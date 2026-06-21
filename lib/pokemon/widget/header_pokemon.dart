import 'package:flutter/material.dart';

import '../pokemon_state.dart';
import '../popup/level_info_dialog.dart';

class HeaderPokemon extends StatelessWidget {
  const HeaderPokemon({
    super.key,
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
    final isLowTime = state.remainingSeconds <= 60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          _Stat(label: 'Cấp độ', value: '${state.currentLevel}'),
          SizedBox(width: 16),
          _Stat(label: 'Điểm', value: '${state.score}'),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              _formatTime(state.remainingSeconds),
              textAlign: TextAlign.end,
              style: TextStyle(
                color: isLowTime
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: 32),
          _ButtonClick(
            onClick: onNewGame,
            tooltip: 'Ván mới',
            icons: Icons.refresh_rounded,
          ),
          _ButtonClick(
            onClick: !state.isTimeOver && state.shufflesLeft > 0
                ? onShuffle
                : null,
            tooltip: 'Xáo bàn',
            icons: Icons.shuffle_rounded,
            number: state.shufflesLeft,
          ),
          _ButtonClick(
            onClick: !state.isTimeOver && state.hintsLeft > 0 ? onHint : null,
            tooltip: 'Gợi ý',
            icons: Icons.lightbulb_rounded,
            number: state.hintsLeft,
          ),
          _ButtonClick(
            onClick: () {
              LevelInfoDialog.showLevelInfo(context, state.currentLevel);
            },
            tooltip: 'Thông tin cấp độ',
            icons: Icons.info_outline_rounded,
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final clampedSeconds = totalSeconds < 0 ? 0 : totalSeconds;
    final minutes = clampedSeconds ~/ 60;
    final seconds = clampedSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 9,
        backgroundColor: const Color(0xFFE2E8F0),
        valueColor: AlwaysStoppedAnimation<Color>(
          isLowTime ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
        ),
      ),
    );
  }
}

class _ButtonClick extends StatelessWidget {
  final Function()? onClick;
  final String tooltip;
  final IconData icons;
  final int number;

  const _ButtonClick({
    required this.tooltip,
    required this.icons,
    required this.onClick,
    this.number = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(500),
            ),
            child: IconButton(
              padding: EdgeInsets.all(0),
              onPressed: onClick,
              tooltip: tooltip,
              iconSize: 18,
              hoverColor: Colors.orange,
              highlightColor: Colors.blue,
              icon: Icon(icons),
            ),
          ),
          Visibility(
            visible: number > 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(500),
              ),
              child: Text(
                "$number",
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
