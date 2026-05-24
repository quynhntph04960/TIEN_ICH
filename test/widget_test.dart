import 'package:flutter_test/flutter_test.dart';

import 'package:demo2/main.dart';

void main() {
  testWidgets('opens Sudoku game from home', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Chon module'), findsOneWidget);
    expect(find.text('Sudoku'), findsOneWidget);

    await tester.tap(find.text('Sudoku'));
    await tester.pumpAndSettle();

    expect(find.text('Game Sudoku'), findsOneWidget);
    expect(find.byTooltip('Ván mới'), findsOneWidget);
  });
}
