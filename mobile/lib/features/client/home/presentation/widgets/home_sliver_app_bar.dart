import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongez/core/di/services_locator.dart';
import 'package:mongez/features/auth/models/user.dart';
import 'package:mongez/features/client/address/data/repositories/address_repository.dart';
import 'package:mongez/features/shared/notifications/presentation/cubit/notification_cubit.dart';
import 'package:mongez/features/shared/notifications/presentation/screens/notification_screen.dart';
import 'package:mongez/core/widgets/app_network_image.dart';
import 'package:mongez/generated/l10n.dart';

class CustomSliverAppBarHome extends StatefulWidget {
  final User user;
  final bool isCustomer;
  const CustomSliverAppBarHome({
    super.key,
    required this.user,
    this.isCustomer = true,
  });

  @override
  State<CustomSliverAppBarHome> createState() => _CustomSliverAppBarHomeState();
}

class _CustomSliverAppBarHomeState extends State<CustomSliverAppBarHome> {
  late final AddressRepository _addressRepo;

  @override
  void initState() {
    super.initState();
    _addressRepo = getIt<AddressRepository>();
    _addressRepo.load();
  }

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final user = widget.user;

    final displayName = user.nameFor(locale).isNotEmpty
        ? user.nameFor(locale)
        : (user.username ?? '');
    final fallbackLocation = user.locationLabel();

    return ListenableBuilder(
      listenable: _addressRepo,
      builder: (context, _) {
        final defaultAddress = _addressRepo.defaultAddress;
        final location = defaultAddress != null &&
                defaultAddress.shortAddress.isNotEmpty
            ? defaultAddress.shortAddress
            : fallbackLocation;

        return SliverAppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          pinned: false,
          floating: true,
          snap: true,
          elevation: 0,
          toolbarHeight: 84,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                _Avatar(
                  imageUrl: user.profileImage,
                  fallbackInitial: displayName,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lang.hello(displayName),
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (location.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tt.titleSmall?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleSmall?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const _NotificationBell(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? imageUrl;
  final String? fallbackInitial;
  const _Avatar({this.imageUrl, this.fallbackInitial});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final initial = (fallbackInitial?.isNotEmpty ?? false)
        ? fallbackInitial![0].toUpperCase()
        : '?';

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        shape: BoxShape.circle,
      ),
      // Foreground border so the photo fills the circle edge-to-edge
      // (a decoration border pads the child and leaves a ring).
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? AppNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              cacheWidth: 44,
              placeholder: (_, _) => _initialBadge(cs, initial),
              errorWidget: (_, _, _) => _initialBadge(cs, initial),
            )
          : _initialBadge(cs, initial),
    );
  }

  Widget _initialBadge(ColorScheme cs, String initial) => Center(
    child: Text(
      initial,
      style: TextStyle(
        color: cs.onPrimaryContainer,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    ),
  );
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final unread = context.watch<NotificationCubit>().unreadCount;
        return Material(
          color: cs.surfaceContainerHighest,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Badge(
                isLabelVisible: unread > 0,
                label: Text('$unread', style: const TextStyle(fontSize: 10)),
                child: Icon(
                  Icons.notifications_outlined,
                  size: 22,
                  color: cs.onSurface,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
