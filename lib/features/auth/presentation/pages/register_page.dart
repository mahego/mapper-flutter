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
                      onPressed: () => context.pop(),
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
                            'Únete a Mapper',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Completa tus datos para comenzar',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Glass Card with Form
                          LiquidGlassCard(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Name Field
                                  LiquidGlassTextField(
                                    controller: _nameController,
                                    labelText: 'Nombre completo',
                                    hintText: 'Tu nombre',
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                      color: Colors.white70,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingresa tu nombre';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Email Field
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

                                  // Role Selector
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.25),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedRole,
                                        isExpanded: true,
                                        dropdownColor: const Color(0xFF1a1a2e),
                                        style: const TextStyle(color: Colors.white),
                                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                                        items: const [
                                          DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
                                          DropdownMenuItem(value: 'prestador', child: Text('Prestador de Servicios')),
                                          DropdownMenuItem(value: 'tienda', child: Text('Tienda / Comercio')),
                                        ],
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() => _selectedRole = value);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

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
                                  const SizedBox(height: 32),

                                  // Register Button
                                  GradientButton(
                                    onPressed: _handleRegister,
                                    text: 'Crear Cuenta',
                                    isLoading: _isLoading,
                                  ),
                                  
                                  // Social Login Divider
                                  const SocialLoginDivider(),
                                  
                                  // Google Button
                                  SocialLoginButton(
                                    provider: 'Google',
                                    onPressed: _handleGoogleRegister,
                                    isLoading: _isGoogleLoading,
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Facebook Button
                                  SocialLoginButton(
                                    provider: 'Facebook',
                                    onPressed: _handleFacebookRegister,
                                    isLoading: _isFacebookLoading,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Login Link
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
