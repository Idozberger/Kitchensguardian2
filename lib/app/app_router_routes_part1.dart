part of 'package:foodkitchen/app/app_router.dart';

/// Authenticated-area routes (nested under post-login [ShellRoute]; feature blocs from [AuthenticatedFeatureScope] in [AppBase]).
List<RouteBase> buildAppRouterRoutesPart1() => [
  GoRoute(
    name: Routes.dashboard,
    path: Routes.dashboard,
    pageBuilder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;

      return buildPage(
        state.pageKey,
        DashboardPage(
          isFromNotification: readRouteBool(extra, 'fromNotification'),
          entryType: readRouteDashboardEntryType(extra),
        ),
      );
    },
  ),

  GoRoute(
    path: Routes.notification,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, NotificationPage()),
  ),

  GoRoute(
    path: Routes.scanHistory,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, ScanHistoryPage()),
  ),
  GoRoute(
    path: Routes.itemRequestsDetails,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, ItemRequestsDetailPage()),
  ),
  GoRoute(
    path: Routes.recipeStartRequests,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, RecipesStartRequestPage()),
  ),
  GoRoute(
    name: Routes.recipeRequestsDetail,
    path: Routes.recipeRequestsDetail,
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>;
      return RecipesRequestDetailsPage(
        recipeId: readRouteString(extra, 'recipeId'),
        kitchenId: readRouteString(extra, 'kitchenId'),
        backPageAvailable: readRouteBool(
          extra,
          'backPageAvailable',
          fallback: true,
        ),
        isCompleted: readRouteString(extra, 'completed', fallback: 'pending'),
      );
    },
  ),
  GoRoute(
    name: Routes.addItem,
    path: Routes.addItem,
    pageBuilder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;

      return buildPage(
        state.pageKey,
        AddItemPage(
          pantryItems: readRoutePantryItems(extra),
          addToInventory: readRouteBool(extra, 'addToInventory'),
          isMember: readRouteBool(extra, 'isMember'),
          recipeId: readRouteString(extra, 'recipeId'),
          selectedIngredients: readRouteIngredientEntities(extra),
        ),
      );
    },
  ),
  GoRoute(
    path: Routes.myPantry,
    name: Routes.myPantry,
    pageBuilder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;

      return buildPage(
        state.pageKey,
        MyPantryPage(
          type: readRouteString(extra, 'type'),
          itemId: readRouteString(extra, 'item_id'),
        ),
      );
    },
  ),
];
