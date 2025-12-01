import 'package:flutter/material.dart';
import 'package:foodkitchen/core/dialogs/logout.dart';
import 'package:foodkitchen/core/dialogs/not_found_404.dart';
import 'package:foodkitchen/features/auth/data/model/user_model.dart';
import 'package:foodkitchen/features/auth/presentation/pages/login/create_new_password_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/login/forgot_password_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/login/password_changed_success_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/login/code_verification_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/login/signin_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/signup/email_verfied_succes_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/signup/signup_page.dart';
import 'package:foodkitchen/features/auth/presentation/pages/signup/verify_email_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/my_kitchen_members_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/notification_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/referral_code_page.dart';
import 'package:foodkitchen/features/grocery/presentation/pages/add_custom_items_page.dart';
import 'package:foodkitchen/features/history/presentation/pages/scan_history_page.dart';
import 'package:foodkitchen/features/home/presentation/pages/grocery_list_page.dart';
import 'package:foodkitchen/features/kitchens/presentation/pages/invite_member_page.dart';
import 'package:foodkitchen/features/kitchens/presentation/pages/kitchen_page.dart';
import 'package:foodkitchen/features/onboarding/presentation/pages/intro_page.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/features/onboarding/presentation/pages/splash_screen.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/add_item_page.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/add_pantry_storage_type_page.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/all_storage_areas_page.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/my_pantry_page.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/receipt_details/capture_details_page.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/request_now_page.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/scan_meal_page.dart';
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
import 'package:foodkitchen/features/subscription/presentation/pages/subscription_page.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      pageBuilder: (context, state) =>
          buildPage(state.pageKey, const SplashScreen()),
    ),
    GoRoute(
      path: Routes.onBoarding,
      pageBuilder: (context, state) => buildPage(state.pageKey, IntroPage()),
    ),
    GoRoute(
      path: Routes.signIn,
      pageBuilder: (context, state) => buildPage(state.pageKey, SignInPage()),
    ),
    GoRoute(
      path: Routes.signUp,
      pageBuilder: (context, state) => buildPage(state.pageKey, SignUpPage()),
    ),
    GoRoute(
      path: Routes.forgotPassword,
      pageBuilder: (context, state) =>
          buildPage(state.pageKey, ForgotPasswordPage()),
    ),
    GoRoute(
      name: "reset_password_verification",
      path: Routes.resetPasswordVerification,
      pageBuilder: (context, state) {
        final String email = state.extra as String;
        return buildPage(
          state.pageKey,
          ResetPasswordVerificationPage(email: email),
        );
      },
    ),
    GoRoute(
      name: "create_new_password",
      path: Routes.createNewPassword,
      pageBuilder: (context, state) {
        final String email = state.extra as String;
        return buildPage(state.pageKey, CreateNewPasswordPage(email: email));
      },
    ),
    GoRoute(
      path: Routes.passwordChangedSuccess,
      pageBuilder: (context, state) =>
          buildPage(state.pageKey, PasswordChangedSuccessPage()),
    ),
    GoRoute(
      name: "verify_email",
      path: Routes.verifyEmail,
      pageBuilder: (context, state) {
        final UserModel userModel = state.extra as UserModel;
        return buildPage(state.pageKey, VerifyEmailPage(userModel: userModel));
      },
    ),
    GoRoute(
      path: Routes.emailVerifiedSuccess,
      pageBuilder: (context, state) =>
          buildPage(state.pageKey, EmailVerfiedSuccesPage()),
    ),
    GoRoute(
      path: Routes.dashboard,
      pageBuilder: (context, state) =>
          buildPage(state.pageKey, DashboardPage()),
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
      path: Routes.addItem,
      pageBuilder: (context, state) => buildPage(state.pageKey, AddItemPage()),
    ),
    GoRoute(
      path: Routes.myPantry,
      pageBuilder: (context, state) => buildPage(state.pageKey, MyPantryPage()),
    ),
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
      name: Routes.generateRecipes,
      path: Routes.generateRecipes,
      pageBuilder: (context, state) {
        final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
        return buildPage(
          state.pageKey,
          GenerateRecipesPage(
            selectedDate: data["selected_date"],
            selectedMealType: data["selected_meal_type"],
            isPlan: data["is_plan"],
            isEdit: data["is_edit"],
          ),
        );
      },
    ),
    GoRoute(
      name: Routes.generateRecipesDetails,
      path: Routes.generateRecipesDetails,
      pageBuilder: (context, state) {
        final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
        return buildPage(
          state.pageKey,
          RecipesDetailsPage(
            recipeEntity: data["meal_type_entity"],
            isPlan: data["is_plan"],
            isEdit: data["is_edit"],
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
      path: Routes.logout,
      pageBuilder: (context, state) => buildPage(state.pageKey, LogoutDialog()),
    ),
    GoRoute(
      path: Routes.notFound404,
      pageBuilder: (context, state) =>
          buildPage(state.pageKey, NotFound404Dialog()),
    ),
    GoRoute(
      path: Routes.requestNow,
      pageBuilder: (context, state) =>
          buildPage(state.pageKey, RequestNowPage()),
    ),
    GoRoute(
      name: Routes.capturedImageDetails,
      path: Routes.capturedImageDetails,
      pageBuilder: (context, state) {
        final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
        return buildPage(
          state.pageKey,
          CaptureDetailsPage(imagePath: data["image_path"]),
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
      pageBuilder: (context, state) =>
          buildPage(state.pageKey, SmartCartPage()),
    ),
  ],
);

CustomTransitionPage buildPage(LocalKey key, Widget child) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(animation);
      final fade = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
