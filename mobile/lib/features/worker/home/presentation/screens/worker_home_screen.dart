import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongez/features/auth/models/user.dart';
import 'package:mongez/features/client/home/presentation/screens/categories_screen.dart';
import 'package:mongez/features/worker/home/presentation/cubit/worker_stats_cubit.dart';
import 'package:mongez/features/worker/home/presentation/widgets/incoming_requests.dart';
import 'package:mongez/features/worker/home/presentation/widgets/no_profile_cta.dart';
import 'package:mongez/features/worker/home/presentation/widgets/recent_reviews.dart';
import 'package:mongez/features/worker/home/presentation/widgets/service_summary.dart';
import 'package:mongez/features/worker/home/presentation/widgets/stats_grid.dart';
import 'package:mongez/features/worker/home/presentation/widgets/worker_header_card.dart';
import 'package:mongez/features/worker/requests/presentation/cubit/technician_orders_cubit.dart';
import 'package:mongez/generated/l10n.dart';

/// Worker home — purpose-built for the role.
///
/// Layout, top-down:
///   1. Header card — name, governorate, Verified chip + an
///      Online/Offline switch tied to WorkerProfile.is_available.
///   2. "No profile yet" CTA — only for workers who registered but
///      never completed AddService; tap → AddServiceScreen.
///   3. Stats grid — completed jobs (lifetime + this-month), pending
///      requests, average rating. Live from /api/workers/me/stats/.
///   4. My service summary — profession (en + ar).
///   5. Incoming requests feed — PENDING orders sorted first, tap →
///      OrderDetailsScreen.
///   6. Recent reviews — last 5 customer ratings with stars + text.
///
/// **FAB to place an order** — workers can hire other workers for
/// services outside their own profession. The backend blocks ordering
/// your own profession but allows all other categories.
class WorkerHomeScreen extends StatefulWidget {
  final User user;
  const WorkerHomeScreen({super.key, required this.user});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  // Cached so dispose() doesn't have to touch context — back-pop safe.
  TechnicianOrdersCubit? _ordersCubit;
  WorkerStatsCubit? _statsCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ordersCubit == null) {
      _ordersCubit = context.read<TechnicianOrdersCubit>();
      _ordersCubit!.startPolling();
    }
    if (_statsCubit == null) {
      _statsCubit = context.read<WorkerStatsCubit>();
      _statsCubit!.load();
    }
  }

  @override
  void dispose() {
    _ordersCubit?.stopPolling();
    _ordersCubit = null;
    _statsCubit = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Workers can hire other workers — e.g. a plumber who needs an
      // electrician at home. The backend blocks ordering your own
      // profession; for any other category this just works.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CategoriesScreen(isCustomer: true),
          ),
        ),
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: Text(S.of(context).needAService),
      ),
      // Re-fetch stats whenever the orders cubit emits — covers Accept,
      // Reject, Mark-finished. Counters refresh without waiting for the
      // WorkerStatsCubit's own poll.
      body: BlocListener<TechnicianOrdersCubit, TechnicianOrdersState>(
        listener: (_, _) => _statsCubit?.load(),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              _ordersCubit?.getOrders();
              await _statsCubit?.load();
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: const [
                WorkerHeaderCard(),
                SizedBox(height: 16),
                NoProfileCta(),
                StatsGrid(),
                ServiceSummary(),
                IncomingRequests(),
                RecentReviews(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
