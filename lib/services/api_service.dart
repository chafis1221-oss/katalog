import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:katalog/config/api_config.dart';
import 'package:katalog/models/product.dart';

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;
  final String imageBaseUrl = ApiConfig.imageBaseUrl;
  final int timeout = ApiConfig.requestTimeout;

  // ============================================
  // PRODUK
  // ============================================

  /// Ambil semua produk
  Future<List<Product>> getAllProducts() async {
    final response = await http
        .get(Uri.parse(ApiConfig.productsUrl))
        .timeout(Duration(seconds: timeout));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List products = data['data'];
        return products.map((p) => Product.fromJson(p)).toList();
      }
      throw Exception(data['message'] ?? 'Gagal mengambil produk');
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  /// Cari produk (prefix + anti-typo)
  Future<Map<String, dynamic>> searchProducts(String keyword) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.searchProductsUrl}?q=$keyword'))
        .timeout(Duration(seconds: timeout));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List products = data['data'] ?? [];
        return {
          'data': products.map((p) => Product.fromJson(p)).toList(),
          'suggestion': data['suggestion'],
        };
      }
      throw Exception(data['message'] ?? 'Gagal mencari produk');
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  /// Ambil satu produk berdasarkan ID
  Future<Product> getProductById(int id) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.productsUrl}/$id'))
        .timeout(Duration(seconds: timeout));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return Product.fromJson(data['data']);
      }
      throw Exception(data['message'] ?? 'Produk tidak ditemukan');
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  /// Buat produk baru
  Future<Product> createProduct(Map<String, dynamic> productData) async {
    final response = await http
        .post(
          Uri.parse(ApiConfig.productsUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(productData),
        )
        .timeout(Duration(seconds: timeout));

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return Product.fromJson(data['data']);
      }
      throw Exception(data['message'] ?? 'Gagal membuat produk');
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  /// Update produk
  Future<Product> updateProduct(int id, Map<String, dynamic> data) async {
    final response = await http
        .put(
          Uri.parse('${ApiConfig.productsUrl}/$id'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        )
        .timeout(Duration(seconds: timeout));

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        return Product.fromJson(result['data']);
      }
      throw Exception(result['message'] ?? 'Gagal mengupdate produk');
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  /// Hapus produk
  Future<void> deleteProduct(int id) async {
    final response = await http
        .delete(Uri.parse('${ApiConfig.productsUrl}/$id'))
        .timeout(Duration(seconds: timeout));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) return;
      throw Exception(data['message'] ?? 'Gagal menghapus produk');
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  // ============================================
  // UPLOAD GAMBAR (langsung ke Panel Jelek)
  // ============================================

  /// Upload gambar ke Panel Jelek, return URL
  Future<String> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.uploadImageUrl),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse =
          await request.send().timeout(Duration(seconds: timeout));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['image_url'];
        }
        throw Exception(data['message'] ?? 'Gagal upload gambar');
      }
      throw Exception('Server error: ${response.statusCode}');
    } catch (e) {
      throw Exception('Gagal upload gambar: $e');
    }
  }

  // ============================================
  // KERANJANG (validasi)
  // ============================================

  /// Validasi isi keranjang
  Future<Map<String, dynamic>> validateCart(List<Map<String, dynamic>> items) async {
    final response = await http
        .post(
          Uri.parse(ApiConfig.validateCartUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'items': items}),
        )
        .timeout(Duration(seconds: timeout));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['data'];
      }
      throw Exception(data['message'] ?? 'Validasi keranjang gagal');
    }
    throw Exception('Server error: ${response.statusCode}');
  }
}