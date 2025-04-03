import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koperasi_undiksha/main.dart';

void main() {
  testWidgets('App should launch without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  }, skip: true);
}
