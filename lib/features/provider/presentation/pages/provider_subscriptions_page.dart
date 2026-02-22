import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/tropical_scaffold.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/repositories/provider_repository.dart';
import '../../domain/entities/subscription.dart';

class ProviderSubscriptionsPage extends StatefulWidget {
  const ProviderSubscriptionsPage({super.key});

  @override
  State<ProviderSubscriptionsPage> createState() =>
      _ProviderSubscriptionsPageState();
}

class _ProviderSubscriptionsPageState extends State<ProviderSubscriptionsPage> {
  final _providerRepo = ProviderRepository();
  Subscription? currentSubscription;
  bool isLoading = true;

  final List<Map<String, dynamic>> availablePlans = [
    {
      'id': 'WEEKLY',
      'name': 'Semanal',
      'price': 150.0,
      'period': '7 días',
      'features': [
        'Acceso a solicitudes express',
        'Comisión del 15%',
        'Soporte prioritario',
        'Máximo 30 servicios',
      ],
      'color': Colors.blue,
      'icon': Icons.calendar_view_week,
    },
    {
      'id': 'MONTHLY',
      'name': 'Mensual',
      'price': 500.0,
      'period': '30 días',
      'features': [
        'Acceso a solicitudes express',
        'Comisión del 12%',
        'Soporte prioritario',
        'Servicios ilimitados',
        'Estadísticas avanzadas',
      ],
      'color': Colors.purple,
      'icon': Icons.calendar_month,
      'recommended': true,
    },
    {
      'id': 'QUARTERLY',
      'name': 'Trimestral',
      'price': 1200.0,
      'period': '90 días',
      'features': [
        'Acceso a solicitudes express',
        'Comisión del 10%',
        'Soporte prioritario 24/7',
        'Servicios ilimitados',
        'Estadísticas avanzadas',
        'Sin penalizaciones',
      ],
      'color': Colors.amber,
      'icon': Icons.calendar_today,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentSubscription();
  }

  Future<void> _loadCurrentSubscription() async {
    try {
      final subscription = await _providerRepo.getCurrentSubscription();
      if (mounted) {
        setState(() {
          currentSubscription = subscription;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading subscription: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _subscribeToPlan(String planId) async {
    try {
      // TODO: Implement payment flow
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Procesando suscripción al plan $planId...'),
          backgroundColor: Colors.blue,
        ),
      );
      // After payment success:
      // await _providerRepo.subscribeToplan(planId);
      // _loadCurrentSubscription();
    } catch (e) {
      debugPrint('Error subscribing: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al procesar suscripción'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TropicalScaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade600,
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Suscripciones',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Elige el plan perfecto para ti',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (currentSubscription != null &&
                    currentSubscription!.isActive)
                  _buildCurrentSubscriptionCard()
                else
                  _buildNoSubscriptionCard(),
                const SizedBox(height: 24),
                const Text(
                  'Planes Disponibles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...availablePlans.map((plan) => _buildPlanCard(plan)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSubscriptionCard() {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade600,
            Colors.green.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Suscripción Activa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPlanName(currentSubscription!.planType),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Vence: ${currentSubscription!.endDate != null ? dateFormat.format(currentSubscription!.endDate!) : 'Sin fecha'}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '${currentSubscription!.daysRemaining} días restantes',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (currentSubscription!.isExpiringSoon) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tu suscripción está por vencer',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to manage subscription
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green.shade800,
              ),
              child: const Text('ADMINISTRAR SUSCRIPCIÓN'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSubscriptionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.slate900,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 48),
          const SizedBox(height: 16),
          const Text(
            'No tienes una suscripción activa',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Activa un plan para empezar a recibir solicitudes y trabajar en tiendas',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final bool isRecommended = plan['recommended'] == true;
    final bool isCurrentPlan =
        currentSubscription?.planType == plan['id'] &&
            (currentSubscription?.isActive ?? false);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.slate900,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRecommended
              ? Colors.amber
              : isCurrentPlan
                  ? Colors.green
                  : Colors.white.withOpacity(0.1),
          width: isRecommended || isCurrentPlan ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      plan['icon'] as IconData,
                      color: plan['color'] as Color,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            plan['period'],
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormat.format(plan['price']),
                          style: TextStyle(
                            color: plan['color'] as Color,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...(plan['features'] as List<String>).map((feature) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: plan['color'] as Color,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan
                        ? null
                        : () => _subscribeToPlan(plan['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentPlan
                          ? Colors.grey
                          : plan['color'] as Color,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade800,
                      disabledForegroundColor: Colors.white54,
                    ),
                    child: Text(
                      isCurrentPlan ? 'PLAN ACTUAL' : 'SUSCRIBIRSE',
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isRecommended)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'RECOMENDADO',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getPlanName(String planType) {
    switch (planType) {
      case 'WEEKLY':
        return 'Semanal';
      case 'MONTHLY':
        return 'Mensual';
      case 'QUARTERLY':
        return 'Trimestral';
      default:
        return planType;
    }
  }
}
