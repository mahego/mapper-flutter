import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/tropical_scaffold.dart';
import '../../../../core/widgets/store_bottom_nav.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/barcode_scanner_service.dart';
import '../../../../core/services/firebase_storage_service.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/store_repository.dart';
import '../../domain/entities/store_product.dart';
import '../widgets/product_card.dart';

class StoreCatalogPage extends StatefulWidget {
  const StoreCatalogPage({super.key});

  @override
  State<StoreCatalogPage> createState() => _StoreCatalogPageState();
}

class _StoreCatalogPageState extends State<StoreCatalogPage> {
  final _apiClient = ApiClient();
  late final ProductRepository _productRepository;
  late final StoreRepository _storeRepository;
  final _storageService = FirebaseStorageService();

  List<StoreProduct> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _productRepository = ProductRepository(_apiClient);
    _storeRepository = StoreRepository(_apiClient);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _productRepository.getProducts();
      setState(() {
        _products = products;
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

  Future<void> _showProductDialog({StoreProduct? product}) async {
    final nameController = TextEditingController(text: product?.name ?? '');
    final descriptionController = TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final stockController = TextEditingController(text: product?.stock.toString() ?? '');
    final categoryController = TextEditingController(text: product?.category ?? '');
    final barcodeController = TextEditingController(text: product?.barcode ?? '');

    XFile? pickedImage;
    Uint8List? pickedImageBytes;

    void unfocus() => FocusScope.of(context).unfocus();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return GestureDetector(
            onTap: unfocus,
            behavior: HitTestBehavior.opaque,
            child: AlertDialog(
              title: Text(product == null ? 'Nuevo Producto' : 'Editar Producto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Foto: actual o previsualización; un solo Guardar guarda todo (incl. foto)
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: pickedImageBytes != null
                              ? Image.memory(
                                  pickedImageBytes!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildImagePlaceholder(80),
                                )
                              : (product?.imageUrl != null && pickedImage == null
                                  ? Image.network(
                                      product!.imageUrl!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(80),
                                    )
                                  : _buildImagePlaceholder(80)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Imagen del producto',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextButton.icon(
                              onPressed: () async {
                                final picker = ImagePicker();
                                final x = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 800,
                                  imageQuality: 85,
                                );
                                if (x != null) {
                                  final bytes = await x.readAsBytes();
                                  setDialogState(() {
                                    pickedImage = x;
                                    pickedImageBytes = bytes;
                                  });
                                }
                              },
                              icon: const Icon(Icons.add_photo_alternate, size: 20),
                              label: const Text('Elegir imagen'),
                            ),
                            if (pickedImage != null || product?.imageUrl != null)
                              TextButton.icon(
                                onPressed: () => setDialogState(() {
                                  pickedImage = null;
                                  pickedImageBytes = null;
                                }),
                                icon: const Icon(Icons.clear, size: 18),
                                label: const Text('Quitar'),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => unfocus(),
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => unfocus(),
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => unfocus(),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stockController,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => unfocus(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: categoryController,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => unfocus(),
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: barcodeController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => unfocus(),
                      decoration: InputDecoration(
                        labelText: 'Código de Barras',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(AppIcons.qrCodeScanner),
                          onPressed: () async {
                            final code = await BarcodeScannerService.scanBarcode(context);
                            if (code != null) {
                              barcodeController.text = code;
                              final lookedUp = await _productRepository.lookupByBarcode(code);
                              if (lookedUp != null && nameController.text.isEmpty) {
                                nameController.text = lookedUp.name;
                                descriptionController.text = lookedUp.description ?? '';
                                priceController.text = lookedUp.price.toString();
                                categoryController.text = lookedUp.category ?? '';
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06b6d4),
                  ),
                  child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (result == true) {
      try {
        String? imageUrl = product?.imageUrl;
        if (pickedImage != null) {
          final storeId = product?.storeId.toString() ?? (await _storeRepository.getMyStore()).id.toString();
          imageUrl = await _storageService.uploadProductImage(
            file: pickedImage!,
            storeId: storeId,
            productName: nameController.text.trim().isEmpty ? 'producto' : nameController.text.trim(),
          );
        }

        final data = <String, dynamic>{
          'name': nameController.text,
          'description': descriptionController.text,
          'price': double.tryParse(priceController.text) ?? 0,
          'stock': int.tryParse(stockController.text) ?? 0,
          'category': categoryController.text,
          if (barcodeController.text.isNotEmpty) 'barcode': barcodeController.text,
          if (imageUrl != null) 'imageUrl': imageUrl,
        };

        if (product == null) {
          await _productRepository.createProduct(data);
        } else {
          await _productRepository.updateProduct(product.id, data);
        }

        _loadProducts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(product == null ? 'Producto creado' : 'Producto actualizado')),
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
  }

  Widget _buildImagePlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[300],
      child: Icon(Icons.image, size: size * 0.5, color: Colors.grey[600]),
    );
  }

  Future<void> _deleteProduct(StoreProduct product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _productRepository.deleteProduct(product.id);
        _loadProducts();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto eliminado')),
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
  }

  @override
  Widget build(BuildContext context) {
    return TropicalScaffold(
      body: Column(
        children: [
          // Header sin buscador: un solo buscador en el flujo tienda (en POS)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Catálogo de productos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0f172a),
                    ),
                  ),
                ),
                FloatingActionButton(
                  onPressed: () => _showProductDialog(),
                  backgroundColor: const Color(0xFF06b6d4),
                  child: const Icon(AppIcons.add, color: Colors.white),
                ),
              ],
            ),
          ),
          // Products List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay productos',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ProductCard(
                                product: product,
                                onEdit: () => _showProductDialog(product: product),
                                onDelete: () => _deleteProduct(product),
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
}
