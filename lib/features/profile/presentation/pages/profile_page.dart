import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/widgets/liquid_glass_card.dart';
import '../../../../core/widgets/liquid_glass_bottom_nav.dart';
import '../../../../core/widgets/notifications_panel.dart';
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
  late final _notificationService = NotificationService(apiClient: ApiClient());

  String _name = '';
  String _email = '';
  String? _phone;
  String _role = '';
  bool _loading = true;
  String? _error;

  List<SavedAddressModel> _addresses = [];
  bool _addressesLoading = true;
  
  bool _drawerOpen = false;
  bool _showNotifications = false;
  int _unreadNotificationsCount = 0;
  
  // Expand/collapse state for tabs
  bool _expandPersonal = true;
  bool _expandAddresses = false;
  bool _expandSettings = false;
  
  // Change password
  bool _showChangePasswordDialog = false;
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';
  bool _changingPassword = false;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadAddresses();
    _loadNotificationCount();
  }

  Future<void> _loadNotificationCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      if (mounted) {
        setState(() => _unreadNotificationsCount = count);
      }
    } catch (e) {
      print('Error loading notification count: $e');
    }
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

  Future<void> _markNotificationsAsRead() async {
    if (_unreadNotificationsCount > 0) {
      setState(() {
        _unreadNotificationsCount = 0;
      });
      try {
        await _notificationService.markAllAsRead();
      } catch (e) {
        print('Error marking notifications as read: $e');
      }
    }
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
      body: Stack(
        children: [
          LiquidGlassBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // Header con drawer y notificaciones
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mi Perfil',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            // Bell icon con notificaciones
                            Stack(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() => _showNotifications = !_showNotifications);
                                    if (_unreadNotificationsCount > 0) {
                                      _markNotificationsAsRead();
                                    }
                                  },
                                  icon: const Icon(Icons.notifications, color: Colors.white),
                                ),
                                if (_unreadNotificationsCount > 0)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFf97316),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        _unreadNotificationsCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            // Menu icon
                            IconButton(
                              onPressed: () {
                                setState(() => _drawerOpen = !_drawerOpen);
                              },
                              icon: const Icon(Icons.menu, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF06b6d4)))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Column(
                              children: [
                                // Profile header
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
                                if (_error != null) ...[
                                  const SizedBox(height: 16),
                                  Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                                ],
                                const SizedBox(height: 24),
                                // Collapsible panels
                                _buildCollapsiblePanel(
                                  title: 'Datos Personales',
                                  icon: Icons.person_outline,
                                  isExpanded: _expandPersonal,
                                  onTap: () => setState(() => _expandPersonal = !_expandPersonal),
                                  child: _buildPersonalDataPanel(),
                                ),
                                const SizedBox(height: 12),
                                _buildCollapsiblePanel(
                                  title: 'Direcciones Guardadas',
                                  icon: Icons.location_on_outlined,
                                  isExpanded: _expandAddresses,
                                  onTap: () => setState(() => _expandAddresses = !_expandAddresses),
                                  child: _buildAddressesPanel(),
                                ),
                                const SizedBox(height: 12),
                                _buildCollapsiblePanel(
                                  title: 'Configuración',
                                  icon: Icons.settings_outlined,
                                  isExpanded: _expandSettings,
                                  onTap: () => setState(() => _expandSettings = !_expandSettings),
                                  child: _buildSettingsPanel(),
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
                                const SizedBox(height: 80), // Space for bottom nav on mobile
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          // Drawer
          _buildDrawer(),
          // Notifications panel
          if (_showNotifications)
            Positioned(
              top: 100,
              right: 16,
              child: GestureDetector(
                onTap: () {},
                child: NotificationsPanel(
                  notificationService: _notificationService,
                  unreadCount: _unreadNotificationsCount,
                  onNotificationTap: () {
                    _markNotificationsAsRead();
                    setState(() => _showNotifications = false);
                  },
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCollapsiblePanel({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.white.withOpacity(0.8), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              Container(
                height: 1,
                color: Colors.white.withOpacity(0.1),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDataPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoField('Nombre', _name.isNotEmpty ? _name : 'No especificado', Icons.person),
        const SizedBox(height: 12),
        _buildInfoField('Email', _email, Icons.email),
        const SizedBox(height: 12),
        _buildInfoField(
          'Teléfono',
          _phone != null && _phone!.isNotEmpty ? _phone! : 'No especificado',
          Icons.phone,
        ),
        const SizedBox(height: 12),
        _buildInfoField('Rol', _roleLabel.isNotEmpty ? _roleLabel : 'No especificado', Icons.badge),
      ],
    );
  }

  Widget _buildAddressesPanel() {
    if (_addressesLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(color: Color(0xFF06b6d4), strokeWidth: 2),
        ),
      );
    }

    if (_addresses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Sin direcciones guardadas.',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      children: _addresses
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final address = entry.value;
            final isLast = index == _addresses.length - 1;
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: const Color(0xFF06b6d4),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            address.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        address.address,
                        style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (!isLast) const SizedBox(height: 8),
              ],
            );
          })
          .toList(),
    );
  }

  Widget _buildSettingsPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingToggle('Notificaciones por email', true, (value) {
          // Handle preference
        }),
        const SizedBox(height: 12),
        _buildSettingToggle('Notificaciones SMS', false, (value) {
          // Handle preference
        }),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacidad',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gestionar compartición de datos',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showChangePasswordDialog ? null : () => _showPasswordChangeDialog(),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cambiar contraseña',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Actualizar tu contraseña',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.5)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingToggle(String label, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF06b6d4),
          ),
        ],
      ),
    );
  }

  void _showPasswordChangeDialog() {
    setState(() => _showChangePasswordDialog = true);
    _currentPassword = '';
    _newPassword = '';
    _confirmPassword = '';
    _passwordError = null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0f172a).withOpacity(0.95),
              title: const Text(
                'Cambiar contraseña',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Contraseña actual',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF06b6d4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF06b6d4)),
                      ),
                    ),
                    onChanged: (value) => setDialogState(() => _currentPassword = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nueva contraseña',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon: const Icon(Icons.lock_open, color: Color(0xFF06b6d4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF06b6d4)),
                      ),
                    ),
                    onChanged: (value) => setDialogState(() => _newPassword = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Confirmar contraseña',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon: const Icon(Icons.check_circle, color: Color(0xFF06b6d4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF06b6d4)),
                      ),
                    ),
                    onChanged: (value) => setDialogState(() => _confirmPassword = value),
                  ),
                  if (_passwordError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _passwordError!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _changingPassword
                      ? null
                      : () {
                          setState(() => _showChangePasswordDialog = false);
                          Navigator.pop(context);
                        },
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06b6d4),
                  ),
                  onPressed: _changingPassword ? null : () => _changePassword(context),
                  child: _changingPassword
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Cambiar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      setState(() => _showChangePasswordDialog = false);
    });
  }

  Future<void> _changePassword(BuildContext dialogContext) async {
    setState(() => _passwordError = null);

    // Validation
    if (_currentPassword.isEmpty) {
      setState(() => _passwordError = 'Ingresa tu contraseña actual');
      return;
    }
    if (_newPassword.isEmpty) {
      setState(() => _passwordError = 'Ingresa una nueva contraseña');
      return;
    }
    if (_newPassword.length < 6) {
      setState(() => _passwordError = 'La contraseña debe tener mínimo 6 caracteres');
      return;
    }
    if (_newPassword != _confirmPassword) {
      setState(() => _passwordError = 'Las contraseñas no coinciden');
      return;
    }

    setState(() => _changingPassword = true);

    try {
      await _authService.changePassword(_currentPassword, _newPassword);
      if (mounted) {
        Navigator.pop(dialogContext);
        _showSuccessSnackbar('Contraseña actualizada correctamente');
        setState(() {
          _showChangePasswordDialog = false;
          _currentPassword = '';
          _newPassword = '';
          _confirmPassword = '';
          _passwordError = null;
          _changingPassword = false;
        });
      }
    } catch (e) {
      setState(() {
        _passwordError = 'Error al cambiar contraseña: ${e.toString().replaceAll('Exception: ', '')}';
        _changingPassword = false;
      });
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10b981),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildDrawer() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      right: _drawerOpen ? 0 : -250,
      top: 0,
      bottom: 0,
      width: 250,
      child: Stack(
        children: [
          // Backdrop
          if (_drawerOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _drawerOpen = false),
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
            ),
          // Drawer panel
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              border: Border(
                left: BorderSide(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
            ),
            child: Column(
              children: [
                // Drawer header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withOpacity(0.15),
                        child: const Icon(Icons.person, color: Colors.white70),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _name.isNotEmpty ? _name : 'Usuario',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _roleLabel,
                              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Menu items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    children: [
                      _drawerLink('Ir al Dashboard', Icons.dashboard_outlined, () {
                        context.go('/dashboard/cliente');
                        setState(() => _drawerOpen = false);
                      }),
                      _drawerLink('Mi Perfil', Icons.person_outline, () {
                        setState(() => _drawerOpen = false);
                      }),
                      _drawerLink('Mis Solicitudes', Icons.assignment_outlined, () {
                        context.go('/solicitudes');
                        setState(() => _drawerOpen = false);
                      }),
                      _drawerLink('Tracking', Icons.location_on_outlined, () {
                        context.go('/tracking');
                        setState(() => _drawerOpen = false);
                      }),
                      _drawerLink('Refrescar', Icons.refresh, () {
                        _loadProfile();
                        _loadAddresses();
                        _loadNotificationCount();
                        setState(() => _drawerOpen = false);
                      }),
                      Divider(color: Colors.white12, height: 24, indent: 16, endIndent: 16),
                      _drawerLink('Cerrar sesión', Icons.logout, _logout,
                          color: const Color(0xFFf97316)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerLink(
    String label,
    IconData icon,
    VoidCallback onTap, {
    Color color = Colors.white,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: color.withOpacity(0.8)),
        title: Text(label, style: TextStyle(color: color)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
    );
  }

  Widget _buildBottomNav() {
    final width = MediaQuery.of(context).size.width;
    if (width >= 768) return const SizedBox.shrink();

    return LiquidGlassBottomNav(
      items: const [
        BottomNavItem(label: 'Inicio', icon: Icons.home_outlined, route: '/dashboard/cliente'),
        BottomNavItem(label: 'Solicitudes', icon: Icons.assignment_outlined, route: '/solicitudes'),
        BottomNavItem(label: 'Tracking', icon: Icons.location_on_outlined, route: '/tracking'),
        BottomNavItem(label: 'Perfil', icon: Icons.person_outline, route: '/perfil'),
      ],
      currentIndex: 3,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/dashboard/cliente');
            break;
          case 1:
            context.go('/solicitudes');
            break;
          case 2:
            context.go('/tracking');
            break;
          case 3:
            break;
        }
      },
    );
  }
}
