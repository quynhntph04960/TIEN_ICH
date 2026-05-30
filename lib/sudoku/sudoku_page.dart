import 'package:demo2/sudoku/sudoku_cubit.dart';
import 'package:demo2/sudoku/sudoku_item.dart';
import 'package:demo2/sudoku/sudoku_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'popup/sudoku_dialog.dart';

class SudokuPage extends StatefulWidget {
  const SudokuPage({super.key});

  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  final _cubit = SudokuCubit();
  bool _lossDialogShown = false;
  bool _winDialogShown = false;

  @override
  void initState() {
    super.initState();
    _cubit.initialize();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SudokuCubit, SudokuState>(
      bloc: _cubit,
      listener: (context, state) {
        if (!state.isCompleted) {
          _winDialogShown = false;
        }

        if (!state.isGameOver) {
          _lossDialogShown = false;
        }

        if (state.isCompleted && !_winDialogShown) {
          _winDialogShown = true;
          showGameWinDialog(
            context,
            callWinGame: () {
              _cubit.newGame();
            },
          );
          return;
        }

        if (state.isGameOver && !_lossDialogShown) {
          _lossDialogShown = true;
          showGameOverDialog(
            context,
            callEndGame: () {
              _cubit.newGame();
            },
          );
        }
      },
      builder: (context, state) {
        final canPlay = !state.isGameOver && !state.isCompleted;

        return Scaffold(
          appBar: AppBar(title: const Text('Sudoku')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Header(state: state, onNewGame: _cubit.newGame),
                const SizedBox(height: 16),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: _SudokuBoard(
                      state: state,
                      enabled: canPlay,
                      onCellTap: _cubit.selectCell,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: _NumberPad(
                      enabled: canPlay,
                      onNumberTap: _cubit.inputNumber,
                      onClear: _cubit.clearSelectedCell,
                      onHint: _cubit.revealHint,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: state.message.isEmpty
                      ? const SizedBox(height: 22)
                      : Text(
                          state.message,
                          key: ValueKey(state.message),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: state.isCompleted
                                ? const Color(0xFF0F766E)
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state, required this.onNewGame});

  final SudokuState state;
  final VoidCallback onNewGame;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.grid_4x4_rounded,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Game Sudoku',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lỗi: ${state.mistakes}  |  Gợi ý: ${state.hintsUsed}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  onPressed: onNewGame,
                  tooltip: 'Ván mới',
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SudokuBoard extends StatelessWidget {
  const _SudokuBoard({
    required this.state,
    required this.enabled,
    required this.onCellTap,
  });

  final SudokuState state;
  final bool enabled;
  final ValueChanged<SudokuItem> onCellTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF0F172A), width: 1.4),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
          ),
          itemCount: 81,
          itemBuilder: (context, index) {
            final row = index ~/ 9;
            final column = index % 9;
            final item = state.list.isEmpty ? null : state.list[row][column];
            if (item == null) return const SizedBox.shrink();

            final selected =
                state.selectedRow == row && state.selectedColumn == column;
            final sameArea =
                state.selectedRow == row ||
                state.selectedColumn == column ||
                _sameBlock(
                  state.selectedRow,
                  state.selectedColumn,
                  row,
                  column,
                );

            return _SudokuCell(
              item: item,
              selected: selected,
              highlighted: sameArea,
              onTap: enabled ? () => onCellTap(item) : null,
            );
          },
        ),
      ),
    );
  }

  bool _sameBlock(int? selectedRow, int? selectedColumn, int row, int column) {
    if (selectedRow == null || selectedColumn == null) return false;
    return selectedRow ~/ 3 == row ~/ 3 && selectedColumn ~/ 3 == column ~/ 3;
  }
}

class _SudokuCell extends StatelessWidget {
  const _SudokuCell({
    required this.item,
    required this.selected,
    required this.highlighted,
    required this.onTap,
  });

  final SudokuItem item;
  final bool selected;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = item.isFixed
        ? const Color(0xFF0F172A)
        : item.isError
        ? const Color(0xFFDC2626)
        : const Color(0xFF2563EB);

    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFBFDBFE)
              : highlighted
              ? const Color(0xFFEFF6FF)
              : Colors.white,
          border: Border(
            right: BorderSide(
              color: const Color(0xFF0F172A),
              width: item.column == 2 || item.column == 5 ? 1.2 : 0.35,
            ),
            bottom: BorderSide(
              color: const Color(0xFF0F172A),
              width: item.row == 2 || item.row == 5 ? 1.2 : 0.35,
            ),
          ),
        ),
        child: Text(
          item.data == 0 ? '' : '${item.data}',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: item.isFixed ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  const _NumberPad({
    required this.enabled,
    required this.onNumberTap,
    required this.onClear,
    required this.onHint,
  });

  final bool enabled;
  final ValueChanged<int> onNumberTap;
  final VoidCallback onClear;
  final VoidCallback onHint;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            final number = index + 1;
            return FilledButton(
              onPressed: enabled ? () => onNumberTap(number) : null,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: enabled ? onClear : null,
                icon: const Icon(Icons.backspace_outlined),
                label: const Text('Xoá'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: enabled ? onHint : null,
                icon: const Icon(Icons.lightbulb_outline_rounded),
                label: const Text('Gợi ý'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
