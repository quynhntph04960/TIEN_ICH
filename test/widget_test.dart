import 'package:flutter_test/flutter_test.dart';

import 'package:demo2/main.dart';

void main() {
  testWidgets('opens Sudoku game from home', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Chọn tính năng'), findsOneWidget);
    expect(find.text('Sudoku'), findsOneWidget);

    await tester.tap(find.text('Sudoku'));
    await tester.pumpAndSettle();

    expect(find.text('Game Sudoku'), findsOneWidget);
    expect(find.byTooltip('Ván mới'), findsOneWidget);
  });

  testWidgets('opens Pokemon game from home', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Pokemon'), findsOneWidget);

    await tester.tap(find.text('Pokemon'));
    await tester.pumpAndSettle();

    expect(find.text('Pokemon cổ điển'), findsOneWidget);
    expect(find.text('Ván mới'), findsOneWidget);
    expect(find.byTooltip('Gợi ý'), findsOneWidget);
    expect(find.byTooltip('Xáo bàn'), findsOneWidget);
  });
}
