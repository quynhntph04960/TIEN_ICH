import 'package:bloc/bloc.dart';
import 'package:demo2/sudoku/sudoku_item.dart';
import 'package:demo2/sudoku/sudoku_state.dart';

class SudokuCubit extends Cubit<SudokuState> {
  SudokuCubit() : super(SudokuState());

  Future initialize() async {
    List<List<SudokuItem>> list = [];
    for (int row = 1; row <= 9; row++) {
      final data = <SudokuItem>[];

      for (int col = 1; col <= 9; col++) {
        int iRowCheck = 0;

        if (row >= 1 && row <= 3) {
          /// ROW 1 2 3
          if (col >= 1 && col <= 3) {
            iRowCheck = 1;
          } else if (col >= 4 && col <= 6) {
            iRowCheck = 2;
          } else {
            iRowCheck = 3;
          }
        } else if (row >= 4 && row <= 6) {
          /// ROW 4 5 6
          if (col >= 1 && col <= 3) {
            iRowCheck = 4;
          } else if (col >= 4 && col <= 6) {
            iRowCheck = 5;
          } else {
            iRowCheck = 6;
          }
        } else {
          /// ROW 7 8 9
          if (col >= 1 && col <= 3) {
            iRowCheck = 7;
          } else if (col >= 4 && col <= 6) {
            iRowCheck = 8;
          } else {
            iRowCheck = 9;
          }
        }

        int iColumnCheck = 0;
        if (row == 1 || row == 4 || row == 7) {
          if (col == 1 || col == 4 || col == 7) {
            iColumnCheck = 1;
          } else if (col == 2 || col == 5 || col == 8) {
            iColumnCheck = 2;
          } else {
            iColumnCheck = 3;
          }
        } else if (row == 2 || row == 5 || row == 8) {
          if (col == 1 || col == 4 || col == 7) {
            iColumnCheck = 4;
          } else if (col == 2 || col == 5 || col == 8) {
            iColumnCheck = 5;
          } else {
            iColumnCheck = 6;
          }
        } else {
          if (col == 1 || col == 4 || col == 7) {
            iColumnCheck = 7;
          } else if (col == 2 || col == 5 || col == 8) {
            iColumnCheck = 8;
          } else {
            iColumnCheck = 9;
          }
        }
        data.add(SudokuItem(row: iRowCheck, column: iColumnCheck, data: 0));
      }

      list.add(data);
    }
    emit(state.copyWith(list: list));
  }

  void onClick(SudokuItem data) {
    List<int> listRow = [];
    List<int> listColumn = [];

    for (int row = 0; row < state.list.length; row++) {
      final listSub = state.list[row];
      for (int col = 0; col < listSub.length; col++) {
        final dataFor = listSub[col];
        if (data.row == dataFor.row) {
          listRow.add(dataFor.data);
        }
        if (data.column == dataFor.column) {
          listColumn.add(dataFor.data);
        }
      }
    }
    print('Position: ${data.row} - ${data.column}');
    print('row: ${listRow.toString()}');
    print('column: ${listColumn.toString()}');
  }
}
