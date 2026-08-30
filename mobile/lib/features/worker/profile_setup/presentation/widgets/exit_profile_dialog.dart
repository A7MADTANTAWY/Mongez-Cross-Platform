import 'package:flutter/material.dart';
import 'package:mongez/generated/l10n.dart';

class ExitProfileDialog extends StatelessWidget {
  final VoidCallback onLeave;
  const ExitProfileDialog({super.key, required this.onLeave});

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text(lang.leaveWithoutCompleting),
      content: Text(lang.leaveWarningDesc),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(lang.stay),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onLeave();
          },
          child: Text(
            lang.leave,
            style: tt.labelLarge?.copyWith(color: cs.error),
          ),
        ),
      ],
    );
  }
}
