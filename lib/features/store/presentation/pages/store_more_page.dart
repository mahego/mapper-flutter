import 'package:flutter/material.dart';
import '../../../../core/widgets/tropical_scaffold.dart';
import '../../../../core/widgets/store_bottom_nav.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/repositories/store_repository.dart';
import '../../domain/entities/store_profile.dart';
import '../../domain/entities/store_metrics.dart';
import '../widgets/metric_card.dart';

class StoreMorePage extends StatefulWidget {
  const StoreMorePage({super.key});

  @override
  State<StoreMorePage> createState() => _StoreMorePageState();
}

class _StoreMorePageState extends State<StoreMorePage> {
  final _apiClient = ApiClient();
  late final StoreRepository _storeRepository;
  
  StoreProfile? _profile;
  StoreMetrics? _metrics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _storeRepository = StoreRepository(_apiClient);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _storeRepository.getMyStore();
      final metrics = await _storeRepository.getMetrics();
      setState(() {
        _profile = profile;
        _metrics = metrics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TropicalScaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store Info
                    Card(
                      elevation: 2,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF06b6d4).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.store,
                                    color: Color(0xFF06b6d4),
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _profile?.name ?? 'Mi Tienda',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0f172a),
                                        ),
                                      ),
                                      if (_profile?.address != null)
                                        Text(
                                          _profile!.address!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (_profile?.phone != null || _profile?.email != null) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 16),
                              if (_profile?.phone != null)
                                Row(
                                  children: [
                                    const Icon(Icons.phone, size: 18, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(_profile!.phone!),
                                  ],
                                ),
                              if (_profile?.email != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.email, size: 18, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(_profile!.email!),
                                  ],
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Metrics Section
                    const Text(
                      'Métricas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_metrics != null) ...[
                      // Today Metrics
                      const Text(
                        'Hoy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              title: 'Ventas',
                              value: _metrics!.salesToday,
                              icon: Icons.attach_money,
                              color: Colors.green,
                              isCurrency: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MetricCard(
                              title: 'Pedidos',
                              value: _metrics!.ordersCompletedToday.toDouble(),
                              icon: Icons.shopping_bag,
                              color: const Color(0xFF06b6d4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Month Metrics
                      const Text(
                        'Este Mes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              title: 'Ventas',
                              value: _metrics!.salesMonth,
                              icon: Icons.trending_up,
                              color: Colors.green,
                              isCurrency: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MetricCard(
                              title: 'Pedidos',
                              value: _metrics!.ordersCompletedMonth.toDouble(),
                              icon: Icons.list_alt,
                              color: const Color(0xFF06b6d4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              title: 'Ticket Promedio',
                              value: _metrics!.avgTicket,
                              icon: Icons.receipt_long,
                              color: Colors.purple,
                              isCurrency: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MetricCard(
                              title: 'Efectivo Pendiente',
                              value: _metrics!.cashPending,
                              icon: Icons.money,
                              color: Colors.orange,
                              isCurrency: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Quick Actions
                    const Text(
                      'Acciones',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      'Reportes',
                      'Ver reportes de ventas',
                      Icons.assessment,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Próximamente: Reportes')),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      'Configuración',
                      'Configurar tienda',
                      Icons.settings,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Próximamente: Configuración')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const StoreBottomNav(currentIndex: 3),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF06b6d4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF06b6d4),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF0f172a),
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
