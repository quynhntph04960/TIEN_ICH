import 'package:demo2/sudoku/sudoku_item.dart';

extension SudokuExtension on List<List<SudokuItem>> {
  // true la trung, false la khong trung
  bool isCheckRow({required SudokuItem item}) {
    for (int row = 0; row < length; row++) {
      final listSub = this[row];
      for (int col = 0; col < listSub.length; col++) {
        final dataFor = listSub[col];
        if (dataFor.row == item.row && dataFor.data == item.data) {
          return true;
        }
      }
    }
    return false;
  }
}
