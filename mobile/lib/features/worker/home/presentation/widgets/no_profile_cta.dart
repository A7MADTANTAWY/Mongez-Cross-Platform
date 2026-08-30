import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongez/features/worker/home/presentation/cubit/worker_stats_cubit.dart';
import 'package:mongez/features/worker/profile_setup/presentation/screens/add_service_screen.dart';
import 'package:mongez/generated/l10n.dart';

class NoProfileCta extends StatelessWidget {
  const NoProfileCta({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkerStatsCubit, WorkerStatsState>(
      builder: (ctx, state) {
        if (state is! WorkerStatsNoProfile) return const SizedBox.shrink();
        final cs = Theme.of(ctx).colorScheme;
        final tt = Theme.of(ctx).textTheme;
        final lang = S.of(ctx);
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: cs.error, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.finishProfileSetup,
                      style: tt.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lang.setupSubtitle,
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => const AddServiceScreen(),
                  ),
                ),
                child: Text(lang.setUp),
              ),
            ],
          ),
        );
      },
    );
  }
}
