import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:katalog/providers/cart_provider.dart';
import 'package:katalog/widgets/calculator_keypad.dart';

class KasirScreen extends StatefulWidget {
  const KasirScreen({super.key});

  @override
  State<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends State<KasirScreen> {
  String _cashInput = '';

  int get cashAmount => int.tryParse(_cashInput.replaceAll('.', '')) ?? 0;
  int get changeAmount => cashAmount - context.read<CartProvider>().total.toInt();
  bool get canPay => cashAmount >= context.read<CartProvider>().total && context.read<CartProvider>().items.isNotEmpty;

  void _onKeyPress(String key) {
    setState(() {
      if (key == '⌫') {
        if (_cashInput.isNotEmpty) {
          _cashInput = _cashInput.substring(0, _cashInput.length - 1);
        }
      } else if (key == '000') {
        _cashInput += '000';
      } else {
        _cashInput += key;
      }
    });
  }

  void _handlePay() {
    if (!canPay) return;
    final cart = context.read<CartProvider>();
    final total = cart.total.toInt();
    final change = cashAmount - total;
    final priceFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('💰 Pembayaran Berhasil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow('Total', priceFormat.format(total)),
            _buildRow('Tunai', priceFormat.format(cashAmount)),
            const Divider(),
            _buildRow('Kembalian', priceFormat.format(change), isBold: true),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              cart.clearCart();
              Navigator.pop(ctx);
              setState(() => _cashInput = '');
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 16)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final priceFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Kasir')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Keranjang kosong', style: TextStyle(fontSize: 18)))
          : Column(
              children: [
                // Daftar item
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return ListTile(
                        title: Text(item.product.name),
                        subtitle: Text('${item.quantity} x ${priceFormat.format(item.product.price)}'),
                        trailing: Text(priceFormat.format(item.subtotal)),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                // Total
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(
                        priceFormat.format(cart.total),
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                // ✅ Input uang tunai - TAMPILAN ANGKA DIPERBAIKI
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Uang Tunai', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(
                        _cashInput.isEmpty ? 'Rp 0' : priceFormat.format(cashAmount),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Kembalian
                if (_cashInput.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kembalian', style: TextStyle(fontSize: 16)),
                        Text(
                          changeAmount >= 0 ? priceFormat.format(changeAmount) : 'Uang kurang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: changeAmount >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Keypad
                CalculatorKeypad(
                  showOperators: false,
                  onKeyPress: _onKeyPress,
                ),
                // Tombol bayar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: canPay ? _handlePay : null,
                    icon: const Icon(Icons.payment),
                    label: const Text('BAYAR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
