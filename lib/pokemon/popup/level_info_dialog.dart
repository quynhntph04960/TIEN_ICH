import 'package:flutter/material.dart';

import '../../base/constant.dart';
import '../model/level_info.dart';

class LevelInfoDialog extends StatelessWidget {
  const LevelInfoDialog({super.key, required this.currentLevel});

  static void showLevelInfo(BuildContext context, int currentLevel) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return LevelInfoDialog(currentLevel: currentLevel);
      },
    );
  }

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
              for (final info in Constant.levelInfosPokemon)
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

  final LevelInfoModel info;
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
