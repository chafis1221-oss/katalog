import 'package:flutter/material.dart';
import 'package:katalog/models/product.dart';
import 'package:katalog/services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _searchSuggestion;

  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get searchSuggestion => _searchSuggestion;

  /// Ambil semua produk dari API
  Future<void> fetchAllProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _apiService.getAllProducts();
      _filteredProducts = _products;
    } catch (e) {
      _errorMessage = e.toString();
      _filteredProducts = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Cari produk (prefix + anti-typo)
  Future<void> searchProducts(String keyword) async {
    if (keyword.trim().isEmpty) {
      _filteredProducts = _products;
      _searchSuggestion = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.searchProducts(keyword);
      _filteredProducts = result['data'] ?? [];
      _searchSuggestion = result['suggestion'];
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Reset filter ke semua produk
  void resetSearch() {
    _filteredProducts = _products;
    _searchSuggestion = null;
    notifyListeners();
  }

  /// Hapus error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}