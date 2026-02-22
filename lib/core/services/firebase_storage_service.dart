import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Subida de imágenes a Firebase Storage (paridad con Angular FirebaseStorageService).
class FirebaseStorageService {
  static const String _storesPath = 'stores';

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Sube una imagen de producto y devuelve la URL de descarga.
  /// [file] XFile desde image_picker.
  /// [storeId] ID de la tienda.
  /// [productName] se usa para sanitizar el nombre del archivo.
  Future<String> uploadProductImage({
    required XFile file,
    required String storeId,
    required String productName,
  }) async {
    final bytes = await file.readAsBytes();
    final extension = _getExtension(file.name);
    final sanitizedName = _sanitizeFileName(productName);
    final fileName = '${sanitizedName}-${DateTime.now().millisecondsSinceEpoch}.$extension';
    final path = '$_storesPath/$storeId/products/$fileName';

    final ref = _storage.ref().child(path);
    await ref.putData(
      bytes,
      SettableMetadata(contentType: _mimeType(extension)),
    );
    return ref.getDownloadURL();
  }

  String _getExtension(String name) {
    final ext = name.split('.').last.toLowerCase();
    return ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'webp' || ext == 'gif' ? ext : 'jpg';
  }

  String _mimeType(String ext) {
    switch (ext) {
      case 'png': return 'image/png';
      case 'gif': return 'image/gif';
      case 'webp': return 'image/webp';
      default: return 'image/jpeg';
    }
  }

  String _sanitizeFileName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäåāăą]'), 'a')
        .replaceAll(RegExp(r'[èéêëēė]'), 'e')
        .replaceAll(RegExp(r'[ìíîïī]'), 'i')
        .replaceAll(RegExp(r'[òóôõöō]'), 'o')
        .replaceAll(RegExp(r'[ùúûüū]'), 'u')
        .replaceAll(RegExp(r'[^a-z0-9]'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}
