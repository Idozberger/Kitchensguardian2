import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/app/di.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/navigation/router_navigation.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/planner/domain/datasources/recipe_start_request_firestore_datasource.dart';
import 'package:go_router/go_router.dart';

part 'recipes_start_request_page_part.dart';

class RecipesStartRequestPage extends StatefulWidget {
  final bool showAppbar;
  const RecipesStartRequestPage({super.key, this.showAppbar = true});

  @override
  State<RecipesStartRequestPage> createState() =>
      _RecipesStartRequestPageState();
}

class _RecipesStartRequestPageState extends State<RecipesStartRequestPage> {
  late final UserCubit _userCubit;
  late final Stream<List<Map<String, dynamic>>> _requestsStream;

  @override
  void initState() {
    super.initState();
    _userCubit = context.read<UserCubit>();
    _requestsStream = sl<RecipeStartRequestFirestoreDatasource>()
        .watchRecipeStartRequestsForKitchen(_userCubit.state.activeKitchenId);
    devLog("User id ${_userCubit.state.userId}");
  }

  List<Map<String, dynamic>> _filterRequests(List<Map<String, dynamic>> items) {
    return items.where((data) {
      final status = data['status'] ?? false;
      final kitchenId = data['kitchen_id'];
      if (status == true) return true;
      return kitchenId == _userCubit.state.activeKitchenId;
    }).toList();
  }

  void _handleBackNavigation() {
    goNamedAfterFrame(
      name: Routes.dashboard,
      extra: {
        'fromNotification': false,
        'entryType': DashboardEntryType.normal,
      },
      isPageMounted: () => mounted,
      pageContext: () => context,
    );
  }

  void _onCardTap(Map<String, dynamic> data) {
    devLog("RecipeId: ${data["recipe_id"]}");
    context.pushNamed(
      Routes.recipeRequestsDetail,
      extra: {
        'recipeId': data['recipe_id'] ?? '',
        'kitchenId': data['kitchen_id'] ?? '',
        'completed': data['recipe_status'] ?? 'pending',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          await Future<void>.delayed(Duration.zero);
          _handleBackNavigation();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF9F9F9),
        appBar: widget.showAppbar
            ? buildRecipesStartRequestAppBar(context)
            : null,
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _requestsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final filtered = snapshot.hasData
                ? _filterRequests(snapshot.data!)
                : <Map<String, dynamic>>[];

            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_menu_outlined,
                      size: 52,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "No recipe requests yet",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: Colors.grey.shade400),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: gapSymmetric(horizontal: 12, vertical: 12),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final Map<String, dynamic> data = filtered[index];

                return RecipeStartRequestCard(
                  senderName: readJsonString(data, 'sender_name'),
                  title: readJsonString(data, 'title'),
                  body: readJsonString(data, 'body'),
                  date: readJsonString(data, 'date'),
                  status: readJsonString(data, 'recipe_status'),
                  onTap: () => _onCardTap(data),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
