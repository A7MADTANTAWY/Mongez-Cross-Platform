import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongez/features/worker/home/presentation/cubit/worker_stats_cubit.dart';
import 'package:mongez/generated/l10n.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkerStatsCubit, WorkerStatsState>(
      builder: (ctx, state) {
        if (state is! WorkerStatsSuccess) return const SizedBox.shrink();
        final s = state.stats;
        final lang = S.of(context);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.check_circle_outline_rounded,
                  label: lang.completedStats,
                  value: '${s.completedJobs}',
                  subtitle: lang.thisMonthCount(s.thisMonthCompleted),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatTile(
                  icon: Icons.inbox_outlined,
                  label: lang.pending,
                  value: '${s.pendingRequests}',
                  subtitle: lang.awaitingReply,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatTile(
                  icon: Icons.star_rate_rounded,
                  label: lang.ratingStats,
                  value: s.averageRating.toStringAsFixed(1),
                  subtitle: lang.recentCount(s.recentReviews.length),
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  const StatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
