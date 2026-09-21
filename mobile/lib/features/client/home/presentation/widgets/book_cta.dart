import 'package:flutter/material.dart';
import 'package:mongez/core/theme/app_colors.dart';
import 'package:mongez/generated/l10n.dart';

class BookCTA extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final String? rate;
  const BookCTA({super.key, required this.onTap, required this.label, this.rate});

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: AppGradients.brand,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            if (rate != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    rate!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    lang.perHour,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Icon(isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
              color: Colors.white),
          ],
        ),
      ),
    );
  }
}
