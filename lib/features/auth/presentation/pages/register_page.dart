import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/widgets/liquid_glass_card.dart';
import '../../../../core/widgets/liquid_glass_text_field.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/liquid_glass_snackbar.dart';
import '../../../../core/widgets/social_login_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  final _firebaseAuthService = FirebaseAuthService();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isFacebookLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'cliente';
  int _currentStep = 1; // Wizard 3 pasos: 1=rol, 2=método, 3=formulario
  bool _registerWithEmail = true; // step 2: true = email, false = social

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: _selectedRole,
        phone: _phoneController.text.trim().isNotEmpty 
            ? _phoneController.text.trim() 
            : null,
      );

      if (!mounted) return;

      LiquidGlassSnackBar.showSuccess(
        context, 
        '¡Registro exitoso! Bienvenido ${user.name}'
      );

      // Navigate based on role
      switch (user.role) {
        case 'prestador':
          context.go('/provider/home');
          break;
        case 'cliente':
          context.go('/client/home');
          break;
        case 'tienda':
          context.go('/store/pos');
          break;
        default:
          context.go('/');
      }
    } catch (e) {
      if (!mounted) return;
      LiquidGlassSnackBar.showError(context, 'Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleRegister() async {
    setState(() => _isGoogleLoading = true);

    try {
      final firebaseUser = await _firebaseAuthService.signInWithGoogle();
      
      if (firebaseUser == null) {
        // User canceled
        if (mounted) {
          setState(() => _isGoogleLoading = false);
        }
        return;
      }

      // Get Firebase ID token
      final idToken = await firebaseUser.getIdToken();
      
      if (idToken == null) {
        throw Exception('No se pudo obtener el token de autenticación');
      }

      // Send to backend
      final user = await _authService.loginWithSocial(idToken, 'google');

      if (!mounted) return;

      // Check if needs to complete profile
      if (user.needsCompleteProfile ?? false) {
        context.push('/auth/complete-profile');
        return;
      }

      // Navigate based on role
      switch (user.role) {
        case 'prestador':
          context.go('/provider/home');
          break;
        case 'cliente':
          context.go('/client/home');
          break;
        case 'tienda':
          context.go('/store/pos');
          break;
        default:
          context.go('/');
      }
      
      LiquidGlassSnackBar.showSuccess(context, '¡Registro exitoso!');
    } catch (e) {
      if (!mounted) return;
      LiquidGlassSnackBar.showError(
        context,
        'Error al registrar con Google: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  Future<void> _handleFacebookRegister() async {
    setState(() => _isFacebookLoading = true);

    try {
      final firebaseUser = await _firebaseAuthService.signInWithFacebook();
      
      if (firebaseUser == null) {
        // User canceled
        if (mounted) {
          setState(() => _isFacebookLoading = false);
        }
        return;
      }

      // Get Firebase ID token
      final idToken = await firebaseUser.getIdToken();
      
      if (idToken == null) {
        throw Exception('No se pudo obtener el token de autenticación');
      }

      // Send to backend
      final user = await _authService.loginWithSocial(idToken, 'facebook');

      if (!mounted) return;

      // Check if needs to complete profile
      if (user.needsCompleteProfile ?? false) {
        context.push('/auth/complete-profile');
        return;
      }

      // Navigate based on role
      switch (user.role) {
        case 'prestador':
          context.go('/provider/home');
          break;
        case 'cliente':
          context.go('/client/home');
          break;
        case 'tienda':
          context.go('/store/pos');
          break;
        default:
          context.go('/');
      }
      
      LiquidGlassSnackBar.showSuccess(context, '¡Registro exitoso!');
    } catch (e) {
      if (!mounted) return;
      LiquidGlassSnackBar.showError(
        context,
        'Error al registrar con Facebook: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() => _isFacebookLoading = false);
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
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        if (_currentStep > 1) {
                          setState(() => _currentStep--);
                        } else {
                          context.pop();
                        }
                      },
                    ),
                    const Text(
                      'Crear Cuenta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: Column(
                        children: [
                          // Logo
                          Icon(
                            Icons.person_add_rounded,
                            size: 70,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 30,
                                color: const Color(0xFFf97316).withOpacity(0.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _currentStep == 1
                                ? 'Paso 1 de 3'
                                : _currentStep == 2
                                    ? 'Paso 2 de 3'
                                    : 'Paso 3 de 3',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentStep == 1
                                ? 'Elige tu tipo de cuenta'
                                : _currentStep == 2
                                    ? '¿Cómo quieres registrarte?'
                                    : 'Completa tus datos',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 28),

                          if (_currentStep == 1) _buildStep1Role(),
                          if (_currentStep == 2) _buildStep2Method(),
                          if (_currentStep == 3) _buildStep3Form(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1Role() {
    return LiquidGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _roleOption('cliente', 'Cliente', 'Solicito servicios y pedidos', Icons.person),
          const SizedBox(height: 12),
          _roleOption('prestador', 'Prestador', 'Ofrezco servicios de entrega', Icons.local_shipping),
          const SizedBox(height: 12),
          _roleOption('tienda', 'Tienda', 'Vendo productos y recibo pedidos', Icons.store),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => setState(() => _currentStep = 2),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06b6d4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Siguiente'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleOption(String value, String label, String subtitle, IconData icon) {
    final selected = _selectedRole == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _selectedRole = value),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF06b6d4).withOpacity(0.25) : Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? const Color(0xFF06b6d4) : Colors.white24,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? const Color(0xFF06b6d4) : Colors.white70, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                    Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check_circle, color: Color(0xFF06b6d4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2Method() {
    return LiquidGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _currentStep = 3),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email_outlined, color: Colors.white70, size: 28),
                    const SizedBox(width: 14),
                    const Expanded(child: Text('Registrarme con mi email', style: TextStyle(color: Colors.white, fontSize: 16))),
                    const Icon(Icons.chevron_right, color: Colors.white54),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          SocialLoginButton(
            provider: 'Google',
            onPressed: _handleGoogleRegister,
            isLoading: _isGoogleLoading,
          ),
          const SizedBox(height: 12),
          SocialLoginButton(
            provider: 'Facebook',
            onPressed: _handleFacebookRegister,
            isLoading: _isFacebookLoading,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() => _currentStep = 1),
            child: Text('Cambiar tipo de cuenta', style: TextStyle(color: Colors.white.withOpacity(0.8))),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Form(BuildContext context) {
    return LiquidGlassCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LiquidGlassTextField(
              controller: _nameController,
              labelText: 'Nombre completo',
              hintText: 'Tu nombre',
              prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Ingresa tu nombre';
                return null;
              },
            ),
            const SizedBox(height: 16),
            LiquidGlassTextField(
                                    controller: _emailController,
                                    labelText: 'Email',
                                    hintText: 'tu@email.com',
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                      color: Colors.white70,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingresa tu email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Email inválido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Phone Field
                                  LiquidGlassTextField(
                                    controller: _phoneController,
                                    labelText: 'Teléfono (opcional)',
                                    hintText: '+52 123 456 7890',
                                    keyboardType: TextInputType.phone,
                                    prefixIcon: const Icon(
                                      Icons.phone_outlined,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Rol elegido en paso 1
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        Icon(Icons.badge_outlined, color: Colors.white.withOpacity(0.7), size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Registrarte como: ${_selectedRole == 'cliente' ? 'Cliente' : _selectedRole == 'prestador' ? 'Prestador' : 'Tienda'}',
                                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                                        ),
                                        const Spacer(),
                                        TextButton(
                                          onPressed: () => setState(() => _currentStep = 1),
                                          child: Text('Cambiar', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Password Field
                                  LiquidGlassTextField(
                                    controller: _passwordController,
                                    labelText: 'Contraseña',
                                    hintText: '••••••••',
                                    obscureText: _obscurePassword,
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      color: Colors.white70,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                      onPressed: () {
                                        setState(() => _obscurePassword = !_obscurePassword);
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingresa tu contraseña';
                                      }
                                      if (value.length < 6) {
                                        return 'Mínimo 6 caracteres';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Confirm Password Field
                                  LiquidGlassTextField(
                                    controller: _confirmPasswordController,
                                    labelText: 'Confirmar Contraseña',
                                    hintText: '••••••••',
                                    obscureText: _obscureConfirmPassword,
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      color: Colors.white70,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                      onPressed: () {
                                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Confirma tu contraseña';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Las contraseñas no coinciden';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  GradientButton(
                                    onPressed: _handleRegister,
                                    text: 'Crear Cuenta',
                                    isLoading: _isLoading,
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: () => setState(() => _currentStep = 2),
                                    child: Text('Regresar', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '¿Ya tienes cuenta? ',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => context.pop(),
                                        child: Text(
                                          'Inicia Sesión',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.95),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
    );
  }
}
