import 'dart:math';

import 'package:demo2/sudoku/sudoku_item.dart';
import 'package:demo2/sudoku/sudoku_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SudokuCubit extends Cubit<SudokuState> {
  SudokuCubit() : super(const SudokuState());

  final Random _random = Random();
  late List<List<int>> _solution;
  late List<List<int>> _puzzle;

  void initialize() {
    newGame();
  }

  void newGame() {
    _solution = _createSolvedBoard();
    _puzzle = _createPuzzle(_solution, hiddenCells: 45);
    emit(
      SudokuState(
        list: _buildItems(_puzzle, _solution),
        message: 'Đề mới đã sẵn sàng',
      ),
    );
  }

  void selectCell(SudokuItem item) {
    if (state.isCompleted || state.isGameOver) return;

    emit(
      state.copyWith(
        selectedRow: item.row,
        selectedColumn: item.column,
        message: item.isFixed ? 'Ô này là số cố định' : '',
      ),
    );
  }

  void inputNumber(int number) {
    final row = state.selectedRow;
    final column = state.selectedColumn;
    if (row == null ||
        column == null ||
        state.isCompleted ||
        state.isGameOver) {
      return;
    }

    final item = state.list[row][column];
    if (item.isFixed) {
      emit(state.copyWith(message: 'Không thể sửa số cố định'));
      return;
    }

    _updateCell(row, column, number);
  }

  void clearSelectedCell() {
    final row = state.selectedRow;
    final column = state.selectedColumn;
    if (row == null ||
        column == null ||
        state.isCompleted ||
        state.isGameOver) {
      return;
    }

    final item = state.list[row][column];
    if (item.isFixed) return;

    _updateCell(row, column, 0);
  }

  void revealHint() {
    final row = state.selectedRow;
    final column = state.selectedColumn;
    if (row == null ||
        column == null ||
        state.isCompleted ||
        state.isGameOver) {
      return;
    }

    if (state.hintsUsed >= 3) {
      emit(state.copyWith(message: 'Bạn đã dùng hết gợi ý'));
      return;
    }

    final item = state.list[row][column];
    if (item.isFixed || item.data == item.answer) return;

    final updated = _copyBoard();
    updated[row][column] = item.copyWith(data: item.answer, isError: false);
    emit(
      state.copyWith(
        list: updated,
        hintsUsed: state.hintsUsed + 1,
        isCompleted: _isBoardCompleted(updated),
        message: 'Đã mở gợi ý',
      ),
    );
  }

  void _updateCell(int row, int column, int number) {
    final item = state.list[row][column];
    final hasError = number != 0 && number != item.answer;
    final updated = _copyBoard();
    updated[row][column] = item.copyWith(data: number, isError: hasError);
    final completed = _isBoardCompleted(updated);
    final mistakes = hasError ? state.mistakes + 1 : state.mistakes;
    final isGameOver = mistakes >= 3 && !completed;

    emit(
      state.copyWith(
        list: updated,
        mistakes: mistakes,
        isCompleted: completed,
        isGameOver: isGameOver,
        message: completed
            ? 'Hoàn thành Sudoku'
            : isGameOver
            ? 'Bạn đã thua'
            : hasError
            ? 'Số này chưa đúng'
            : '',
      ),
    );
  }

  List<List<SudokuItem>> _copyBoard() {
    return state.list
        .map((row) => row.map((item) => item.copyWith()).toList())
        .toList();
  }

  bool _isBoardCompleted(List<List<SudokuItem>> board) {
    for (final row in board) {
      for (final item in row) {
        if (item.data != item.answer) return false;
      }
    }
    return true;
  }

  List<List<SudokuItem>> _buildItems(
    List<List<int>> puzzle,
    List<List<int>> solution,
  ) {
    return List.generate(9, (row) {
      return List.generate(9, (column) {
        final value = puzzle[row][column];
        return SudokuItem(
          row: row,
          column: column,
          data: value,
          answer: solution[row][column],
          isFixed: value != 0,
        );
      });
    });
  }

  List<List<int>> _createSolvedBoard() {
    final rows = _shuffledGroups();
    final columns = _shuffledGroups();
    final numbers = List<int>.generate(9, (index) => index + 1)
      ..shuffle(_random);

    return List.generate(9, (row) {
      return List.generate(9, (column) {
        final pattern = (rows[row] * 3 + rows[row] ~/ 3 + columns[column]) % 9;
        return numbers[pattern];
      });
    });
  }

  List<int> _shuffledGroups() {
    final groups = [0, 1, 2]..shuffle(_random);
    final result = <int>[];
    for (final group in groups) {
      final inner = [0, 1, 2]..shuffle(_random);
      result.addAll(inner.map((value) => group * 3 + value));
    }
    return result;
  }

  List<List<int>> _createPuzzle(
    List<List<int>> solved, {
    required int hiddenCells,
  }) {
    final puzzle = solved.map((row) => List<int>.from(row)).toList();
    final positions = List<int>.generate(81, (index) => index)
      ..shuffle(_random);

    for (final position in positions.take(hiddenCells)) {
      puzzle[position ~/ 9][position % 9] = 0;
    }
    return puzzle;
  }
}
