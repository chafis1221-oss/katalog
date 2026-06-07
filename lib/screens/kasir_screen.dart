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

  static const int _maxDigits = 12;

  int get cashAmount => int.tryParse(_cashInput) ?? 0;
  int get changeAmount => cashAmount - context.read<CartProvider>().total.toInt();
  bool get canPay => cashAmount >= context.read<CartProvider>().total && context.read<CartProvider>().items.isNotEmpty;

  void _onKeyPress(String key) {
    setState(() {
      if (key == '⌫') {
        if (_cashInput.isNotEmpty) {
          _cashInput = _cashInput.substring(0, _cashInput.length - 1);
        }
      } else if (key == '000') {
        if (_cashInput.length + 3 <= _maxDigits) {
          _cashInput += '000';
        }
      } else {
        if (_cashInput.length < _maxDigits) {
          _cashInput += key;
        }
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
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
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
          ? const Center(child: Text('Keranjang kosong'))
          : Column(
              children: [
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(priceFormat.format(cart.total), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Uang Tunai',
                      hintText: '0',
                      suffix: Text(priceFormat.format(cashAmount), style: const TextStyle(fontSize: 18)),
                    ),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                if (_cashInput.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kembalian', style: TextStyle(fontSize: 16)),
                        Text(
                          priceFormat.format(changeAmount > 0 ? changeAmount : 0),
                          style: TextStyle(fontSize: 16, color: changeAmount >= 0 ? Colors.green : Colors.red),
                        ),
                      ],
                    ),
                  ),
                CalculatorKeypad(
                  showOperators: false,
                  onKeyPress: _onKeyPress,
                ),
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
