import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:katalog/models/product.dart';
import 'package:katalog/services/api_service.dart';
import 'package:katalog/providers/cart_provider.dart';
import 'package:katalog/screens/product_form_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ApiService _apiService = ApiService();
  Product? _product;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final product = await _apiService.getProductById(widget.productId);
      if (!mounted) return;
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleStatus() async {
    if (_product == null) return;
    try {
      await _apiService.updateProduct(
        _product!.id,
        {
          'name': _product!.name,
          'description': _product!.description ?? '',
          'price': _product!.price,
          'image_url': _product!.imageUrl,
          'is_available': !_product!.isAvailable,
        },
      );
      if (!mounted) return;
      _loadProduct();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "${_product!.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true && _product != null) {
      try {
        await _apiService.deleteProduct(_product!.id);
        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal hapus: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_product?.name ?? 'Detail Produk'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _product == null ? null : () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => ProductFormScreen(product: _product),
            )).then((_) => _loadProduct());
          }),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: _deleteProduct),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _product == null
                  ? const Center(child: Text('Produk tidak ditemukan'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _product!.imageUrl != null
                                ? CachedNetworkImage(imageUrl: _product!.imageUrl!, height: 250, fit: BoxFit.cover)
                                : Container(height: 250, color: Colors.grey[300], child: const Icon(Icons.image_not_supported, size: 80)),
                          ),
                          const SizedBox(height: 16),
                          Text(_product!.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(priceFormat.format(_product!.price), style: TextStyle(fontSize: 22, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 16),
                          if (_product!.description != null && _product!.description!.isNotEmpty) ...[
                            const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(_product!.description!),
                            const SizedBox(height: 16),
                          ],
                          SwitchListTile(
                            title: const Text('Produk Tersedia'),
                            value: _product!.isAvailable,
                            onChanged: (_) => _toggleStatus(),
                            activeColor: Colors.green,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _product!.isAvailable
                                ? () {
                                    cart.addItem(_product!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${_product!.name} ditambahkan ke keranjang')),
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Tambah ke Keranjang'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
