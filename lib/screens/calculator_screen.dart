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
      // Ganti simbol operator agar bisa di-evaluasi
      String expr = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('%', '/100');

      // Evaluasi ekspresi matematika
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
    // Parser sederhana: pisahkan operator dan angka, hitung bertahap
    // Hanya mendukung +, -, *, / dan kurung
    final sanitized = expr.replaceAll(RegExp(r'[^0-9+\-*/().]'), '');
    return _parseExpression(sanitized);
  }

  double _parseExpression(String expr) {
    // Gunakan recursive descent parser sederhana
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator'),
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
                // Ekspresi (jika ada)
                if (_expression.isNotEmpty)
                  Text(
                    _expression,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                // Hasil / display utama
                Text(
                  _display,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Keypad
          Expanded(
            child: CalculatorKeypad(
              showOperators: true,
              onKeyPress: _onKeyPress,
            ),
          ),
          // Riwayat
          if (_history.isNotEmpty)
            Container(
              height: 80,
              color: Colors.grey[100],
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(right: 8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Center(
                        child: Text(
                          _history[index],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}