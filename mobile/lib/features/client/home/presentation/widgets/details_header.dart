import 'package:flutter/material.dart';
import 'package:mongez/core/theme/app_colors.dart';
import 'package:mongez/core/widgets/app_network_image.dart';
import 'package:mongez/core/widgets/favorite_button.dart';
import 'package:mongez/features/shared/workers/data/models/worker_model.dart';
import 'package:mongez/generated/l10n.dart';

class DetailsHeader extends StatelessWidget {
  final WorkerModel worker;
  final bool isCustomer;
  final String name;
  final String profession;
  final String location;

  const DetailsHeader({
    super.key,
    required this.worker,
    required this.isCustomer,
    required this.name,
    required this.profession,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    final theme = Theme.of(context);
    final tt = theme.textTheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.brand,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(28),
          ),
        ),
        padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CircleButton(
                  icon: isRtl
                      ? Icons.arrow_forward_rounded
                      : Icons.arrow_back_rounded,
                  onTap: () => Navigator.maybePop(context),
                ),
                const Spacer(),
                if (isCustomer)
                  FavoriteButton(workerId: worker.userId ?? worker.id),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                  // Foreground border so the photo fills the circle
                  // edge-to-edge (a decoration border pads the child
                  // and leaves a ring).
                  foregroundDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5), width: 2,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: worker.profileImage != null
                      ? AppNetworkImage(
                          imageUrl: worker.profileImage!,
                          fit: BoxFit.cover,
                          cacheWidth: 84,
                          errorWidget: (_, e, s) => const Icon(
                            Icons.person, size: 40, color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tt.titleLarge?.copyWith(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (worker.isVerified)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.verified_rounded,
                                color: Colors.white, size: 22,
                              ),
                            ),
                        ],
                      ),
                      if (profession.isNotEmpty)
                        Text(
                          profession,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _GlassChip(
                            icon: Icons.star_rounded,
                            iconColor: Colors.amber.shade300,
                            text: '${worker.averageRating.toStringAsFixed(1)} '
                                '(${worker.completedJobs})',
                          ),
                          if (location.isNotEmpty)
                            _GlassChip(
                              icon: Icons.place_outlined,
                              text: location,
                            ),
                          if (worker.isFeatured)
                            _GlassChip(
                              icon: Icons.workspace_premium_outlined,
                              iconColor: Colors.amber.shade200,
                              text: lang.topRated,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String text;
  const _GlassChip({required this.icon, required this.text, this.iconColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor ?? Colors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
