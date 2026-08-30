import 'package:flutter/material.dart';

class CheckoutSection extends StatelessWidget {
  final String title;
  final Widget child;
  const CheckoutSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
