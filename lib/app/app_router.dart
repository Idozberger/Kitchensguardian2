import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodkitchen/app/scan_completion_toast.dart';
import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/config/env.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/logout.dart';
import 'package:foodkitchen/core/dialogs/not_found_404.dart';
import 'package:foodkitchen/core/screens/presentation/pages/country_currency_setup_screen.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/features/auth/data/model/user_model.dart';
import 'package:foodkitchen/features/auth/presentation/pages/login/code_verification_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/login/create_new_password_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/login/forgot_password_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/login/password_changed_success_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/login/signin_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/signup/email_verfied_succes_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/signup/signup_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/signup/verify_email_page.dart';
import 'package:foodkitchen/features/consumptions/presentation/pages/pending_consumptions_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/my_kitchen_members_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/notification_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/recipes_request_details_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/recipes_start_request_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/referral_code_page.dart';
import 'package:foodkitchen/features/grocery/presentation/pages/add_custom_items_page.dart';
import 'package:foodkitchen/features/history/presentation/pages/scan_history_page.dart';
import 'package:foodkitchen/features/home/presentation/pages/item_requests_details/pages/item_requests_detail_page.dart';
import 'package:foodkitchen/features/home/presentation/pages/smart_grocery_list_page.dart';
import 'package:foodkitchen/features/kitchens/presentation/pages/invite_member_page.dart';
import 'package:foodkitchen/features/kitchens/presentation/pages/kitchen_page.dart';
import 'package:foodkitchen/features/kitchens/presentation/pages/kitchen_selection_page.dart';
import 'package:foodkitchen/features/onboarding/presentation/pages/intro_page.dart';
import 'package:foodkitchen/features/onboarding/presentation/pages/onboarding_features_page.dart';
import 'package:foodkitchen/features/onboarding/presentation/pages/splash_screen.dart';
import 'package:foodkitchen/features/pantry/presentation/models/pantry_items.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/add_item_page.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/add_pantry_storage_type_page.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/all_storage_areas_page.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/ingredient_search/ingredient_search_page.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/my_pantry_page.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/receipt_details/receipt_scanned_details_page.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/request_now_page.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/scan_meal_page.dart';
import 'package:foodkitchen/features/planner/domain/entities/ingredient_entity.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';
import 'package:foodkitchen/features/planner/presentation/pages/add_meal_plan/pages/add_meal_page.dart';
import 'package:foodkitchen/features/planner/presentation/pages/edit_meal_page.dart';
import 'package:foodkitchen/features/planner/presentation/pages/favourite_food_page.dart';
import 'package:foodkitchen/features/planner/presentation/pages/generate_recipes_page.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/recipes_details_page.dart';
import 'package:foodkitchen/features/planner/presentation/pages/view_plan_details_page.dart';
import 'package:foodkitchen/features/profile/presentation/pages/change_password_page.dart';
import 'package:foodkitchen/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:foodkitchen/features/profile/presentation/pages/profile_page.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/pages/kitchen_analysis_page.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/pages/smart_kitchen_setup_page.dart';
import 'package:foodkitchen/features/subscription/presentation/pages/subscription_page.dart';
import 'package:go_router/go_router.dart';

part 'app_router_extra_helpers.dart';
part 'app_router_routes_part1.dart';
part 'app_router_routes_part2.dart';
part 'app_router_routes_public.dart';

List<RouteBase> buildAppRouterRoutes() => [
  ...buildPublicRoutes(),
  ShellRoute(
    builder: (context, state, child) => ScanCompletionToast(child: child),
    routes: [...buildAppRouterRoutesPart1(), ...buildAppRouterRoutesPart2()],
  ),
];

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: Routes.splash,
  debugLogDiagnostics: kDebugMode,
  redirect: (context, state) {
    if (state.matchedLocation == Routes.subscription && !Env.billingUiEnabled) {
      return Routes.dashboard;
    }
    return null;
  },
  routes: buildAppRouterRoutes(),
);

CustomTransitionPage buildPage(LocalKey key, Widget child) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOut));

      return SlideTransition(
        position: animation.drive(tween),
        child: RepaintBoundary(child: child),
      );
    },
  );
}
