// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gato/main.dart';

void main() {
  testWidgets('navigates from home to mark picker and board', (tester) async {
    await tester.pumpWidget(const GatoApp());

    expect(find.text('Gato'), findsOneWidget);
    expect(find.text('INICIAR'), findsOneWidget);

    await tester.tap(find.text('INICIAR'));
    await tester.pumpAndSettle();

    expect(find.text('Elige tu ficha'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Elegir X'));
    await tester.pumpAndSettle();

    expect(find.text('Elige tu ficha'), findsNothing);

    await tester.tap(find.byKey(const Key('board-cell-0')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(MarkShape), findsNWidgets(2));
  });
}
