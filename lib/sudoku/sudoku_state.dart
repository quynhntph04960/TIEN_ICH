import 'package:demo2/sudoku/sudoku_item.dart';

class SudokuState {
  final List<List<SudokuItem>> list;
  final int? selectedRow;
  final int? selectedColumn;
  final int mistakes;
  final int hintsUsed;
  final bool isCompleted;
  final String message;

  const SudokuState({
    this.list = const [],
    this.selectedRow,
    this.selectedColumn,
    this.mistakes = 0,
    this.hintsUsed = 0,
    this.isCompleted = false,
    this.message = '',
  });

  SudokuState copyWith({
    List<List<SudokuItem>>? list,
    int? selectedRow,
    int? selectedColumn,
    bool clearSelected = false,
    int? mistakes,
    int? hintsUsed,
    bool? isCompleted,
    String? message,
  }) {
    return SudokuState(
      list: list ?? this.list,
      selectedRow: clearSelected ? null : selectedRow ?? this.selectedRow,
      selectedColumn: clearSelected
          ? null
          : selectedColumn ?? this.selectedColumn,
      mistakes: mistakes ?? this.mistakes,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      isCompleted: isCompleted ?? this.isCompleted,
      message: message ?? this.message,
    );
  }
}
