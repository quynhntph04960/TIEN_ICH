import 'package:demo2/sudoku/sudoku_item.dart';

class SudokuState {
  final List<List<SudokuItem>> list;

  SudokuState({this.list = const []});

  SudokuState copyWith({List<List<SudokuItem>>? list}) {
    return SudokuState(list: list ?? this.list);
  }
}
