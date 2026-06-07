import 'package:flutter/material.dart';
import 'package:katalog/widgets/calculator_keypad.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  final List<String> _history = [];

  void _onKeyPress(String key) {
    setState(() {
      switch (key) {
        case 'C':
          _display = '0';
          _expression = '';
          break;
        case '⌫':
          if (_expression.isNotEmpty) {
            _expression = _expression.substring(0, _expression.length - 1);
            _display = _expression.isEmpty ? '0' : _expression;
          }
          break;
        case '=':
          _calculate();
          break;
        default:
          _expression += key;
          _display = _expression;
      }
    });
  }

  void _calculate() {
    try {
      String expr = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('%', '/100');

      double result = _evaluate(expr);
      String resultStr = result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 2);

      _history.add('$_expression = $resultStr');
      _expression = resultStr;
      _display = resultStr;
    } catch (e) {
      _display = 'Error';
      _expression = '';
    }
  }

  double _evaluate(String expr) {
    final sanitized = expr.replaceAll(RegExp(r'[^0-9+\-*/().]'), '');
    return _parseExpression(sanitized);
  }

  double _parseExpression(String expr) {
    return _parseAddSub(expr.replaceAll(' ', ''));
  }

  double _parseAddSub(String expr) {
    double value = _parseMulDiv(expr);
    int i = 0;
    while (i < expr.length) {
      if (expr[i] == '+' || expr[i] == '-') {
        String op = expr[i];
        i++;
        double rhs = _parseMulDiv(expr.substring(i));
        if (op == '+') value += rhs;
        if (op == '-') value -= rhs;
        break;
      }
      i++;
    }
    return value;
  }

  double _parseMulDiv(String expr) {
    double value = _parseNum(expr);
    int i = 0;
    while (i < expr.length) {
      if (expr[i] == '*' || expr[i] == '/') {
        String op = expr[i];
        i++;
        double rhs = _parseNum(expr.substring(i));
        if (op == '*') value *= rhs;
        if (op == '/') value /= rhs;
        break;
      }
      i++;
    }
    return value;
  }

  double _parseNum(String expr) {
    if (expr.isEmpty) return 0;
    if (expr[0] == '(') {
      int depth = 0;
      int end = 0;
      for (int i = 0; i < expr.length; i++) {
        if (expr[i] == '(') depth++;
        if (expr[i] == ')') depth--;
        if (depth == 0) {
          end = i;
          break;
        }
      }
      return _parseAddSub(expr.substring(1, end));
    }
    final match = RegExp(r'^(\d+\.?\d*)').firstMatch(expr);
    if (match != null) {
      return double.parse(match.group(1)!);
    }
    return 0;
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Riwayat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() => _history.clear());
                          Navigator.pop(ctx);
                        },
                        child: const Text('Hapus Semua'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              Flexible(
                child: _history.isEmpty
                    ? const Center(child: Text('Belum ada riwayat'))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _history.length,
                        itemBuilder: (_, i) => ListTile(
                          title: Text(_history[i]),
                          onTap: () {
                            _history.removeAt(i);
                            setState(() {});
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator'),
        actions: [
          // ✅ Tombol riwayat
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Lihat Riwayat',
            onPressed: _showHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Layar kalkulator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_expression.isNotEmpty)
                  Text(
                    _expression,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                Text(
                  _display,
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Keypad penuh tanpa riwayat
          Expanded(
            child: CalculatorKeypad(
              showOperators: true,
              onKeyPress: _onKeyPress,
            ),
          ),
        ],
      ),
    );
  }
}
