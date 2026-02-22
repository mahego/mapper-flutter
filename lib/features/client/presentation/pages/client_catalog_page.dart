import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/liquid_glass_background.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

/// Catálogo de una tienda para el cliente (ruta /cliente/catalog/:storeId).
/// Carga productos de GET /stores/:storeId/products.
class ClientCatalogPage extends StatefulWidget {
  final String storeId;

  const ClientCatalogPage({super.key, required this.storeId});

  @override
  State<ClientCatalogPage> createState() => _ClientCatalogPageState();
}

class _ClientCatalogPageState extends State<ClientCatalogPage> {
  final _apiClient = ApiClient();
  List<dynamic> _products = [];
  String _storeName = 'Tienda';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final productsRes = await _apiClient.get(ApiEndpoints.storeProductsList(widget.storeId));
      final data = productsRes.data;
      final list = data is Map ? (data['data'] ?? data) : (data is List ? data : []);
      if (mounted) {
        setState(() {
          _products = list is List ? list : [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudo cargar el catálogo.';
          _loading = false;
        });
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
              AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                title: Text('Catálogo', style: TextStyle(color: Colors.white, fontSize: 18)),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF06b6d4)))
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_error!, style: TextStyle(color: Colors.white.withOpacity(0.9))),
                                  const SizedBox(height: 16),
                                  TextButton(onPressed: _load, child: const Text('Reintentar')),
                                ],
                              ),
                            ),
                          )
                        : _products.isEmpty
                            ? Center(
                                child: Text(
                                  'Esta tienda no tiene productos publicados.',
                                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: _products.length,
                                itemBuilder: (context, i) {
                                  final p = _products[i] as Map<String, dynamic>;
                                  final name = p['name'] ?? p['title'] ?? 'Producto';
                                  final price = p['price'] ?? p['unitPrice'] ?? 0;
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    color: Colors.white.withOpacity(0.08),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(color: Colors.white.withOpacity(0.12)),
                                    ),
                                    child: ListTile(
                                      title: Text(name, style: const TextStyle(color: Colors.white)),
                                      subtitle: Text(
                                        '\$${price.toStringAsFixed(2)}',
                                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
