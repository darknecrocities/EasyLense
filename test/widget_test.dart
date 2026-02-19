import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:easylense_prototype/main.dart';

void main() {
  testWidgets('EasyLens app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EasyLensApp());
    await tester.pumpAndSettle();

    // Bottom navigation bar should be visible
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Detection tab content should be visible by default
    expect(find.text('CAMERA SIMULATED'), findsOneWidget);
  });
}
