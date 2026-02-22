import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/widgets/liquid_glass_card.dart';
import '../../../client/domain/repositories/request_repository.dart';

/// Perfil de usuario (paridad Angular ProfileComponent): datos y direcciones guardadas.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();
  final _requestRepository = RequestRepository(ApiClient());

  String _name = '';
  String _email = '';
  String? _phone;
  String _role = '';
  bool _loading = true;
  String? _error;

  List<SavedAddressModel> _addresses = [];
  bool _addressesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadAddresses();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await _authService.getCurrentUser();
      if (mounted) {
        setState(() {
          _name = user?.name ?? '';
          _email = user?.email ?? '';
          _phone = user?.phone;
          _role = _authService.getUserRole() ?? '';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar el perfil.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadAddresses() async {
    setState(() => _addressesLoading = true);
    try {
      final list = await _requestRepository.getSavedAddresses();
      if (mounted) {
        setState(() {
          _addresses = list;
          _addressesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _addressesLoading = false);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) context.go('/login');
  }

  String get _roleLabel {
    switch (_role) {
      case 'cliente':
        return 'Cliente';
      case 'prestador':
        return 'Prestador';
      case 'admin':
        return 'Administrador';
      default:
        return _role.isNotEmpty ? _role : '';
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
                  onPressed: () => context.go('/dashboard/cliente'),
                ),
                title: const Text('Mi Perfil', style: TextStyle(color: Colors.white, fontSize: 18)),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF06b6d4)))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: Colors.white.withOpacity(0.15),
                              child: const Icon(Icons.person, size: 44, color: Colors.white70),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _name.isNotEmpty ? _name : 'Usuario',
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            if (_roleLabel.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(_roleLabel, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              _email,
                              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14),
                            ),
                            if (_phone != null && _phone!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(_phone!, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
                            ],
                            if (_error != null) ...[
                              const SizedBox(height: 16),
                              Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                            ],
                            const SizedBox(height: 24),
                            LiquidGlassCard(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_outlined, color: Colors.white.withOpacity(0.8), size: 22),
                                      const SizedBox(width: 8),
                                      Text('Direcciones guardadas', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (_addressesLoading)
                                    const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: Color(0xFF06b6d4), strokeWidth: 2))),
                                  if (!_addressesLoading && _addresses.isEmpty)
                                    Text('Sin direcciones guardadas.', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
                                  if (!_addressesLoading && _addresses.isNotEmpty)
                                    ..._addresses.map((a) => Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.06),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(a.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                                                const SizedBox(height: 4),
                                                Text(a.address, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                        )),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _logout,
                                icon: const Icon(Icons.logout, size: 20),
                                label: const Text('Cerrar sesión'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                  side: const BorderSide(color: Colors.redAccent),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
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
}
