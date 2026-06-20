import 'package:demo2/pokemon/pokemon_cubit.dart';
import 'package:demo2/pokemon/pokemon_state.dart';
import 'package:demo2/pokemon/pokemon_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
              _Header(
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

class _Header extends StatelessWidget {
  const _Header({
    required this.state,
    required this.onNewGame,
    required this.onHint,
    required this.onShuffle,
  });

  final PokemonState state;
  final VoidCallback onNewGame;
  final VoidCallback onHint;
  final VoidCallback onShuffle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEDD5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.catching_pokemon_rounded,
                        color: Color(0xFFEA580C),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Wrap(
                        spacing: 14,
                        runSpacing: 8,
                        children: [
                          _Stat(label: 'Điểm', value: '${state.score}'),
                          _Stat(label: 'Cấp', value: '${state.currentLevel}'),
                          _Stat(label: 'Gợi ý', value: '${state.hintsLeft}'),
                          _Stat(label: 'Xáo', value: '${state.shufflesLeft}'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _TimeBar(state: state),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onNewGame,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Ván mới'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filledTonal(
                      onPressed: !state.isTimeOver && state.hintsLeft > 0
                          ? onHint
                          : null,
                      tooltip: 'Gợi ý',
                      icon: const Icon(Icons.lightbulb_rounded),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: !state.isTimeOver && state.shufflesLeft > 0
                          ? onShuffle
                          : null,
                      tooltip: 'Xáo bàn',
                      icon: const Icon(Icons.shuffle_rounded),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (context) {
                            return _LevelInfoDialog(
                              currentLevel: state.currentLevel,
                            );
                          },
                        );
                      },
                      tooltip: 'Thông tin cấp độ',
                      icon: const Icon(Icons.info_outline_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeBar extends StatelessWidget {
  const _TimeBar({required this.state});

  final PokemonState state;

  @override
  Widget build(BuildContext context) {
    final totalSeconds = state.totalSeconds == 0 ? 1 : state.totalSeconds;
    final progress = (state.remainingSeconds / totalSeconds).clamp(0.0, 1.0);
    final isLowTime = state.remainingSeconds <= 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row(
        //   children: [
        //     Icon(
        //       Icons.timer_outlined,
        //       size: 18,
        //       color: isLowTime
        //           ? const Color(0xFFDC2626)
        //           : const Color(0xFF2563EB),
        //     ),
        //     const SizedBox(width: 6),
        //     const Text(
        //       'Thời gian',
        //       style: TextStyle(
        //         color: Color(0xFF64748B),
        //         fontSize: 12,
        //         fontWeight: FontWeight.w700,
        //       ),
        //     ),
        //     const Spacer(),
        //     Text(
        //       _formatTime(state.remainingSeconds),
        //       style: TextStyle(
        //         color: isLowTime
        //             ? const Color(0xFFDC2626)
        //             : const Color(0xFF0F172A),
        //         fontSize: 13,
        //         fontWeight: FontWeight.w900,
        //       ),
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(
              isLowTime ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(int totalSeconds) {
    final clampedSeconds = totalSeconds < 0 ? 0 : totalSeconds;
    final minutes = clampedSeconds ~/ 60;
    final seconds = clampedSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _LevelInfoDialog extends StatelessWidget {
  const _LevelInfoDialog({required this.currentLevel});

  final int currentLevel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thông tin cấp độ'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final info in _levelInfos)
                _LevelInfoRow(
                  info: info,
                  isCurrent: info.level == currentLevel,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}

class _LevelInfoRow extends StatelessWidget {
  const _LevelInfoRow({required this.info, required this.isCurrent});

  final _LevelInfo info;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFFE0F2FE) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrent ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: const Color(0xFF334155),
            fontSize: 13,
            height: 1.35,
            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: 'Cấp ${info.level}: ',
              style: TextStyle(
                color: const Color(0xFF0F172A),
                fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w800,
              ),
            ),
            TextSpan(text: info.description),
          ],
        ),
      ),
    );
  }
}

class _LevelInfo {
  const _LevelInfo(this.level, this.description);

  final int level;
  final String description;
}

const _levelInfos = [
  _LevelInfo(1, 'Các ô giữ nguyên sau khi nối đúng.'),
  _LevelInfo(2, 'Các ô trong từng cột đổ từ trên xuống dưới.'),
  _LevelInfo(3, 'Các ô trong từng cột đổ từ dưới lên trên.'),
  _LevelInfo(4, 'Các ô trong từng hàng đổ từ trái qua phải.'),
  _LevelInfo(5, 'Các ô trong từng hàng đổ từ phải qua trái.'),
  _LevelInfo(6, 'Nửa trái đổ về cột 8, nửa phải đổ về cột 9.'),
  _LevelInfo(7, 'Nửa trái đổ về cột 1, nửa phải đổ về cột 16.'),
  _LevelInfo(8, 'Các ô trong từng cột đổ về hàng 5.'),
  _LevelInfo(
    9,
    'Hàng 2-4 đổ về hàng 1, hàng 6-8 đổ về hàng 9, hàng 5 tách chẵn/lẻ.',
  ),
];

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
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
