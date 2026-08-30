import 'package:flutter/material.dart';
import 'package:mongez/core/widgets/app_network_image.dart';
import 'package:mongez/features/shared/workers/data/models/worker_model.dart';

class CheckoutWorkerCard extends StatelessWidget {
  final WorkerModel worker;
  const CheckoutWorkerCard({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final locale = Localizations.localeOf(context).languageCode;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: ClipOval(
              child: worker.profileImage != null
                  ? AppNetworkImage(
                      imageUrl: worker.profileImage!,
                      fit: BoxFit.cover,
                      cacheWidth: 40,
                      errorWidget: (_, _, _) => const Icon(Icons.person),
                    )
                  : const Icon(Icons.person),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(worker.nameFor(locale),
                  style: textTheme.titleMedium),
              Text(worker.categoryName ?? '',
                  style: textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
