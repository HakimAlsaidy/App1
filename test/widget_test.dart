import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hall/main.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const HallApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
