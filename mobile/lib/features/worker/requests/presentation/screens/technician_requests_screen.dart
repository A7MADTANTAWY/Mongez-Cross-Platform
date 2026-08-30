import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongez/features/worker/requests/presentation/cubit/technician_orders_cubit.dart';
import 'package:mongez/features/client/order/presentation/screens/order_details_screen.dart';
import 'package:mongez/features/client/order/presentation/widgets/order_card.dart';
import 'package:mongez/features/shared/profile/presentation/cubit/profile_cubit.dart';
import 'package:mongez/generated/l10n.dart';
import 'package:mongez/core/widgets/custom_app_bar.dart';
import 'package:mongez/core/widgets/skeletons/skeleton_order_card.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  // Cached so dispose() never reads from `context` — a logout flow can
  // tear down the BlocProvider on the same frame the route is popped.
  TechnicianOrdersCubit? _cubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _cubit?.loadMore();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit ??= context.read<TechnicianOrdersCubit>();
    // Start a 15 s background poll so a freshly placed client order or
    // a dashboard-driven status change lands here without manual refresh.
    _cubit!.startPolling();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cubit?.stopPolling();
    _cubit = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    return Scaffold(
      appBar: CustomAppBar(title: lang.requests),
      body: BlocBuilder<TechnicianOrdersCubit, TechnicianOrdersState>(
        builder: (context, state) {
          if (state is TechnicianOrdersInitial || state is TechnicianOrdersLoading) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (context, index) => const SkeletonOrderCard(),
            );
          }
          if (state is TechnicianOrdersEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(lang.noPendingRequests),
                ],
              ),
            );
          }
          if (state is TechnicianOrdersFailure) {
            return Center(child: Text(state.errorMessage));
          }
          if (state is TechnicianOrdersSuccess) {
            final orders = state.orders;
            final currentUserId = (context.read<ProfileCubit>().state is ProfileSuccess)
                ? (context.read<ProfileCubit>().state as ProfileSuccess).profile.id
                : -1;
            return RefreshIndicator(
              onRefresh: () => context.read<TechnicianOrdersCubit>().getOrders(),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final isCustomer = order.clientId == currentUserId;
                  return OrderCard(
                    order: order,
                    isCustomer: isCustomer,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsScreen(
                            order: order,
                            isCustomer: isCustomer,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
