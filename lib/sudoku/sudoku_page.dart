import 'package:demo2/sudoku/sudoku_cubit.dart';
import 'package:demo2/sudoku/sudoku_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SudokuPage extends StatefulWidget {
  const SudokuPage({super.key});

  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  final _cubit = SudokuCubit();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _cubit.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SudokuCubit, SudokuState>(
      bloc: _cubit,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text("Sudoku")),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(8),

                decoration: BoxDecoration(
                  border: Border.all(width: 1.1, color: Colors.black),
                ),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  shrinkWrap: true,
                  itemCount: state.list.length,
                  itemBuilder: (context, index) {
                    final list = state.list[index];
                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.black),
                      ),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                            ),
                        shrinkWrap: true,
                        itemCount: list.length,
                        itemBuilder: (context, subIndex) {
                          final data = list[subIndex];
                          return GestureDetector(
                            onTap: () {
                              _cubit.onClick(data);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.1,
                                  color: Colors.black,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Text(
                                  //   "row:${data.row}",
                                  //   style: TextStyle(fontSize: 10),
                                  // ),
                                  // Text(
                                  //   "column:${data.column}",
                                  //   style: TextStyle(fontSize: 10),
                                  // ),
                                  Text(
                                    "${data.data}",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  BorderSide isBorderRight(int index) {
    switch (index) {
      case 2:
      case 5:
      case 11:
      case 14:
      case 20:
      case 23:
      case 29:
      case 32:
      case 38:
      case 41:
      case 47:
      case 50:
      case 56:
      case 59:
      case 65:
      case 68:
      case 74:
      case 77:
        return BorderSide(width: 1, color: Colors.black);
    }
    return BorderSide(width: 0.1, color: Colors.black);
  }

  BorderSide isBorderTop(int index) {
    switch (index) {
      case 27:
      case 28:
      case 29:
      case 30:
      case 31:
      case 32:
      case 33:
      case 34:
      case 35:
      case 54:
      case 55:
      case 56:
      case 57:
      case 58:
      case 59:
      case 60:
      case 61:
      case 62:
        return BorderSide(width: 1, color: Colors.black);
    }
    return BorderSide(width: 0.1, color: Colors.black);
  }
}
