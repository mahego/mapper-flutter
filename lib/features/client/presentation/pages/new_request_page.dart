import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:glass/glass.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/widgets/liquid_glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/modern_glass_card.dart';
import '../../../../core/widgets/liquid_glass_modal.dart';
import '../../../../core/validators/input_validators.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/services/geolocation_service.dart';
import '../../../../core/services/google_places_service.dart';
import '../../domain/repositories/request_repository.dart';
import '../../../pricing/domain/repositories/pricing_repository.dart';
import '../../../auth/data/repositories/profile_repository.dart';

/// Nueva solicitud en 4 pasos (paridad Angular CreateRequestComponent):
/// 1) Categoría → 2) Tipo de servicio → 3) Ubicación → 4) Confirmar
class NewRequestPage extends StatefulWidget {
  const NewRequestPage({super.key});

  @override
  State<NewRequestPage> createState() => _NewRequestPageState();
}

class _NewRequestPageState extends State<NewRequestPage> {
  static const _stepLabels = ['Categoría', 'Servicio', 'Ubicación', 'Confirmar'];

  late final RequestRepository _requestRepository;
  late final PricingRepository _pricingRepository;
  late final ProfileRepository _profileRepository;
  late final GooglePlacesService _googlePlacesService;
  final _geolocationService = GeolocationService();
  
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _notesController = TextEditingController();
  final _apiClient = ApiClient();

  int _currentStep = 1;
  List<ServiceCategoryModel> _categories = [];
  bool _categoriesLoading = true;
  String _error = '';
  String _successMessage = '';
  
  // Location permissions status
  bool _locationPermissionGranted = false;
  bool _checkingPermissions = true;

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
  bool _estimatingPrice = false;

  // Field validation errors
  String? _originError;
  String? _destinationError;
  String? _notesError;

  double _proposedPrice = 0;
  double? _estimatedDistance;
  double? _baseFare;
  double? _distanceFare;

  List<SavedAddressModel> _savedAddresses = [];
  
  // User profile data
  String? _userName;
  String? _userPhone;

  @override
  void initState() {
    super.initState();
    _initializeRepositories();
    _requestLocationPermissions();
    _loadCategories();
    _loadSavedAddresses();
    _loadUserProfile();
  }

  void _initializeRepositories() {
    _requestRepository = RequestRepository(_apiClient);
    _pricingRepository = PricingRepository(_apiClient);
    _profileRepository = ProfileRepository(_apiClient);
    _googlePlacesService = GooglePlacesService(
      dio: _apiClient.client,
      apiKey: AppConstants.googlePlacesApiKey,
    );
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _profileRepository.getProfile();
      if (mounted) {
        setState(() {
          _userName = profile.name;
          _userPhone = profile.phone;
        });
      }
    } catch (e) {
      print('❌ Error cargando perfil: $e');
    }
  }

  Future<void> _requestLocationPermissions() async {
    setState(() => _checkingPermissions = true);
    try {
      final hasPermission = await _geolocationService.handlePermissions();
      if (mounted) {
        setState(() {
          _locationPermissionGranted = hasPermission;
          _checkingPermissions = false;
        });
        
        if (!hasPermission) {
          // Show dialog explaining that location is needed
          _showLocationPermissionDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationPermissionGranted = false;
          _checkingPermissions = false;
        });
      }
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (ctx) => LiquidGlassModal(
        type: LiquidGlassModalType.info,
        title: 'Permisos de ubicación',
        message:
            'Esta app necesita acceso a tu ubicación para poder crear solicitudes de servicio y rastrear entregas. Por favor, habilita los permisos de ubicación.',
        confirmLabel: 'Abrir configuración',
        cancelLabel: 'Cancelar',
        onConfirm: () => _geolocationService.openAppSettings(),
        onCancel: () => Navigator.of(ctx).pop(),
        barrierDismissible: true,
      ),
    );
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
      print('📋 Cargando categorías de servicio...');
      final list = await _requestRepository.getServiceCategories();
      print('✅ Categorías cargadas: ${list.length}');
      
      if (mounted) {
        setState(() {
          _categories = list;
          _categoriesLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error al cargar categorías: $e');
      print('Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _error = 'No se pudieron cargar las categorías de servicio. Error: ${e.toString()}';
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
    print('📍 Intentando obtener ubicación actual (isOrigin=$isOrigin)...');
    
    if (!_locationPermissionGranted) {
      print('❌ Permisos de ubicación no otorgados');
      setState(() => _error = 'Necesitas habilitar los permisos de ubicación.');
      _showLocationPermissionDialog();
      return;
    }

    if (isOrigin) {
      setState(() {
        _loadingOrigin = true;
        _error = '';
      });
    } else {
      setState(() {
        _loadingDest = true;
        _error = '';
      });
    }
    
    try {
      // Check if location services are enabled
      final serviceEnabled = await _geolocationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Servicios de ubicación deshabilitados en el dispositivo');
        if (mounted) {
          setState(() {
            _loadingOrigin = false;
            _loadingDest = false;
            _error = 'Los servicios de ubicación están deshabilitados. Por favor, habilítalos en la configuración del dispositivo.';
          });
        }
        return;
      }

      print('📡 Obteniendo posición GPS...');
      final pos = await _geolocationService.getCurrentPosition(
        accuracy: LocationAccuracy.best,
      );
      
      if (pos == null) {
        print('❌ No se pudo obtener la posición GPS');
        if (mounted) {
          setState(() {
            _loadingOrigin = false;
            _loadingDest = false;
            _error = 'No se pudo obtener tu ubicación. Verifica que:\n• Los servicios de ubicación estén habilitados\n• Tengas señal GPS\n• La app tenga permisos de ubicación';
          });
        }
        return;
      }

      print('✅ Posición obtenida: ${pos.latitude}, ${pos.longitude}');
      
      // Get human-readable address via reverse geocoding
      String displayAddress = await _getReverseGeocodeAddress(pos.latitude, pos.longitude);
      print('📍 Dirección obtenida: $displayAddress');
      
      if (mounted) {
        setState(() {
          if (isOrigin) {
            _originLat = pos.latitude;
            _originLng = pos.longitude;
            _originDisplay = displayAddress;
            _originController.text = displayAddress;
            _loadingOrigin = false;
            _originError = null;
            print('✅ Origen establecido: $_originLat, $_originLng');
          } else {
            _destLat = pos.latitude;
            _destLng = pos.longitude;
            _destDisplay = displayAddress;
            _destinationController.text = displayAddress;
            _loadingDest = false;
            _destinationError = null;
            print('✅ Destino establecido: $_destLat, $_destLng');
          }
          _error = '';
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error obteniendo ubicación: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _loadingOrigin = false;
          _loadingDest = false;
          _error = 'Error obteniendo ubicación: ${e.toString()}';
        });
      }
    }
  }

  /// Obtiene dirección legible desde coordenadas usando geocoding inverso
  Future<String> _getReverseGeocodeAddress(double lat, double lng) async {
    try {
      print('🔎 Google Reverse geocoding: $lat, $lng');
      
      // Usar Google Geocoding API para reverse geocoding
      final result = await _googlePlacesService.reverseGeocode(lat, lng);
      
      // Devolver la dirección formateada de Google
      print('✅ Dirección obtenida: ${result.address}');
      return result.address;
    } catch (e) {
      print('❌ Error en geocoding inverso: $e');
      return 'Mi ubicación actual';
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
    
    print('🔍 Buscando coordenadas para: "$query"');
    setState(() {
      _loadingDest = true;
      _error = '';
    });

    try {
      print('📡 Usando Google Geocoding para búsqueda de dirección...');
      final result = await _googlePlacesService.searchAddress(query);
      
      // Validar si la búsqueda fue exitosa (no es fallback)
      if (result.address.startsWith('Lat:')) {
        print('❌ No se encontraron coordenadas para: "$query"');
        if (mounted) {
          setState(() {
            _loadingDest = false;
            _destinationError = 'Dirección no encontrada. Intenta con:\n• Una dirección más específica\n• El nombre de una calle o avenida\n• Usar "Mi ubicación"';
            _error = _destinationError ?? 'Dirección no encontrada';
          });
        }
        return;
      }
      
      print('✅ Coordenadas encontradas: ${result.lat}, ${result.lng}');
      
      // Usar dirección de Mapbox como display
      String displayAddress = result.address;
      print('✅ Dirección: $displayAddress');
      
      if (!mounted) return;
      
      setState(() {
        _destLat = result.lat;
        _destLng = result.lng;
        _destDisplay = displayAddress;
        _destinationController.text = displayAddress;
        _loadingDest = false;
        _error = '';
        _destinationError = null;
        print('✅ Destino geocodificado: $_destLat, $_destLng');
      });
    } catch (e, stackTrace) {
      print('❌ Error geocodificando dirección: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _loadingDest = false;
          _destinationError = 'Error buscando dirección. Intenta nuevamente.';
          _error = _destinationError ?? 'Error buscando dirección';
        });
      }
    }
  }

  Future<void> _estimatePrice() async {
    if (_selectedService == null || _destLat == null || _destLng == null) {
      setState(() => _error = 'Faltan datos para estimar el precio.');
      return;
    }

    setState(() {
      _estimatingPrice = true;
      _error = '';
    });

    try {
      print('📊 Solicitando estimación de precio al servidor...');
      
      // Get pricing estimate from backend
      final estimate = await _pricingRepository.calculatePrice(
        serviceId: _selectedService!.id,
        originLat: _originLat ?? 25.6866, // Default to Monterrey coords
        originLng: _originLng ?? -100.3161,
        destLat: _destLat!,
        destLng: _destLng!,
      );

      if (mounted) {
        setState(() {
          _proposedPrice = estimate.total;
          _baseFare = estimate.basePrice;
          _distanceFare = estimate.distanceCost;
          _estimatedDistance = estimate.distanceKm;
          _estimatingPrice = false;
          print('✅ Precio estimado desde servidor: \$${estimate.total}');
        });
      }
    } catch (e) {
      print('❌ Error estimando precio: $e');
      
      // Check if it's an auth error (401)
      final errorStr = e.toString();
      final isAuthError = errorStr.contains('401') || 
                         errorStr.contains('UNAUTHORIZED') || 
                         errorStr.contains('Unauthorized');
      
      if (isAuthError) {
        print('⚠️ Error de autenticación detectado (401). Usando cálculo local...');
      }
      
      // Use local calculation as fallback
      print('📐 Usando cálculo local (Haversine)...');
      _fallbackEstimatePrice();
      
      if (mounted) {
        setState(() {
          _estimatingPrice = false;
          if (isAuthError) {
            _error = 'Usando tarifa local. Conecta con internet para actualizaciones en tiempo real.';
          }
          print('✅ Precio estimado local: \$${_proposedPrice}');
        });
      }
    }
  }

  void _fallbackEstimatePrice() {
    print('📐 Iniciando cálculo local de precio (Haversine)...');
    
    double distance = 0;
    
    // Calculate distance if origin and destination are available
    if (_originLat != null && _originLng != null && _destLat != null && _destLng != null) {
      print('📍 Calculando distancia entre: ($_originLat, $_originLng) → ($_destLat, $_destLng)');
      distance = _haversine(_originLat!, _originLng!, _destLat!, _destLng!);
      print('📏 Distancia calculada: ${distance.toStringAsFixed(2)} km');
    } else if (_destLat != null && _destLng != null && !_requiresOrigin) {
      // For services that don't require origin, distance might be 0 or handled differently
      print('⚠️ Servicio sin requerimiento de origen. Distancia = 0');
      distance = 0;
    } else {
      print('⚠️ No hay coordenadas suficientes para calcular distancia');
      distance = 0;
    }
    
    _estimatedDistance = distance;
    
    // Get base fare and price per km from selected service
    final base = _selectedService?.basePrice ?? _selectedCategory?.basePrice ?? 150.0;
    final perKm = _selectedService?.pricePerKm ?? _selectedCategory?.pricePerKm ?? 12.0;
    
    print('💰 Tarifa base: \$$base');
    print('🛣️  Precio por km: \$$perKm');
    
    _baseFare = base;
    _distanceFare = distance * perKm;
    _proposedPrice = base + (distance * perKm);
    
    print('💵 Desglose:');
    print('   - Base: \$$base');
    print('   - Distancia: ${distance.toStringAsFixed(2)} km × \$$perKm = \$${_distanceFare}');
    print('   - Total: \$${_proposedPrice.toStringAsFixed(2)}');
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

  Future<void> _nextStep() async {
    setState(() => _error = '');
    
    if (_currentStep == 1) {
      if (_selectedCategory == null) {
        setState(() => _error = 'Elige una categoría para continuar');
        return;
      }
      if (_selectedCategory!.services.isEmpty) {
        setState(() => _error = 'Esta categoría no tiene servicios.');
        return;
      }
      if (_selectedCategory!.services.length == 1) {
        _selectService(_selectedCategory!.services.first);
      } else {
        setState(() => _currentStep = 2);
      }
      return;
    }
    
    if (_currentStep == 2) {
      if (_selectedService == null) {
        setState(() => _error = 'Elige un tipo de servicio para continuar');
        return;
      }
      setState(() => _currentStep = 3);
      return;
    }
    
    if (_currentStep == 3) {
      if (_requiresOrigin && (_originLat == null || _originLng == null)) {
        setState(() => _error = 'Completa origen (usa "Mi ubicación" o escribe y busca).');
        return;
      }
      if (_destLat == null || _destLng == null) {
        if (_destinationController.text.trim().isEmpty) {
          setState(() => _error = 'Indica la dirección de destino.');
          return;
        }
        await _geocodeDestination();
        if (!mounted || _destLat == null || _destLng == null) return;
      }
      
      // Estimate price and move to confirmation
      await _estimatePrice();
      if (mounted) {
        setState(() => _currentStep = 4);
      }
      return;
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
        context.go('/dashboard/cliente', extra: {'tab': 1});
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
                  onPressed: () => _currentStep > 1 ? _prevStep() : context.go('/dashboard/cliente', extra: {'tab': 1}),
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
                TextButton(onPressed: () => context.go('/dashboard/cliente', extra: {'tab': 1}), child: const Text('Volver')),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Selecciona una categoría',
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_categories.length, (index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory?.id == cat.id;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ModernGlassCard(
              onTap: () => _selectCategory(cat),
              opacity: isSelected ? 0.25 : 0.1,
              tintColor: isSelected ? const Color(0xFF06b6d4) : Colors.white,
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Color(0xFF06b6d4).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getCategoryIcon(cat.name),
                      color: const Color(0xFF06b6d4),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${cat.services.length} servicios disponibles',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF06b6d4),
                      size: 24,
                    ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => context.go('/dashboard/cliente', extra: {'tab': 1}),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Cancelar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedCategory != null ? _nextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06b6d4),
                  disabledBackgroundColor: Colors.white.withOpacity(0.1),
                ),
                child: const Text('Siguiente'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final services = _selectedCategory?.services ?? [];
    
    if (services.isEmpty) {
      return LiquidGlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Esta categoría no tiene servicios disponibles.',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _prevStep,
              child: const Text('Volver'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Elige el tipo de servicio',
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(services.length, (index) {
          final svc = services[index];
          final isSelected = _selectedService?.id == svc.id;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ModernGlassCard(
              onTap: () => _selectService(svc),
              opacity: isSelected ? 0.25 : 0.1,
              tintColor: isSelected ? const Color(0xFF06b6d4) : Colors.white,
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Color(0xFF10b981).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.miscellaneous_services_rounded,
                      color: Color(0xFF10b981),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          svc.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Desde \$${svc.basePrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Color(0xFF10b981),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF06b6d4),
                      size: 24,
                    ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _prevStep,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Regresar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedService != null ? _nextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06b6d4),
                  disabledBackgroundColor: Colors.white.withOpacity(0.1),
                ),
                child: const Text('Siguiente'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3() {
    final hasOrigin = _originLat != null && _originLng != null;
    final hasDest = _destLat != null && _destLng != null;
    
    return LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text('Ubicaciones del servicio', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade300, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '📍 Toca el ícono de GPS para tu ubicación o escribe una dirección',
                      style: TextStyle(color: Colors.blue.shade100, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // ORIGIN
            if (_requiresOrigin) ...[
              Row(
                children: [
                  Text('📤 Dirección de origen', 
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14, fontWeight: FontWeight.w500)),
                  if (hasOrigin)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(Icons.check_circle, color: Colors.green, size: 18),
                    ),
                ],
              ),
              
              if (_savedAddresses.isNotEmpty) ...[
                const SizedBox(height: 8),
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
              ],
              
              const SizedBox(height: 12),
              TextField(
                controller: _originController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Mi ubicación actual o calle/avenida...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  suffixIcon: _loadingOrigin
                      ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF06b6d4))))
                      : Tooltip(
                          message: 'Obtener mi ubicación actual',
                          child: IconButton(
                            icon: const Icon(Icons.location_on, color: Color(0xFF06b6d4), size: 22),
                            onPressed: () => _useMyLocation(true),
                          ),
                        ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _originError != null
                          ? Colors.red.withOpacity(0.5)
                          : hasOrigin ? Colors.green.withOpacity(0.3) : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _originError != null
                          ? Colors.red.withOpacity(0.5)
                          : hasOrigin ? Colors.green.withOpacity(0.3) : Colors.white.withOpacity(0.2),
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
            
            // DESTINATION
            Row(
              children: [
                Text('📥 Dirección de destino', 
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14, fontWeight: FontWeight.w500)),
                if (hasDest)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(Icons.check_circle, color: Colors.green, size: 18),
                  ),
              ],
            ),
            
            if (_savedAddresses.isNotEmpty) ...[
              const SizedBox(height: 8),
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
            ],
            
            const SizedBox(height: 12),
            TextField(
              controller: _destinationController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Mi ubicación actual o dirección...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                suffixIcon: _loadingDest
                    ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF06b6d4))))
                    : Tooltip(
                        message: 'Obtener mi ubicación actual',
                        child: IconButton(
                          icon: const Icon(Icons.location_on, color: Color(0xFF06b6d4), size: 22),
                          onPressed: () => _useMyLocation(false),
                        ),
                      ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _destinationError != null
                        ? Colors.red.withOpacity(0.5)
                        : hasDest ? Colors.green.withOpacity(0.3) : Colors.white.withOpacity(0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _destinationError != null
                        ? Colors.red.withOpacity(0.5)
                        : hasDest ? Colors.green.withOpacity(0.3) : Colors.white.withOpacity(0.2),
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
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
            const SizedBox(height: 20),
            
            // NOTES
            Text('📝 Notas (opcional)', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Detalles: acceso, referencias, piso...',
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
            
            const SizedBox(height: 24),
            
            // ACTION BUTTONS
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _prevStep,
                  icon: const Icon(Icons.chevron_left, size: 18),
                  label: const Text('Regresar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Check if coordinates are already set
                      if (_destLat != null && _destLng != null) {
                        _nextStep();
                        return;
                      }
                      
                      // Try to geocode destination if text is entered
                      if (_destinationController.text.trim().isEmpty) {
                        setState(() => _error = 'Por favor, escriba o use "Mi ubicación" para el destino.');
                        return;
                      }
                      
                      // Geocode and proceed if successful
                      await _geocodeDestination();
                      if (mounted && _destLat != null && _destLng != null) {
                        _nextStep();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06b6d4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Estimar precio'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Resumen de solicitud',
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        // Service details card
        ModernGlassCard(
          opacity: 0.08,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Servicio',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              if (_selectedCategory != null)
                Text(
                  _selectedCategory!.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 4),
              if (_selectedService != null)
                Text(
                  _selectedService!.name,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Locations card
        ModernGlassCard(
          opacity: 0.08,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_rounded, color: Color(0xFF06b6d4), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Ubicaciones',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_requiresOrigin)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Color(0xFF10b981).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            'A',
                            style: TextStyle(
                              color: Color(0xFF10b981),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _originDisplay.isNotEmpty ? _originDisplay : _originController.text,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Color(0xFFef4444).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        'B',
                        style: TextStyle(
                          color: Color(0xFFef4444),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _destDisplay.isNotEmpty ? _destDisplay : _destinationController.text,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (_estimatedDistance != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.straighten, color: Colors.white.withOpacity(0.5), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Distancia: ${_estimatedDistance!.toStringAsFixed(2)} km',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Pricing card with breakdown
        ModernGlassCard(
          opacity: 0.15,
          tintColor: const Color(0xFF06b6d4),
          elevation: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Desglose de tarifa',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_estimatingPrice)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Color(0xFF06b6d4)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (_baseFare != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tarifa base:', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                      Text('\$${_baseFare!.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              if (_distanceFare != null && _estimatedDistance != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tarifa por distancia:', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                      Text('\$${_distanceFare!.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              const Divider(height: 12, color: Colors.white24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total estimado:', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('\$${_proposedPrice.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF06b6d4), fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Price adjustment
        ModernGlassCard(
          opacity: 0.05,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Puedes ajustar el precio',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: _proposedPrice > 5 ? () => setState(() => _proposedPrice -= 5) : null,
                    icon: const Icon(Icons.remove),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      disabledBackgroundColor: Colors.white.withOpacity(0.05),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    '\$${_proposedPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton.filled(
                    onPressed: () => setState(() => _proposedPrice += 5),
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Incrementos de \$5',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Action buttons
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _isSubmitting ? null : _prevStep,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Regresar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                disabledForegroundColor: Colors.white.withOpacity(0.3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10b981),
                  disabledBackgroundColor: Colors.white.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isSubmitting)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    else
                      const Icon(Icons.check_circle, size: 18),
                    const SizedBox(width: 8),
                    Text(_isSubmitting ? 'Creando...' : 'Crear solicitud'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('transporte') || name.contains('delivery')) return Icons.local_shipping_rounded;
    if (name.contains('mudanza')) return Icons.home_work_rounded;
    if (name.contains('taxi') || name.contains('viaje')) return Icons.directions_car_rounded;
    if (name.contains('comida') || name.contains('restaurant')) return Icons.restaurant_rounded;
    if (name.contains('entrega')) return Icons.local_shipping_rounded;
    if (name.contains('compra') || name.contains('shopping')) return Icons.shopping_cart_rounded;
    return Icons.category_rounded;
  }

  Future<void> _validateAndSubmit() async {
    await _submitRequest();
  }
}
