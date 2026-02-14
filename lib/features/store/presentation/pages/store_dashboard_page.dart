import 'package:flutter/material.dart';
import '../../../../core/widgets/tropical_scaffold.dart';
import '../../../../core/theme/app_theme.dart';

class StoreDashboardPage extends StatefulWidget {
  const StoreDashboardPage({super.key});

  @override
  State<StoreDashboardPage> createState() => _StoreDashboardPageState();
}

class _StoreDashboardPageState extends State<StoreDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TropicalScaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              title: const Text('Mi Tienda'),
              centerTitle: false,
              actions: [
                Switch(
                  value: true, 
                  onChanged: (val) {},
                  activeColor: Colors.greenAccent,
                ),
                const SizedBox(width: 8),
                const Chip(
                  label: Text('Abierto', style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 16),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.accent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                tabs: const [
                  Tab(icon: Icon(Icons.point_of_sale), text: 'POS'),
                  Tab(icon: Icon(Icons.list_alt), text: 'Pedidos'),
                  Tab(icon: Icon(Icons.inventory_2), text: 'Catálogo'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _POSView(),
            _OrdersView(),
            _CatalogView(),
          ],
        ),
      ),
    );
  }
}

class _POSView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Product Grid (Left)
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          child: const Icon(Icons.fastfood, color: Colors.white24, size: 40),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Producto ${index + 1}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const Text('\$150.00', style: TextStyle(color: AppTheme.accent)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        // Cart Summary (Right - narrower)
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppTheme.slate900.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Carrito', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const Divider(color: Colors.white10),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.white24),
                        SizedBox(height: 8),
                        Text('Vacío', style: TextStyle(color: Colors.white38)),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black26,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Total:', style: TextStyle(color: Colors.white)),
                          Text('\$0.00', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('COBRAR'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OrdersView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.white10),
              borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: index % 2 == 0 ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
              child: Icon(
                index % 2 == 0 ? Icons.soup_kitchen : Icons.check,
                color: index % 2 == 0 ? Colors.orange : Colors.green,
              ),
            ),
            title: Text('Pedido #${1020 + index}', style: const TextStyle(color: Colors.white)),
            subtitle: Text('3 items • \$450.00', style: TextStyle(color: Colors.white70)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
          ),
        );
      },
    );
  }
}

class _CatalogView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
         return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.white10),
              borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, color: Colors.white38),
            ),
            title: Text('Producto Catalogo ${index + 1}', style: const TextStyle(color: Colors.white)),
            subtitle: Text('Stock: ${10 + index}', style: TextStyle(color: Colors.white70)),
            trailing: Switch(value: index % 3 != 0, onChanged: (val){}, activeColor: AppTheme.accent),
          ),
        );
      },
    );
  }
}
