import 'package:flutter/material.dart';
import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/dialogs/logout.dart';
import 'package:foodkitchen/core/dialogs/no_internet.dart';
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
import 'package:foodkitchen/features/history/presentation/pages/history_page.dart';
import 'package:foodkitchen/features/kitchens/presentation/pages/kitchen_page.dart';
import 'package:foodkitchen/features/onboarding/presentation/pages/intro_page.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/features/onboarding/presentation/pages/splash_screen.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/add_item_page.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/my_pantry_page.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/request_now_page.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/scan_meal_page.dart';
import 'package:foodkitchen/features/planner/presentation/pages/add_meal_page.dart';
import 'package:foodkitchen/features/planner/presentation/pages/edit_meal_page.dart';
import 'package:foodkitchen/features/planner/presentation/pages/favourite_food_page.dart';
import 'package:foodkitchen/features/planner/presentation/pages/generate_recipes_page.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details_page.dart';
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
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(path: Routes.onBoarding, builder: (context, state) => IntroPage()),
    // GoRoute(
    //   path: Routes.languageSelection,
    //   builder: (context, state) => LanguageSelectionPage(),
    // ),
    GoRoute(path: Routes.signIn, builder: (context, state) => SignInPage()),
    GoRoute(path: Routes.signUp, builder: (context, state) => SignUpPage()),
    GoRoute(
      path: Routes.forgotPassword,
      builder: (context, state) => ForgotPasswordPage(),
    ),
    GoRoute(
      name: "reset_password_verification",
      path: Routes.resetPasswordVerification,
      builder: (context, state) {
        final String email = state.extra as String;
        return ResetPasswordVerificationPage(email: email);
      },
    ),

    GoRoute(
      name: "create_new_password",
      path: Routes.createNewPassword,
      builder: (context, state) {
        final String email = state.extra as String;
        return CreateNewPasswordPage(email: email);
      },
    ),
    GoRoute(
      path: Routes.passwordChangedSuccess,
      builder: (context, state) => PasswordChangedSuccessPage(),
    ),
    GoRoute(
      name: "verify_email",
      path: Routes.verifyEmail,
      builder: (context, state) {
        final UserModel userModel = state.extra as UserModel;
        return VerifyEmailPage(userModel: userModel);
      },
    ),
    GoRoute(
      path: Routes.emailVerifiedSuccess,
      builder: (context, state) => EmailVerfiedSuccesPage(),
    ),
    GoRoute(
      path: Routes.dashboard,
      builder: (context, state) => DashboardPage(),
    ),
    GoRoute(
      path: Routes.notification,
      builder: (context, state) => NotificationPage(),
    ),
    GoRoute(
      path: Routes.scanHistory,
      builder: (context, state) => ScanHistoryPage(),
    ),
    GoRoute(path: Routes.addItem, builder: (context, state) => AddItemPage()),
    GoRoute(path: Routes.myPantry, builder: (context, state) => MyPantryPage()),
    GoRoute(path: Routes.scanMeal, builder: (context, state) => ScanMealPage()),
    GoRoute(path: Routes.kitchen, builder: (context, state) => KitchenPage()),
    GoRoute(path: Routes.profile, builder: (context, state) => ProfilePage()),
    GoRoute(
      path: Routes.editProfile,
      builder: (context, state) => EditProfilePage(),
    ),
    GoRoute(
      path: Routes.changePassword,
      builder: (context, state) => ChangePasswordPage(),
    ),
    GoRoute(path: Routes.addMeal, builder: (context, state) => AddMealPage()),
    GoRoute(
      name: Routes.editMeal,
      path: Routes.editMeal,
      builder: (context, state) {
        final MealTypeEntity mealTypeEntity = state.extra as MealTypeEntity;
        return EditMealPage(mealTypeEntity: mealTypeEntity);
      },
    ),
    GoRoute(
      name: Routes.generateRecipes,
      path: Routes.generateRecipes,
      builder: (context, state) {
        final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
        return GenerateRecipesPage(
          selectedDate: data["selected_date"],
          selectedMealType: data["selected_meal_type"],
          isPlan: data["is_plan"],
        );
      },
    ),

    GoRoute(
      name: Routes.generateRecipesDetails,
      path: Routes.generateRecipesDetails,
      builder: (context, state) {
        final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
        MealTypeEntity mealTypeEntity = data["meal_type_entity"];
        bool isPlan = data["is_plan"];
        return RecipesDetailsPage(
          mealTypeEntity: mealTypeEntity,
          isPlan: isPlan,
        );
      },
    ),
    GoRoute(
      path: Routes.favouriteFood,
      builder: (context, state) => FavouriteFoodPage(),
    ),
    GoRoute(
      path: Routes.myKitchenMembers,
      builder: (context, state) => MyKitchenMembersPage(),
    ),
    GoRoute(
      path: Routes.subscription,
      builder: (context, state) => SubscriptionPage(),
    ),
    GoRoute(path: Routes.logout, builder: (context, state) => LogoutDialog()),
    GoRoute(
      path: Routes.notFound404,
      builder: (context, state) => NotFound404Dialog(),
    ),
    GoRoute(
      path: Routes.requestNow,
      builder: (context, state) => RequestNowPage(),
    ),
  ],
);
