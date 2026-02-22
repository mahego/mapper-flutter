import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/widgets/liquid_glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/validators/input_validators.dart';
import '../../../../core/utils/error_handler.dart';
import '../../domain/repositories/request_repository.dart';

/// Nueva solicitud en 4 pasos (paridad Angular CreateRequestComponent):
/// 1) Categoría → 2) Tipo de servicio → 3) Ubicación → 4) Confirmar
class NewRequestPage extends StatefulWidget {
  const NewRequestPage({super.key});

  @override
  State<NewRequestPage> createState() => _NewRequestPageState();
}

class _NewRequestPageState extends State<NewRequestPage> {
  static const _stepLabels = ['Categoría', 'Servicio', 'Ubicación', 'Confirmar'];

  final _requestRepository = RequestRepository(ApiClient());
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _notesController = TextEditingController();

  int _currentStep = 1;
  List<ServiceCategoryModel> _categories = [];
  bool _categoriesLoading = true;
  String _error = '';
  String _successMessage = '';

  ServiceCategoryModel? _selectedCategory;
  ServiceTypeModel? _selectedService;

  double? _originLat;
  double? _originLng;
  String _originDisplay = '';
  double? _destLat;
  double? _destLng;
  String _destDisplay = '';

  bool _loadingOrigin = false;
  bool _loadingDest = false;
  bool _isSubmitting = false;

  // Field validation errors
  String? _originError;
  String? _destinationError;
  String? _notesError;

  double _proposedPrice = 0;
  double? _estimatedDistance;

  List<SavedAddressModel> _savedAddresses = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    try {
      final list = await _requestRepository.getSavedAddresses();
      if (mounted) setState(() => _savedAddresses = list);
    } catch (_) {}
  }

  void _applySavedAddress(SavedAddressModel addr, bool isOrigin) {
    if (isOrigin) {
      setState(() {
        _originLat = addr.latitude;
        _originLng = addr.longitude;
        _originDisplay = addr.address;
        _originController.text = addr.address;
      });
    } else {
      setState(() {
        _destLat = addr.latitude;
        _destLng = addr.longitude;
        _destDisplay = addr.address;
        _destinationController.text = addr.address;
      });
    }
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _requiresOrigin => _selectedService?.requiresOrigin ?? _selectedCategory?.requiresOrigin ?? true;

  Future<void> _loadCategories() async {
    setState(() {
      _categoriesLoading = true;
      _error = '';
    });
    try {
      final list = await _requestRepository.getServiceCategories();
      if (mounted) {
        setState(() {
          _categories = list;
          _categoriesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudieron cargar las categorías de servicio.';
          _categoriesLoading = false;
        });
      }
    }
  }

  void _selectCategory(ServiceCategoryModel cat) {
    setState(() {
      _selectedCategory = cat;
      _selectedService = cat.services.isNotEmpty ? cat.services.first : null;
      _error = '';
      if (cat.services.length == 1) {
        _currentStep = 2;
      } else {
        _currentStep = 2;
      }
    });
  }

  void _selectService(ServiceTypeModel svc) {
    setState(() {
      _selectedService = svc;
      _error = '';
      _currentStep = 3;
    });
  }

  Future<void> _useMyLocation(bool isOrigin) async {
    if (isOrigin) {
      setState(() => _loadingOrigin = true);
    } else {
      setState(() => _loadingDest = true);
    }
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      List<Placemark>? placemarks;
      try {
        placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      } catch (_) {}
      final address = placemarks?.isNotEmpty == true
          ? '${placemarks!.first.street ?? ''}, ${placemarks.first.locality ?? ''}'.trim()
          : 'Mi ubicación actual';
      if (address.isEmpty) {
        if (isOrigin) _originDisplay = 'Mi ubicación actual';
        else _destDisplay = 'Mi ubicación actual';
      } else {
        if (isOrigin) _originDisplay = address;
        else _destDisplay = address;
      }
      if (mounted) {
        setState(() {
          if (isOrigin) {
            _originLat = pos.latitude;
            _originLng = pos.longitude;
            _originController.text = _originDisplay.isEmpty ? 'Mi ubicación actual' : _originDisplay;
            _loadingOrigin = false;
          } else {
            _destLat = pos.latitude;
            _destLng = pos.longitude;
            _destinationController.text = _destDisplay.isEmpty ? 'Mi ubicación actual' : _destDisplay;
            _loadingDest = false;
          }
          _error = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingOrigin = false;
          _loadingDest = false;
          _error = 'No se pudo obtener tu ubicación. Verifica los permisos.';
        });
      }
    }
  }

  Future<void> _geocodeDestination() async {
    final query = _destinationController.text.trim();
    
    // Validate destination address
    final destinationError = InputValidators.validateAddress(query);
    setState(() => _destinationError = destinationError);
    
    if (destinationError != null) {
      setState(() => _error = destinationError);
      return;
    }
    
    setState(() => _loadingDest = true);
    try {
      final locations = await locationFromAddress(query);
      if (locations.isEmpty || !mounted) {
        setState(() {
          _loadingDest = false;
          _destinationError = 'No se encontró la dirección. Prueba con "Mi ubicación" o otra redacción.';
          _error = 'No se encontró la dirección. Prueba con "Mi ubicación" o otra redacción.';
        });
        return;
      }
      final loc = locations.first;
      setState(() {
        _destLat = loc.latitude;
        _destLng = loc.longitude;
        _destDisplay = query;
        _loadingDest = false;
        _error = '';
        _destinationError = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingDest = false;
          _error = 'No se pudo buscar la dirección.';
        });
      }
    }
  }

  void _estimatePrice() {
    double distance = 0;
    if (_requiresOrigin && _originLat != null && _originLng != null && _destLat != null && _destLng != null) {
      distance = _haversine(_originLat!, _originLng!, _destLat!, _destLng!);
    }
    _estimatedDistance = distance;
    double base = 150;
    double perKm = 12;
    if (_selectedService != null) {
      base = _selectedService!.basePrice;
      perKm = _selectedService!.pricePerKm;
    } else if (_selectedCategory != null) {
      base = _selectedCategory!.basePrice;
      perKm = _selectedCategory!.pricePerKm;
    }
    _proposedPrice = base + (distance * perKm);
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) * math.cos(_toRad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * math.pi / 180;

  void _nextStep() {
    setState(() => _error = '');
    if (_currentStep == 1) {
      if (_selectedCategory == null) {
        _error = 'Elige una categoría para continuar';
        return;
      }
      if (_selectedCategory!.services.isEmpty) {
        _error = 'Esta categoría no tiene servicios.';
        return;
      }
      if (_selectedCategory!.services.length == 1) {
        _selectService(_selectedCategory!.services.first);
      } else {
        _currentStep = 2;
      }
      return;
    }
    if (_currentStep == 2) {
      if (_selectedService == null) {
        _error = 'Elige un tipo de servicio para continuar';
        return;
      }
      _currentStep = 3;
      return;
    }
    if (_currentStep == 3) {
      if (_requiresOrigin && (_originLat == null || _originLng == null)) {
        _error = 'Completa origen (usa "Mi ubicación" o escribe y busca).';
        return;
      }
      if (_destLat == null || _destLng == null) {
        if (_destinationController.text.trim().isEmpty) {
          _error = 'Indica la dirección de destino.';
          return;
        }
        _geocodeDestination();
        return;
      }
      _estimatePrice();
      _currentStep = 4;
    }
  }

  void _prevStep() {
    setState(() {
      _error = '';
      if (_currentStep > 1) _currentStep--;
    });
  }

  Future<void> _submitRequest() async {
    // Validate all fields before submission
    final originError = _requiresOrigin ? InputValidators.validateAddress(_originController.text) : null;
    final destinationError = InputValidators.validateAddress(_destinationController.text);
    final notesError = InputValidators.validateNotes(_notesController.text);

    setState(() {
      _originError = originError;
      _destinationError = destinationError;
      _notesError = notesError;
    });

    // Check validations
    if (originError != null) {
      setState(() => _error = originError);
      return;
    }
    if (destinationError != null) {
      setState(() => _error = destinationError);
      return;
    }
    if (notesError != null) {
      setState(() => _error = notesError);
      return;
    }

    if (_selectedCategory == null || _selectedService == null || _destLat == null || _destLng == null) {
      setState(() => _error = 'Faltan datos para crear la solicitud.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = '';
    });
    try {
      await _requestRepository.createExpressRequest(
        categoryId: _selectedCategory!.id,
        serviceTypeId: _selectedService!.id,
        serviceTypeName: _selectedService!.name,
        deliveryLocation: _destDisplay.isNotEmpty ? _destDisplay : _destinationController.text.trim(),
        deliveryLatitude: _destLat!,
        deliveryLongitude: _destLng!,
        offeredPrice: _proposedPrice,
        pickupLocation: _requiresOrigin && _originDisplay.isNotEmpty ? _originDisplay : _originController.text.trim().isNotEmpty ? _originController.text.trim() : null,
        pickupLatitude: _originLat,
        pickupLongitude: _originLng,
        description: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );
      if (mounted) {
        setState(() {
          _successMessage = '¡Solicitud creada exitosamente!';
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Solicitud creada exitosamente!'), backgroundColor: Color(0xFF10b981)),
        );
        context.go('/requests');
      }
    } catch (e) {
      final errorMessage = ErrorHandler.getErrorMessage(e);
      if (mounted) {
        setState(() {
          _error = errorMessage;
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidGlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => _currentStep > 1 ? _prevStep() : context.go('/requests'),
                ),
                title: const Text('Nueva Solicitud', style: TextStyle(color: Colors.white, fontSize: 18)),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStepper(),
                      if (_error.isNotEmpty) _buildError(),
                      if (_successMessage.isNotEmpty) _buildSuccess(),
                      const SizedBox(height: 16),
                      if (_currentStep == 1) _buildStep1(),
                      if (_currentStep == 2) _buildStep2(),
                      if (_currentStep == 3) _buildStep3(),
                      if (_currentStep == 4) _buildStep4(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return LiquidGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: List.generate(_stepLabels.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 20),
                color: _currentStep > (i ~/ 2) + 1 ? const Color(0xFF10b981).withOpacity(0.5) : Colors.white.withOpacity(0.2),
              ),
            );
          }
          final step = (i ~/ 2) + 1;
          final done = _currentStep > step;
          final current = _currentStep == step;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? const Color(0xFF10b981).withOpacity(0.6) : (current ? const Color(0xFF06b6d4) : Colors.white.withOpacity(0.15)),
                ),
                child: done ? const Icon(Icons.check, color: Colors.white, size: 18) : Center(child: Text('$step', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
              ),
              if (step < _stepLabels.length) const SizedBox(width: 4),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(_error, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.5)),
      ),
      child: Text(_successMessage, style: const TextStyle(color: Colors.greenAccent, fontSize: 13)),
    );
  }

  Widget _buildStep1() {
    if (_categoriesLoading) {
      return LiquidGlassCard(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            const CircularProgressIndicator(color: Color(0xFF06b6d4)),
            const SizedBox(height: 16),
            Text('Cargando categorías...', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
          ],
        ),
      );
    }
    if (_categories.isEmpty) {
      return LiquidGlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('No se pudieron cargar las categorías.', style: TextStyle(color: Colors.white.withOpacity(0.8))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: _loadCategories, child: const Text('Reintentar')),
                const SizedBox(width: 8),
                TextButton(onPressed: () => context.go('/requests'), child: const Text('Volver')),
              ],
            ),
          ],
        ),
      );
    }
    return LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Elige una categoría', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
          const SizedBox(height: 16),
          ..._categories.map((cat) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: (_selectedCategory?.id == cat.id) ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _selectCategory(cat),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.category_outlined, color: Color(0xFF06b6d4), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cat.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                                Text('${cat.services.length} servicios', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                              ],
                            ),
                          ),
                          if (_selectedCategory?.id == cat.id) const Icon(Icons.check, color: Color(0xFF06b6d4), size: 22),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _prevStep,
                icon: const Icon(Icons.chevron_left, size: 18),
                label: const Text('Regresar'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white.withOpacity(0.3))),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06b6d4)),
                child: const Text('Siguiente'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    final services = _selectedCategory?.services ?? [];
    return LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Elige el tipo de servicio', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
          const SizedBox(height: 16),
          ...services.map((svc) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: (_selectedService?.id == svc.id) ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _selectService(svc),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.build_circle_outlined, color: Color(0xFF06b6d4), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(svc.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16))),
                          if (_selectedService?.id == svc.id) const Icon(Icons.check, color: Color(0xFF06b6d4), size: 22),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _prevStep,
                icon: const Icon(Icons.chevron_left, size: 18),
                label: const Text('Regresar'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white.withOpacity(0.3))),
              ),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: _nextStep, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06b6d4)), child: const Text('Siguiente')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Indica las direcciones', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
          const SizedBox(height: 16),
          if (_requiresOrigin) ...[
            Text('Dirección de origen', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
            if (_savedAddresses.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _savedAddresses.map((addr) => ActionChip(
                  label: Text(addr.label, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.white.withOpacity(0.1),
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  labelStyle: const TextStyle(color: Colors.white),
                  onPressed: () => _applySavedAddress(addr, true),
                )).toList(),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            TextField(
              controller: _originController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Escribe la dirección de origen...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                suffixIcon: _loadingOrigin
                    ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF06b6d4))))
                    : IconButton(
                        icon: const Icon(Icons.my_location, color: Color(0xFF06b6d4)),
                        onPressed: () => _useMyLocation(true),
                      ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _originError != null
                        ? Colors.red.withOpacity(0.5)
                        : Colors.white.withOpacity(0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _originError != null
                        ? Colors.red.withOpacity(0.5)
                        : Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _originError = InputValidators.validateAddress(value);
                });
              },
            ),
            if (_originError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _originError!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 20),
          ],
          Text('Dirección de destino', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
          if (_savedAddresses.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _savedAddresses.map((addr) => ActionChip(
                label: Text(addr.label, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.white.withOpacity(0.1),
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                labelStyle: const TextStyle(color: Colors.white),
                onPressed: () => _applySavedAddress(addr, false),
              )).toList(),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          TextField(
            controller: _destinationController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Escribe la dirección completa de destino...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              suffixIcon: _loadingDest
                  ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF06b6d4))))
                  : IconButton(
                      icon: const Icon(Icons.my_location, color: Color(0xFF06b6d4)),
                      onPressed: () => _useMyLocation(false),
                    ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _destinationError != null
                      ? Colors.red.withOpacity(0.5)
                      : Colors.white.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _destinationError != null
                      ? Colors.red.withOpacity(0.5)
                      : Colors.white.withOpacity(0.2),
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _destinationError = InputValidators.validateAddress(value);
              });
            },
          ),
          if (_destinationError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _destinationError!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 20),
          Text('Notas (opcional)', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Detalles adicionales...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _notesError != null
                      ? Colors.red.withOpacity(0.5)
                      : Colors.white.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _notesError != null
                      ? Colors.red.withOpacity(0.5)
                      : Colors.white.withOpacity(0.2),
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _notesError = InputValidators.validateNotes(value);
              });
            },
          ),
          if (_notesError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _notesError!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _prevStep,
                icon: const Icon(Icons.chevron_left, size: 18),
                label: const Text('Regresar'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white.withOpacity(0.3))),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () async {
                  if (_destLat != null && _destLng != null) {
                    _nextStep();
                    return;
                  }
                  if (_destinationController.text.trim().isEmpty) {
                    setState(() => _error = 'Indica la dirección de destino.');
                    return;
                  }
                  await _geocodeDestination();
                  if (mounted && _destLat != null && _destLng != null) _nextStep();
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06b6d4)),
                child: const Text('Siguiente'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumen', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
          const SizedBox(height: 12),
          if (_selectedCategory != null) Text('Categoría: ${_selectedCategory!.name}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
          if (_selectedService != null) Text('Servicio: ${_selectedService!.name}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
          if (_requiresOrigin && _originDisplay.isNotEmpty) Text('Origen: $_originDisplay', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
          Text('Destino: ${_destDisplay.isNotEmpty ? _destDisplay : _destinationController.text}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
          if (_estimatedDistance != null) Text('Distancia: ${_estimatedDistance!.toStringAsFixed(1)} km', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
          const SizedBox(height: 16),
          Text('Precio estimado (puedes ajustarlo)', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                onPressed: _proposedPrice > 5 ? () => setState(() => _proposedPrice -= 5) : null,
                icon: const Icon(Icons.remove),
                style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2), foregroundColor: Colors.white),
              ),
              const SizedBox(width: 20),
              Text('\$${_proposedPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
              const SizedBox(width: 20),
              IconButton.filled(
                onPressed: () => setState(() => _proposedPrice += 5),
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2), foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Incrementos de \$5', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
          const SizedBox(height: 24),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _prevStep,
                icon: const Icon(Icons.chevron_left, size: 18),
                label: const Text('Regresar'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white.withOpacity(0.3))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  onPressed: _isSubmitting ? null : _validateAndSubmit,
                  text: _isSubmitting ? 'Creando...' : 'Crear Solicitud',
                  isLoading: _isSubmitting,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _validateAndSubmit() async {
    await _submitRequest();
  }
}
