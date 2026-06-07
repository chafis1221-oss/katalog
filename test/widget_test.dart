import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warung_digital/main.dart';

void main() {
  testWidgets('App berjalan tanpa crash', (WidgetTester tester) async {
    await tester.pumpWidget(const WarungDigitalApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}