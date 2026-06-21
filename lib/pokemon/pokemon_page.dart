import 'package:demo2/pokemon/pokemon_cubit.dart';
import 'package:demo2/pokemon/pokemon_state.dart';
import 'package:demo2/pokemon/pokemon_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widget/header_pokemon.dart';

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  final _cubit = PokemonCubit();
  bool _winDialogShown = false;
  bool _timeOverDialogShown = false;

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
    return BlocConsumer<PokemonCubit, PokemonState>(
      bloc: _cubit,
      listener: (context, state) {
        if (!state.isCompleted) {
          _winDialogShown = false;
        }

        if (!state.isTimeOver) {
          _timeOverDialogShown = false;
        }

        if (state.isCompleted && !_winDialogShown) {
          _winDialogShown = true;
          final isFinalLevel = state.currentLevel >= PokemonCubit.levelCount;
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text(isFinalLevel ? 'Phá đảo rồi!' : 'Thắng rồi!'),
                content: Text(
                  isFinalLevel
                      ? 'Bạn đã phá đảo Pokemon cổ điển. Xác nhận để quay về cấp 1.'
                      : 'Bạn đã thắng cấp ${state.currentLevel}. Xác nhận để sang cấp ${state.currentLevel + 1}.',
                ),
                actions: [
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _cubit.continueAfterWin();
                    },
                    child: Text(
                      isFinalLevel
                          ? 'Về cấp 1'
                          : 'Sang cấp ${state.currentLevel + 1}',
                    ),
                  ),
                ],
              );
            },
          );
        }

        if (state.isTimeOver && !_timeOverDialogShown) {
          _timeOverDialogShown = true;
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: const Text('Hết giờ rồi'),
                content: Text(
                  'Bạn chưa hoàn thành cấp ${state.currentLevel}. Xác nhận để chơi lại cấp này.',
                ),
                actions: [
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _cubit.newGame();
                    },
                    child: const Text('Chơi lại'),
                  ),
                ],
              );
            },
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Pokemon cổ điển')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              HeaderPokemon(
                state: state,
                onNewGame: _cubit.newGame,
                onHint: _cubit.revealHint,
                onShuffle: _cubit.shuffleBoard,
              ),
              const SizedBox(height: 16),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: _PokemonBoard(
                    state: state,
                    onTileTap: _cubit.selectTile,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  state.message,
                  key: ValueKey(state.message),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PokemonBoard extends StatefulWidget {
  const _PokemonBoard({required this.state, required this.onTileTap});

  final PokemonState state;
  final ValueChanged<PokemonTile> onTileTap;

  @override
  State<_PokemonBoard> createState() => _PokemonBoardState();
}

class _PokemonBoardState extends State<_PokemonBoard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lineController;
  late final Animation<double> _lineOpacity;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _lineOpacity = Tween<double>(begin: 0.25, end: 1).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant _PokemonBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hasLine = widget.state.connectionPath.isNotEmpty;
    final hadLine = oldWidget.state.connectionPath.isNotEmpty;

    if (hasLine && !hadLine) {
      _lineController.repeat(reverse: true);
    } else if (!hasLine && hadLine) {
      _lineController.stop();
      _lineController.value = 0;
    }
  }

  @override
  void dispose() {
    _lineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: PokemonCubit.columns / PokemonCubit.rows,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          border: Border.all(color: const Color(0xFF0F172A), width: 2),
        ),
        child: Stack(
          children: [
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(3),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: PokemonCubit.columns,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: PokemonCubit.rows * PokemonCubit.columns,
              itemBuilder: (context, index) {
                final row = index ~/ PokemonCubit.columns;
                final column = index % PokemonCubit.columns;
                final tile = widget.state.board[row][column];
                final isSelected =
                    widget.state.selectedTile?.row == tile.row &&
                    widget.state.selectedTile?.column == tile.column;
                final isHinted = widget.state.hintedKeys.contains(
                  '${tile.row}-${tile.column}',
                );

                return _PokemonTileButton(
                  tile: tile,
                  isSelected: isSelected,
                  isHinted: isHinted,
                  onTap: () => widget.onTileTap(tile),
                );
              },
            ),
            if (widget.state.connectionPath.isNotEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _lineOpacity,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _ConnectionLinePainter(
                          path: widget.state.connectionPath,
                          opacity: _lineOpacity.value,
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionLinePainter extends CustomPainter {
  const _ConnectionLinePainter({required this.path, required this.opacity});

  final List<PokemonConnectionPoint> path;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;

    const outerPadding = 3.0;
    const spacing = 2.0;
    final boardWidth = size.width - outerPadding * 2;
    final boardHeight = size.height - outerPadding * 2;
    final tileWidth =
        (boardWidth - spacing * (PokemonCubit.columns - 1)) /
        PokemonCubit.columns;
    final tileHeight =
        (boardHeight - spacing * (PokemonCubit.rows - 1)) / PokemonCubit.rows;

    Offset pointToOffset(PokemonConnectionPoint point) {
      final x =
          outerPadding +
          (point.column + 0.5) * tileWidth +
          point.column * spacing;
      final y =
          outerPadding + (point.row + 0.5) * tileHeight + point.row * spacing;
      return Offset(x, y);
    }

    final line = Path()
      ..moveTo(pointToOffset(path.first).dx, pointToOffset(path.first).dy);
    for (final point in path.skip(1)) {
      final offset = pointToOffset(point);
      line.lineTo(offset.dx, offset.dy);
    }

    final glowPaint = Paint()
      ..color = const Color(0xFFFFF7AD).withValues(alpha: opacity * 0.65)
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final linePaint = Paint()
      ..color = const Color(0xFFFFD000).withValues(alpha: opacity)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(line, glowPaint);
    canvas.drawPath(line, linePaint);
  }

  @override
  bool shouldRepaint(covariant _ConnectionLinePainter oldDelegate) {
    return oldDelegate.path != path || oldDelegate.opacity != opacity;
  }
}

class _PokemonTileButton extends StatelessWidget {
  const _PokemonTileButton({
    required this.tile,
    required this.isSelected,
    required this.isHinted,
    required this.onTap,
  });

  final PokemonTile tile;
  final bool isSelected;
  final bool isHinted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (tile.isRemoved) {
      return const SizedBox.shrink();
    }

    final borderColor = isHinted
        ? const Color(0xFFFACC15)
        : isSelected
        ? const Color(0xFFF60000)
        : const Color(0xFFE2E8F0);

    return Material(
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: isHinted ? 1 : 1),
            boxShadow: isSelected || isHinted
                ? const [
                    BoxShadow(
                      color: Color(0x330EA5E9),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Image.asset(tile.assetPath, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
