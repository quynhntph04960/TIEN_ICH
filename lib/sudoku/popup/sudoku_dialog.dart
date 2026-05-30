import 'package:flutter/material.dart';

Future<void> showGameOverDialog(
  BuildContext context, {
  required Function() callEndGame,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Bạn đã thua'),
        content: const Text(
          'Bạn đã sai 3 lần. Bạn có thể chơi lại hoặc xem lại ván này.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Xem lại'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              callEndGame();
            },
            child: const Text('Chơi lại'),
          ),
        ],
      );
    },
  );
}

Future<void> showGameWinDialog(
  BuildContext context, {
  required Function() callWinGame,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Bạn đã thắng'),
        content: const Text(
          'Bạn đã thắng ván này, có muốn tiếp tục thử thách nữa không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Xem lại'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              callWinGame();
            },
            child: const Text('Chơi lại'),
          ),
        ],
      );
    },
  );
}
