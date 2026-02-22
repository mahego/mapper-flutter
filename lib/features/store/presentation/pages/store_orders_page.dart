import 'package:flutter/material.dart';
import '../../../../core/widgets/tropical_scaffold.dart';
import '../../../../core/widgets/store_bottom_nav.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/entities/store_order.dart';
import '../widgets/order_card.dart';
import 'package:intl/intl.dart';

class StoreOrdersPage extends StatefulWidget {
  const StoreOrdersPage({super.key});

  @override
  State<StoreOrdersPage> createState() => _StoreOrdersPageState();
}

class _StoreOrdersPageState extends State<StoreOrdersPage> {
  final _apiClient = ApiClient();
  late final OrderRepository _orderRepository;
  
  List<StoreOrder> _orders = [];
  bool _isLoading = true;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _orderRepository = OrderRepository(_apiClient);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _orderRepository.getOrders();
      setState(() {
        _orders = orders;
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

  Future<void> _showOrderDetail(StoreOrder order) async {
    final formatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 2);
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pedido #${order.id}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Cliente', order.clientName),
              _buildDetailRow('Fecha', dateFormatter.format(order.createdAt)),
              _buildDetailRow('Estado', order.status),
              if (order.paymentMethod != null)
                _buildDetailRow('Método de Pago', order.paymentMethod!),
              const SizedBox(height: 16),
              const Text(
                'Items',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('${item.productName} x${item.quantity}'),
                    ),
                    Text(
                      formatter.format(item.subtotal),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formatter.format(order.total),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF06b6d4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          if (order.status.toLowerCase() == 'pending' || 
              order.status.toLowerCase() == 'pendiente')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateOrderStatus(order, 'completed');
              },
              child: const Text('Marcar como Completado'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(StoreOrder order, String status) async {
    try {
      await _orderRepository.updateOrderStatus(order.id, status);
      _loadOrders();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estado actualizado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  List<StoreOrder> _getFilteredOrders() {
    if (_filterStatus == 'all') return _orders;
    return _orders.where((o) => 
      o.status.toLowerCase() == _filterStatus.toLowerCase()
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _getFilteredOrders();

    return TropicalScaffold(
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todos', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pendientes', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('En Proceso', 'in_progress'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completados', 'completed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cancelados', 'cancelled'),
                ],
              ),
            ),
          ),
          // Orders List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOrders.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay pedidos',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: OrderCard(
                                order: order,
                                onTap: () => _showOrderDetail(order),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String status) {
    final isSelected = _filterStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = status;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF06b6d4),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      checkmarkColor: Colors.white,
    );
  }
}
