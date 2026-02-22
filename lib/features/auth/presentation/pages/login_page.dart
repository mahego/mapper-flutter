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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _firebaseAuthService = FirebaseAuthService();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isFacebookLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // Navigate based on role
      switch (user.role) {
        case 'prestador':
          context.go('/provider/dashboard');
          break;
        case 'cliente':
          context.go('/client/dashboard');
          break;
        case 'tienda':
        case 'store':
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

  Future<void> _handleGoogleLogin() async {
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
      
      LiquidGlassSnackBar.showSuccess(context, 'Bienvenido de nuevo');
    } catch (e) {
      if (!mounted) return;
      LiquidGlassSnackBar.showError(
        context,
        'Error al iniciar sesión con Google: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  Future<void> _handleFacebookLogin() async {
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
      
      LiquidGlassSnackBar.showSuccess(context, 'Bienvenido de nuevo');
    } catch (e) {
      if (!mounted) return;
      LiquidGlassSnackBar.showError(
        context,
        'Error al iniciar sesión con Facebook: ${e.toString()}',
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo & Title
                    Icon(
                      Icons.location_on_rounded,
                      size: 90,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 30,
                          color: const Color(0xFF06b6d4).withOpacity(0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Mapper',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 20,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Inicia sesión en tu cuenta',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Glass Card with Form
                    LiquidGlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                            const SizedBox(height: 20),

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
                            const SizedBox(height: 32),

                            // Login Button
                            GradientButton(
                              onPressed: _handleLogin,
                              text: 'Inicia sesión',
                              isLoading: _isLoading,
                            ),
                            
                            // Social Login Divider
                            const SocialLoginDivider(),
                            
                            // Google Button
                            SocialLoginButton(
                              provider: 'Google',
                              onPressed: _handleGoogleLogin,
                              isLoading: _isGoogleLoading,
                            ),
                            const SizedBox(height: 12),
                            
                            // Facebook Button
                            SocialLoginButton(
                              provider: 'Facebook',
                              onPressed: _handleFacebookLogin,
                              isLoading: _isFacebookLoading,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Links
                    Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/auth/forgot-password'),
                      child: Text(
                        'Recupérala aquí',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿No tienes cuenta? ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/auth/register'),
                          child: Text(
                            'Regístrate',
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
      ),
    );
  }
}
