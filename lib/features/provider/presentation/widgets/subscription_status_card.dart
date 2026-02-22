import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/subscription.dart';

class SubscriptionStatusCard extends StatelessWidget {
  final Subscription? subscription;
  final bool isLoading;
  final VoidCallback? onManageSubscription;

  const SubscriptionStatusCard({
    super.key,
    this.subscription,
    this.isLoading = false,
    this.onManageSubscription,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingCard();
    }

    if (subscription == null || !subscription!.isActive) {
      return _buildInactiveCard();
    }

    return _buildActiveCard();
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.slate800.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildInactiveCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
              SizedBox(width: 8),
              Text(
                'Suscripción Inactiva',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Necesitas una suscripción activa para recibir solicitudes',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          if (onManageSubscription != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onManageSubscription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Activar Suscripción'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveCard() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isExpiringSoon = subscription!.isExpiringSoon;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isExpiringSoon 
            ? Colors.orange.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpiringSoon 
              ? Colors.orange.withOpacity(0.3)
              : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isExpiringSoon ? Icons.access_time : Icons.check_circle,
                color: isExpiringSoon ? Colors.orangeAccent : Colors.greenAccent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                _getPlanName(subscription!.planType),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vence el:',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  Text(
                    dateFormat.format(subscription!.endDate!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Días restantes:',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  Text(
                    '${subscription!.daysRemaining}',
                    style: TextStyle(
                      color: isExpiringSoon ? Colors.orangeAccent : Colors.greenAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (onManageSubscription != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onManageSubscription,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                ),
                child: const Text('Gestionar Suscripción'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getPlanName(String planType) {
    switch (planType) {
      case 'monthly':
        return 'Plan Mensual';
      case 'annual':
        return 'Plan Anual';
      case 'quarterly':
        return 'Plan Trimestral';
      default:
        return 'Suscripción Activa';
    }
  }
}
