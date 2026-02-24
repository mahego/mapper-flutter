import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/widgets/liquid_glass_card.dart';
import '../../../../core/widgets/liquid_glass_text_field.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/liquid_glass_snackbar.dart';
import '../../../../core/services/storage_service.dart';

/// Pantalla de pago POS por QR: el cliente escaneó el QR en tienda,
/// ve monto y tienda, puede asociar su teléfono y confirmar pago.
/// Requiere estar logueado para pagar.
class PosPayPage extends StatefulWidget {
  final String sessionId;

  const PosPayPage({super.key, required this.sessionId});

  @override
  State<PosPayPage> createState() => _PosPayPageState();
}

class _PosPayPageState extends State<PosPayPage> {
  final _apiClient = ApiClient();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();

  bool _loading = true;
  bool _paying = false;
  String? _error;
  String? _storeName;
  double? _chargePesos;
  String? _status;
  String? _checkoutUrl;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadSession() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final path = ApiEndpoints.posPaymentSession(widget.sessionId);
      final response = await _apiClient.get(path, skipAuth: true);
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        setState(() {
          _loading = false;
          _error = 'Respuesta inválida';
        });
        return;
      }
      final payload = data['data'] as Map<String, dynamic>? ?? data;
      final status = payload['status'] as String?;
      if (status != 'pending') {
        setState(() {
          _loading = false;
          _error = status == 'completed' ? 'Esta sesión ya fue pagada.' : 'Sesión no disponible.';
        });
        return;
      }
      final chargeCents = payload['chargeCents'];
      final chargePesos = payload['chargePesos'];
      final checkoutUrl = payload['checkoutUrl'] as String?;
      setState(() {
        _loading = false;
        _storeName = payload['storeName'] as String? ?? 'Tienda';
        _chargePesos = chargePesos is num ? chargePesos.toDouble() : (chargeCents is num ? (chargeCents / 100).toDouble() : null);
        _status = status;
        _checkoutUrl = checkoutUrl;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'No se pudo cargar la sesión. Revisa el enlace o intenta de nuevo.';
      });
    }
  }

  Future<void> _pay() async {
    if (_chargePesos == null || _chargePesos! <= 0) return;

    if (_checkoutUrl != null && _checkoutUrl!.isNotEmpty) {
      await _openConektaCheckout();
      return;
    }

    final token = await StorageService().getTokenAsync();
    if (token == null || token.isEmpty) {
      LiquidGlassSnackBar.showError(context, 'Inicia sesión para pagar.');
      context.go('/login');
      return;
    }
    setState(() => _paying = true);
    try {
      final path = ApiEndpoints.posPaymentConfirm(widget.sessionId);
      await _apiClient.post(path, data: {
        if (_phoneController.text.trim().isNotEmpty) 'clientPhone': _phoneController.text.trim(),
        if (_nameController.text.trim().isNotEmpty) 'clientName': _nameController.text.trim(),
      });
      if (!mounted) return;
      LiquidGlassSnackBar.showSuccess(context, 'Pago realizado. La tienda recibió el monto.');
      context.go('/dashboard/cliente');
    } catch (e) {
      if (!mounted) return;
      LiquidGlassSnackBar.showError(context, 'Error al procesar el pago. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  Future<void> _openConektaCheckout() async {
    final url = _checkoutUrl;
    if (url == null || url.isEmpty) return;
    setState(() => _paying = true);
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!mounted) return;
        LiquidGlassSnackBar.showSuccess(context, 'Completa el pago en el navegador. Al terminar volverás aquí.');
        context.go('/dashboard/cliente');
      } else {
        LiquidGlassSnackBar.showError(context, 'No se pudo abrir la página de pago.');
      }
    } catch (e) {
      if (mounted) LiquidGlassSnackBar.showError(context, 'Error al abrir el pago.');
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidGlassBackground(
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF06b6d4)))
              : _error != null
                  ? _buildError()
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: LiquidGlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 20),
            GradientButton(
              onPressed: () => context.go('/'),
              text: 'Volver',
              variant: GradientButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final chargePesos = _chargePesos ?? 0.0;
    final chargeStr = chargePesos.toStringAsFixed(2);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            'Pagar en tienda',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _storeName ?? 'Tienda',
            style: const TextStyle(color: Color(0xFF06b6d4), fontSize: 18),
          ),
          const SizedBox(height: 24),
          LiquidGlassCard(
            child: Column(
              children: [
                const Text('Total a pagar', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  '\$$chargeStr MXN',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Asocia tu teléfono a la tienda (opcional)',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          LiquidGlassTextField(
            controller: _phoneController,
            hintText: 'Ej. 55 1234 5678',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          LiquidGlassTextField(
            controller: _nameController,
            hintText: 'Tu nombre (opcional)',
          ),
          const SizedBox(height: 16),
          const Text(
            'Al pagar, podrás vincular tu método de pago y asociar tu número a la base de clientes de la tienda.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 32),
          GradientButton(
            onPressed: _paying ? null : _pay,
            text: _paying ? 'Procesando...' : 'Pagar \$$chargeStr MXN',
            isLoading: _paying,
            icon: Icons.payment,
          ),
        ],
      ),
    );
  }
}
