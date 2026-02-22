import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/widgets/liquid_glass_card.dart';
import '../../../../core/widgets/liquid_glass_text_field.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/liquid_glass_snackbar.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.forgotPassword(_emailController.text.trim());

      if (!mounted) return;

      setState(() => _emailSent = true);

      LiquidGlassSnackBar.showSuccess(
        context, 
        'Correo de recuperación enviado a ${_emailController.text}'
      );
    } catch (e) {
      if (!mounted) return;
      LiquidGlassSnackBar.showError(context, 'Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
                      'Recuperar Contraseña',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: _emailSent ? _buildSuccessMessage() : _buildForm(),
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

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon
        Icon(
          Icons.lock_reset_rounded,
          size: 80,
          color: Colors.white,
          shadows: [
            Shadow(
              blurRadius: 30,
              color: const Color(0xFF06b6d4).withOpacity(0.5),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Title
        const Text(
          '¿Olvidaste tu contraseña?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          'Ingresa tu email y te enviaremos un enlace para restablecer tu contraseña.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
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
                const SizedBox(height: 32),

                // Submit Button
                GradientButton(
                  onPressed: _handleForgotPassword,
                  text: 'Enviar Enlace',
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Back to Login
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'Volver a Iniciar Sesión',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        // Glass Card with Success Message
        LiquidGlassCard(
          child: Column(
            children: [
              // Success Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF10b981).withOpacity(0.3),
                      const Color(0xFF10b981).withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 80,
                  color: Color(0xFF10b981),
                ),
              ),
              const SizedBox(height: 32),

              // Success Title
              const Text(
                '¡Correo Enviado!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Revisa tu bandeja de entrada y sigue las instrucciones para restablecer tu contraseña.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),

              // Email
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  _emailController.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Back to Login Button
        GradientButton(
          onPressed: () => context.pop(),
          text: 'Volver a Iniciar Sesión',
        ),
      ],
    );
  }
}
