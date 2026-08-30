import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongez/features/client/home/presentation/cubit/categories_cubit.dart';
import 'package:mongez/features/client/home/presentation/widgets/custom_category.dart';
import 'package:mongez/features/client/home/presentation/screens/search_screen.dart';
import 'package:mongez/core/widgets/skeletons/skeleton_category.dart';

class CategoryList extends StatelessWidget {
  final bool isCustomer;

  const CategoryList({super.key, this.isCustomer = true});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              height: width * 0.34,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: 5,
                itemBuilder: (_, _) => const SkeletonCategory(),
              ),
            ),
          );
        }

        if (state is CategoriesFailure) {
          return Center(child: Text(state.errorMessage));
        }

        if (state is CategoriesSuccess) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              height: width * 0.34,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: state.categories.length,
                itemBuilder: (_, index) {
                  final category = state.categories[index];
                  return CustomCategory(
                    category: category,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SearchScreen(
                            initialCategoryId: category.id,
                            initialCategoryName: category.name,
                            isCustomer: isCustomer,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
