part of 'package:foodkitchen/app/app_router.dart';

List<RouteBase> buildAppRouterRoutesPart2() => [
  GoRoute(
    path: Routes.scanMeal,
    pageBuilder: (context, state) => buildPage(state.pageKey, ScanMealPage()),
  ),
  GoRoute(
    path: Routes.kitchen,
    pageBuilder: (context, state) => buildPage(state.pageKey, KitchenPage()),
  ),
  GoRoute(
    path: Routes.profile,
    pageBuilder: (context, state) => buildPage(state.pageKey, ProfilePage()),
  ),
  GoRoute(
    path: Routes.editProfile,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, EditProfilePage()),
  ),
  GoRoute(
    path: Routes.changePassword,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, ChangePasswordPage()),
  ),
  GoRoute(
    path: Routes.addMeal,
    pageBuilder: (context, state) => buildPage(state.pageKey, AddMealPage()),
  ),
  GoRoute(
    path: Routes.editMeal,
    pageBuilder: (context, state) => buildPage(state.pageKey, EditMealPage()),
  ),
  GoRoute(
    name: Routes.pendingconsumptionconfirmation,
    path: Routes.pendingconsumptionconfirmation,
    pageBuilder: (context, state) {
      final String kitchenId = state.extra as String;
      return buildPage(
        state.pageKey,
        PendingConsumptionsPage(kitchenId: kitchenId),
      );
    },
  ),
  GoRoute(
    name: Routes.generateRecipes,
    path: Routes.generateRecipes,
    pageBuilder: (context, state) {
      final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
      return buildPage(
        state.pageKey,
        GenerateRecipesPage(
          selectedDate: readRouteString(data, 'selected_date'),
          selectedMealType: readRouteString(data, 'selected_meal_type'),
          isPlan: readRouteBool(data, 'is_plan'),
          isEdit: readRouteBool(data, 'is_edit'),
        ),
      );
    },
  ),
  GoRoute(
    name: Routes.generateRecipesDetails,
    path: Routes.generateRecipesDetails,
    pageBuilder: (context, state) {
      devLog("Recipe is in progress: []");
      final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
      devLog("Recipe is in progress: [${data["meal_type_entity"]}]");
      return buildPage(
        state.pageKey,
        RecipesDetailsPage(
          isRequestToStartRecipe: readRouteBool(
            data,
            'is_request_to_start_recipe',
          ),
          recipeEntity: data['meal_type_entity'] as RecipeEntity,
          isPlan: readRouteBool(data, 'is_plan'),
          isEdit: readRouteBool(data, 'is_edit'),
        ),
      );
    },
  ),
  GoRoute(
    path: Routes.favouriteFood,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, FavouriteFoodPage()),
  ),
  GoRoute(
    path: Routes.myKitchenMembers,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, MyKitchenMembersPage()),
  ),
  GoRoute(
    path: Routes.subscription,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, SubscriptionPage()),
  ),
  GoRoute(
    path: Routes.requestNow,
    pageBuilder: (context, state) => buildPage(state.pageKey, RequestNowPage()),
  ),
  GoRoute(
    name: Routes.capturedImageDetails,
    path: Routes.capturedImageDetails,
    pageBuilder: (context, state) {
      final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
      return buildPage(
        state.pageKey,
        CaptureDetailsPage(imagePath: readRouteString(data, 'image_path')),
      );
    },
  ),
  GoRoute(
    path: Routes.addCustomItem,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, AddCustomItemsPage()),
  ),
  GoRoute(
    name: Routes.viewPlanDetails,
    path: Routes.viewPlanDetails,
    pageBuilder: (context, state) {
      final MergedRecipePlanEntity mergedRecipePlanEntity =
          state.extra as MergedRecipePlanEntity;
      return buildPage(
        state.pageKey,
        ViewPlanDetailsPage(mergedRecipePlanEntity: mergedRecipePlanEntity),
      );
    },
  ),
  GoRoute(
    path: Routes.referralPage,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, ReferralCodePage()),
  ),
  GoRoute(
    path: Routes.inviteMember,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, InviteMemberPage()),
  ),
  GoRoute(
    path: Routes.addPantryStorageType,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, AddPantryStorageTypePage()),
  ),
  GoRoute(
    path: Routes.allStorageArea,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, AllPantryStoragePage()),
  ),
  GoRoute(
    path: Routes.smartCart,
    pageBuilder: (context, state) => buildPage(state.pageKey, SmartCartPage()),
  ),
  GoRoute(
    path: Routes.kitchenSelection,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, KitchenSelectionPage()),
  ),
  GoRoute(
    path: Routes.kitchenAnalysisPage,
    pageBuilder: (context, state) =>
        buildPage(state.pageKey, KitchenAnalysisPage()),
  ),
  GoRoute(
    name: Routes.smartKitchenSetup,
    path: Routes.smartKitchenSetup,
    pageBuilder: (context, state) {
      final bool isRescanning = state.extra as bool;
      return buildPage(
        state.pageKey,
        SmartKitchenSetupPage(isRescanning: isRescanning),
      );
    },
  ),
];
