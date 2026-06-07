import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:katalog/providers/product_provider.dart';
import 'package:katalog/providers/cart_provider.dart';
import 'package:katalog/widgets/product_card.dart';
import 'package:katalog/widgets/search_bar.dart';
import 'package:katalog/screens/product_detail_screen.dart';
import 'package:katalog/screens/product_form_screen.dart';
import 'package:katalog/screens/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warung Digital'),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, __) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              ProductSearchBar(
                onSearch: (keyword) => provider.searchProducts(keyword),
                onClear: () => provider.resetSearch(),
              ),
              if (provider.searchSuggestion != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.amber.withOpacity(0.1),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.searchSuggestion!,
                          style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                const SizedBox(height: 12),
                                Text(provider.errorMessage!),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => provider.fetchAllProducts(),
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          )
                        : provider.products.isEmpty
                            ? const Center(
                                child: Text('Belum ada produk', style: TextStyle(fontSize: 16)),
                              )
                            : RefreshIndicator(
                                onRefresh: () => provider.fetchAllProducts(),
                                child: GridView.builder(
                                  padding: const EdgeInsets.all(12),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.68,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemCount: provider.products.length,
                                  itemBuilder: (context, index) {
                                    final product = provider.products[index];
                                    return ProductCard(
                                      product: product,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ProductDetailScreen(productId: product.id),
                                          ),
                                        ).then((_) {
                                          Future.delayed(const Duration(milliseconds: 500), () {
                                            provider.fetchAllProducts();
                                          });
                                        });
                                      },
                                      onEdit: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ProductFormScreen(product: product),
                                          ),
                                        ).then((result) {
                                          if (result == true) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Produk berhasil diperbarui'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                          Future.delayed(const Duration(milliseconds: 500), () {
                                            provider.fetchAllProducts();
                                          });
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          ).then((result) {
            if (result == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Produk berhasil ditambahkan'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            Future.delayed(const Duration(milliseconds: 500), () {
              context.read<ProductProvider>().fetchAllProducts();
            });
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
    );
  }
}
