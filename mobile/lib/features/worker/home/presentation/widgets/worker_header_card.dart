import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongez/core/di/services_locator.dart';
import 'package:mongez/features/client/address/data/repositories/address_repository.dart';
import 'package:mongez/features/shared/profile/presentation/cubit/profile_cubit.dart';
import 'package:mongez/features/worker/home/presentation/cubit/worker_stats_cubit.dart';
import 'package:mongez/generated/l10n.dart';

class WorkerHeaderCard extends StatefulWidget {
  const WorkerHeaderCard({super.key});

  @override
  State<WorkerHeaderCard> createState() => _WorkerHeaderCardState();
}

class _WorkerHeaderCardState extends State<WorkerHeaderCard> {
  late final AddressRepository _addressRepo;

  @override
  void initState() {
    super.initState();
    _addressRepo = getIt<AddressRepository>();
    _addressRepo.load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final lang = S.of(context);

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (ctx, profileState) {
        final profile =
            profileState is ProfileSuccess ? profileState.profile : null;
        final displayName = profile?.displayName ?? profile?.username ?? '';
        final governorate = profile?.governorateLabel ?? '';
        final city = profile?.city ?? '';
        final locationParts = [
          if (governorate.isNotEmpty) governorate,
          if (city.isNotEmpty) city,
        ];

        return BlocBuilder<WorkerStatsCubit, WorkerStatsState>(
          builder: (ctx, statsState) {
            final stats = statsState is WorkerStatsSuccess ? statsState.stats : null;
            final isAvailable = stats?.isAvailable ?? false;

            return ListenableBuilder(
              listenable: _addressRepo,
              builder: (ctx, _) {
                // Prefer the address the user marked as default in My
                // Addresses; fall back to the profile governorate/city.
                final defaultAddress = _addressRepo.defaultAddress;
                final savedLocation = defaultAddress?.shortAddress ?? '';
                final locationText = savedLocation.isNotEmpty
                    ? savedLocation
                    : locationParts.join(' · ');

            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cs.primary, cs.primary.withValues(alpha: 0.78)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang.welcomeBack,
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onPrimary.withValues(alpha: 0.78),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displayName,
                              style: tt.headlineSmall?.copyWith(
                                color: cs.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (locationText.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: cs.onPrimary.withValues(alpha: 0.78),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      locationText,
                                      style: tt.bodyMedium?.copyWith(
                                        color:
                                            cs.onPrimary.withValues(alpha: 0.78),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (stats?.isVerified ?? false)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: cs.onPrimary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded,
                                  size: 14, color: cs.onPrimary),
                              const SizedBox(width: 4),
                              Text(
                                lang.verified,
                                style: tt.labelSmall?.copyWith(
                                  color: cs.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (stats != null)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.onPrimary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? const Color(0xFF34D399)
                                  : Colors.white60,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isAvailable
                                  ? lang.availableDescription
                                  : lang.offlineDescription,
                              style:
                                  tt.bodySmall?.copyWith(color: cs.onPrimary),
                            ),
                          ),
                          Switch(
                            value: isAvailable,
                            onChanged: (v) => ctx
                                .read<WorkerStatsCubit>()
                                .toggleAvailability(v),
                            activeThumbColor: Colors.white,
                            activeTrackColor: const Color(0xFF34D399),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor:
                                cs.onPrimary.withValues(alpha: 0.3),
                          ),
                         ],
                       ),
                     ),
                 ],
               ),
             );
               },
            );
          },
        );
      },
    );
  }
}
