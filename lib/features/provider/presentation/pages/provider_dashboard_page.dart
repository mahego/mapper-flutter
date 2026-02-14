import 'package:flutter/material.dart';
import '../../../../core/widgets/tropical_scaffold.dart';
import '../../../../core/theme/app_theme.dart';

class ProviderDashboardPage extends StatefulWidget {
  const ProviderDashboardPage({super.key});

  @override
  State<ProviderDashboardPage> createState() => _ProviderDashboardPageState();
}

class _ProviderDashboardPageState extends State<ProviderDashboardPage> {
  bool isOnline = false;

  @override
  Widget build(BuildContext context) {
    return TropicalScaffold(
      body: CustomScrollView(
        slivers: [
          // Header / Status
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
              title: Row(
                children: [
                   Container(
                    width: 12, 
                    height: 12, 
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.greenAccent : Colors.redAccent, 
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isOnline ? Colors.greenAccent : Colors.redAccent).withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isOnline ? 'En Línea' : 'Desconectado',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            actions: [
              Switch(
                value: isOnline, 
                onChanged: (val) {
                  setState(() {
                    isOnline = val;
                  });
                },
                activeColor: Colors.greenAccent,
                activeTrackColor: Colors.green.withOpacity(0.4),
                inactiveThumbColor: Colors.redAccent,
                inactiveTrackColor: Colors.red.withOpacity(0.4),
              ),
              const SizedBox(width: 16),
            ],
          ),

          // Stats Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Ganancias hoy',
                      value: '\$850.00',
                      icon: Icons.attach_money,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      label: 'Viajes',
                      value: '12',
                      icon: Icons.motorcycle,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Active Assignment (if any)
          if (isOnline)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primary600, AppTheme.primary500],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary500.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Viaje en curso',
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.store, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Burger King Centro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                const Text('Recoger pedido #1234', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 1, width: double.infinity, child: ColoredBox(color: Colors.white24)),
                      const SizedBox(height: 16),
                       Row(
                        children: [
                          const Icon(Icons.person, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Juan Pérez', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                const Text('Calle 5 de Mayo #45', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primary600,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('VER DETALLES'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Incoming Requests List
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Solicitudes Disponibles',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
            ),
          ),
          
          if (!isOnline)
             SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.cloud_off, size: 60, color: Colors.white24),
                      SizedBox(height: 16),
                      Text(
                        'Conéctate para recibir solicitudes',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else 
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _RequestCard(index: index);
                },
                childCount: 3,
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.slate800.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final int index;

  const _RequestCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.slate900,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Mandadito', style: TextStyle(color: Colors.orange, fontSize: 12)),
              ),
              const Text('\$45.00', style: TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.my_location, color: Colors.blue, size: 16),
              const SizedBox(width: 8),
              const Expanded(child: Text('Origen: Av. Reforma 222', style: TextStyle(color: Colors.white70))),
            ],
          ),
          Container(
             margin: const EdgeInsets.only(left: 7),
             height: 20,
             width: 2,
             color: Colors.white10,
          ),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              const Expanded(child: Text('Destino: Colonia Centro #10', style: TextStyle(color: Colors.white70))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                  ),
                  child: const Text('Rechazar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Aceptar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
