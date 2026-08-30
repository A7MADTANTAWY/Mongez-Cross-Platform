import 'package:flutter/material.dart';
import 'package:mongez/core/theme/app_colors.dart';
import 'package:mongez/features/shared/workers/data/models/worker_model.dart';

class StatsRow extends StatelessWidget {
  final WorkerModel worker;
  const StatsRow({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    Widget cell(String label, String value, IconData icon, Color color) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(value, style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w800, color: color, fontSize: 16,
              )),
              const SizedBox(height: 2),
              Text(label, style: tt.bodySmall?.copyWith(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.7),
              )),
            ],
          ),
        ),
      );
    }
    return Row(
      children: [
        cell('Complete', '${worker.completionRate.round()}%',
            Icons.check_circle_outline, AppColors.success),
        const SizedBox(width: 10),
        cell('Accept', '${worker.acceptRate.round()}%',
            Icons.task_alt_outlined, AppColors.primary),
        const SizedBox(width: 10),
        cell('Experience', '${worker.experienceYears}y',
            Icons.workspace_premium_outlined, AppColors.highlight),
      ],
    );
  }
}
