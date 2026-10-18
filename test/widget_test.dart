import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:bookworm/database_helper.dart';
import 'package:bookworm/main.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    await DatabaseHelper.instance.getBooks();
  });

  testWidgets('Home screen shows the empty state and add button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Want to add some books?'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
