import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongez/core/di/services_locator.dart';
import 'package:mongez/features/client/address/data/repositories/address_repository.dart';
import 'package:mongez/features/client/home/presentation/screens/categories_screen.dart';
import 'package:mongez/features/client/home/presentation/screens/details_view.dart';
import 'package:mongez/features/client/home/presentation/widgets/home_sliver_app_bar.dart';
import 'package:mongez/features/client/home/presentation/widgets/service_card.dart';
import 'package:mongez/features/client/home/presentation/widgets/custom_category_list.dart';
import 'package:mongez/features/auth/models/user.dart';
import 'package:mongez/features/client/home/presentation/screens/search_screen.dart';
import 'package:mongez/features/client/home/presentation/cubit/workers_cubit.dart';
import 'package:mongez/generated/l10n.dart';
import 'package:mongez/core/widgets/custom_section.dart';
import 'package:mongez/core/widgets/search_bar_ui.dart';
import 'package:mongez/core/widgets/skeletons/skeleton_service_card.dart';

class HomeScreen extends StatelessWidget {
  final bool isCustomer;
  final User user;
  const HomeScreen({super.key, required this.isCustomer, required this.user});

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              context.read<WorkersCubit>().refresh(),
              getIt<AddressRepository>().load(),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              CustomSliverAppBarHome(user: user, isCustomer: isCustomer),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      SearchFieldUI(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SearchScreen(isCustomer: isCustomer),
                            ),
                          );
                        },
                      ),
                      isCustomer
                          ? CustomSection(
                              title: lang.category,
                              actionText: lang.viewAll,
                              onActionTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CategoriesScreen(
                                      isCustomer: isCustomer,
                                    ),
                                  ),
                                );
                              },
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
              isCustomer
                  ? SliverToBoxAdapter(
                      child: CategoryList(isCustomer: isCustomer),
                    )
                  : const SliverToBoxAdapter(child: SizedBox()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: CustomSection(
                    title: isCustomer ? lang.hotDeals : lang.myServices,
                  ),
                ),
              ),
              BlocBuilder<WorkersCubit, WorkersState>(
                builder: (context, state) {
                  if (state is WorkersLoading) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          child: const SkeletonServiceCard(),
                        );
                      }, childCount: 3),
                    );
                  }
                  if (state is WorkersFailure) {
                    return SliverToBoxAdapter(
                      child: Center(child: Text(state.errorMessage)),
                    );
                  }
                  if (state is WorkersSuccess) {
                    final workers = state.workers;
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final worker = workers[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailsView(
                                    worker: worker,
                                    isCustomer: isCustomer,
                                  ),
                                ),
                              );
                            },
                            child: ServiceCard(
                              worker: worker,
                              isCustomer: isCustomer,
                            ),
                          ),
                        );
                      }, childCount: workers.length),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
