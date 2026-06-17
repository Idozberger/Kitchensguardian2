import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:lottie/lottie.dart';

class RecipesRequestDetailsLoadingView extends StatelessWidget {
  const RecipesRequestDetailsLoadingView({
    super.key,
    required this.recipeId,
    required this.kitchenId,
  });

  final String recipeId;
  final String kitchenId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (_, state) {
        if (state is DashboardFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.read<DashboardBloc>().add(
                    GetRecipeDetailsEvent(
                      recipeId: recipeId,
                      kitchenId: kitchenId,
                    ),
                  ),
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }
        return Center(child: Lottie.asset("assets/lotties/loader.json"));
      },
    );
  }
}
