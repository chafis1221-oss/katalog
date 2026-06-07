import 'package:flutter/material.dart';

class CalculatorKeypad extends StatelessWidget {
  final bool showOperators; // true untuk kalkulator full, false untuk kasir
  final Function(String) onKeyPress;

  const CalculatorKeypad({
    super.key,
    required this.showOperators,
    required this.onKeyPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Baris operator (hanya untuk kalkulator full)
        if (showOperators)
          Row(
            children: [
              _buildKey('C', color: Colors.red),
              _buildKey('( )', color: Colors.blueGrey),
              _buildKey('%', color: Colors.blueGrey),
              _buildKey('÷', color: Colors.orange),
            ],
          ),
        // Baris 1
        Row(
          children: [
            _buildKey('7'),
            _buildKey('8'),
            _buildKey('9'),
            if (showOperators) _buildKey('×', color: Colors.orange),
            if (!showOperators) _buildKey('⌫', color: Colors.red),
          ],
        ),
        // Baris 2
        Row(
          children: [
            _buildKey('4'),
            _buildKey('5'),
            _buildKey('6'),
            if (showOperators) _buildKey('-', color: Colors.orange),
            if (!showOperators) _buildKey('000', color: Colors.teal),
          ],
        ),
        // Baris 3
        Row(
          children: [
            _buildKey('1'),
            _buildKey('2'),
            _buildKey('3'),
            if (showOperators) _buildKey('+', color: Colors.orange),
            if (!showOperators) _buildKey('0'),
          ],
        ),
        // Baris 4
        Row(
          children: [
            if (showOperators) _buildKey('0'),
            if (showOperators) _buildKey('000', color: Colors.teal),
            if (showOperators) _buildKey('.', color: Colors.teal),
            if (!showOperators) _buildKey('0', flex: 2),
            if (!showOperators) _buildKey('.', color: Colors.teal),
            _buildKey('⌫', color: Colors.red),
          ],
        ),
        // Tombol = (hanya kalkulator full)
        if (showOperators)
          Row(
            children: [
              _buildKey('=', flex: 4, color: Colors.teal),
            ],
          ),
      ],
    );
  }

  Widget _buildKey(String label, {Color? color, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox(
          height: 60,
          child: ElevatedButton(
            onPressed: () => onKeyPress(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: color ?? Colors.grey[200],
              foregroundColor: color != null ? Colors.white : Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 1,
              padding: EdgeInsets.zero,
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}