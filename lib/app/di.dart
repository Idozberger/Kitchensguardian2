import 'package:dio/dio.dart';
import 'package:foodkitchen/core/common/cubits/app_cubit.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/data/datasource/common_remote_datasource.dart';
import 'package:foodkitchen/core/common/data/datasource/profile_local_datasource.dart';
import 'package:foodkitchen/core/services/connection/connection_checker.dart';
import 'package:foodkitchen/core/services/jwt_decoder/jwt_decoder.dart';
import 'package:foodkitchen/core/services/notifications/flutter_local_notifications_service.dart';
import 'package:foodkitchen/features/auth/data/data_source/auth_remote_datasource.dart';
import 'package:foodkitchen/features/auth/data/repository/auth_repository_impl.dart';
import 'package:foodkitchen/features/auth/domain/repository/auth_repository.dart';
import 'package:foodkitchen/features/auth/domain/usecase/apple_sign_in_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/apple_sign_up_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/google_sign_in_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/google_signup_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/send_password_reset_email_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/send_user_email_verification_code_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/set_user_new_password_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/user_sign_in_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/user_sign_up_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/verify_user_email_usecase.dart';
import 'package:foodkitchen/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:foodkitchen/core/common/data/datasource/current_user_remote_datasource.dart';
import 'package:foodkitchen/core/common/data/repositories/current_user_respository_impl.dart';
import 'package:foodkitchen/core/common/domain/repository/current_user_repository.dart';
import 'package:foodkitchen/core/common/domain/usecase/get_current_user.dart';
import 'package:foodkitchen/features/consumptions/data/datasource/consumption_remote_datasource.dart';
import 'package:foodkitchen/features/consumptions/data/repository/consumption_repository_impl.dart';
import 'package:foodkitchen/features/consumptions/domain/repository/consumption_repository.dart';
import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_bloc.dart';
import 'package:foodkitchen/features/dashboard/data/datasource/dashboard_remote_datasource.dart';
import 'package:foodkitchen/features/dashboard/data/repository/dashboard_repository_impl.dart';
import 'package:foodkitchen/features/dashboard/domain/repository/dashboard_repository.dart';
import 'package:foodkitchen/features/consumptions/domain/usecases/get_consumption_confirmation_count.dart';
import 'package:foodkitchen/features/consumptions/domain/usecases/get_consumption_confirmation_pending.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/demote_cohost.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/get_kitchen_members.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/get_recipe_details.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/kick_member.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/make_cohost.dart';
import 'package:foodkitchen/features/consumptions/domain/usecases/respond_consumption_confirmation.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:foodkitchen/features/grocery/data/datasource/grocery_remote_datasource.dart';
import 'package:foodkitchen/features/grocery/data/repository/grocery_repository_impl.dart';
import 'package:foodkitchen/features/grocery/domain/repository/grocery_repository.dart';
import 'package:foodkitchen/features/grocery/domain/usecases/add_custom_item.dart';
import 'package:foodkitchen/features/grocery/domain/usecases/add_mylist_to_inventory.dart';
import 'package:foodkitchen/features/grocery/domain/usecases/delete_kitchen_items.dart';
import 'package:foodkitchen/features/grocery/domain/usecases/get_ai_generated_items.dart';
import 'package:foodkitchen/features/grocery/domain/usecases/get_requested_items.dart';
import 'package:foodkitchen/features/grocery/domain/usecases/update_bucket_type.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/history/data/datasource/scan_history_remote_datasource.dart';
import 'package:foodkitchen/features/history/data/repository/scan_history_repository_impl.dart';
import 'package:foodkitchen/features/history/domain/repository/scan_history_repository.dart';
import 'package:foodkitchen/features/history/domain/usecases/get_scan_history_usecase.dart';
import 'package:foodkitchen/features/history/presentation/bloc/scan_history_cubit.dart';
import 'package:foodkitchen/features/home/data/datasource/home_remote_datasource.dart';
import 'package:foodkitchen/features/home/data/repository/home_repository_impl.dart';
import 'package:foodkitchen/features/home/domain/repository/home_repository.dart';
import 'package:foodkitchen/features/home/domain/usecases/create_kitchen_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/get_all_requested_items.dart';
import 'package:foodkitchen/features/home/domain/usecases/get_recipe_suggestion_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/respond_to_item_request.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/add_pantry_request_item.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/cart_items.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/create_pantry_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/get_all_weekly_plans_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/get_pantries_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/join_kitchen_usecase.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/kitchens/data/datasource/kitchen_remote_datasource.dart';
import 'package:foodkitchen/features/kitchens/data/repository/kitchen_repository_impl.dart';
import 'package:foodkitchen/features/kitchens/domain/repository/kitchen_repository.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/create_kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/get_kitchens.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/invite_user.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/join_kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/leave_kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/remove_kitchen.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_bloc.dart';
import 'package:foodkitchen/features/onboarding/presentation/bloc/user_bloc.dart';
import 'package:foodkitchen/features/pantry/data/datasource/pantry_remote_datasource.dart';
import 'package:foodkitchen/features/pantry/data/repository/pantry_repository_impl.dart';
import 'package:foodkitchen/features/pantry/domain/repository/pantry_repository.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/add_pantry_item.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/delete_item.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/delete_pantry.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/get_pantry_items.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/get_storage_area.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/request_items.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/scan_receipt.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/show_notification.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/update_item.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/planner/data/datasource/planner_local_datasource.dart';
import 'package:foodkitchen/features/planner/data/datasource/planner_remote_datasource.dart';
import 'package:foodkitchen/features/planner/data/repository/planner_repository_impl.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:foodkitchen/features/planner/domain/usecases/add_to_favourite_recipe.dart';
import 'package:foodkitchen/features/planner/domain/usecases/add_to_weekly_plan.dart';
import 'package:foodkitchen/features/planner/domain/usecases/create_plan.dart';
import 'package:foodkitchen/features/planner/domain/usecases/delete_meal_type_from_weekly_plan.dart';
import 'package:foodkitchen/features/planner/domain/usecases/delete_plan.dart';
import 'package:foodkitchen/features/planner/domain/usecases/delete_plan_remote_db.dart';
import 'package:foodkitchen/features/planner/domain/usecases/favourite_recipes.dart';
import 'package:foodkitchen/features/planner/domain/usecases/generate_recipes.dart';
import 'package:foodkitchen/features/planner/domain/usecases/get_all_plans.dart';
import 'package:foodkitchen/features/planner/domain/usecases/get_all_weekly_plans.dart';
import 'package:foodkitchen/features/planner/domain/usecases/get_date_range.dart';
import 'package:foodkitchen/features/planner/domain/usecases/get_meal_by_date.dart';
import 'package:foodkitchen/features/planner/domain/usecases/mark_recipe_finished.dart';
import 'package:foodkitchen/features/planner/domain/usecases/remove_from_favourite_recipe.dart';
import 'package:foodkitchen/features/planner/domain/usecases/request_missing_items.dart';
import 'package:foodkitchen/features/planner/domain/usecases/set_date_range.dart';
import 'package:foodkitchen/features/planner/domain/usecases/update_meal_plan.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/profile/data/datasource/profile_remote_datasource.dart';
import 'package:foodkitchen/features/profile/data/repository/profile_repository_impl.dart';
import 'package:foodkitchen/features/profile/domain/repository/profile_repository.dart';
import 'package:foodkitchen/features/profile/domain/usecases/change_password.dart';
import 'package:foodkitchen/features/profile/domain/usecases/edit_profile.dart';
import 'package:foodkitchen/features/profile/domain/usecases/get_profile_picture.dart';
import 'package:foodkitchen/features/profile/domain/usecases/set_profile_picture.dart';
import 'package:foodkitchen/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:foodkitchen/features/smart_kitcheb_setup/data/datasource/smart_kitchen_setup_datasource.dart';
import 'package:foodkitchen/features/smart_kitcheb_setup/data/repository/smart_kitchen_setup_repo_impl.dart';
import 'package:foodkitchen/features/smart_kitcheb_setup/domain/repository/smart_kitchen_setup_repository.dart';
import 'package:foodkitchen/features/smart_kitcheb_setup/domain/usecases/scan_kitchen_images.dart';
import 'package:foodkitchen/features/smart_kitcheb_setup/domain/usecases/skip_kitchen_setup.dart';
import 'package:foodkitchen/features/smart_kitcheb_setup/presentation/bloc/smart_kitchen_setup_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final dartJwtCoder = DartJwtDecoder();
  sl.registerFactory(() => sharedPreferences);
  sl.registerFactory(() => dartJwtCoder);
  sl.registerFactory(() => InternetConnection());
  sl.registerFactory<ConnectionChecker>(() => ConnectionCheckerImpl(sl()));
  _initCommonRemoteRepo();
  _dioInjection();
  _initOnboarding();
  _initHome();
  _initConsumption();
  _initAuth();

  _initDashboard();
  _initSmartKitchenSetup();
  _initKitchen();
  _initPantry();
  _initGrocery();
  _initPlanner();
  _initHistory();
  _initProfile();
  _initAppCubit();
}

void _initSmartKitchenSetup() {
  // Datasource
  sl.registerLazySingleton<SmartKitchenSetupDatasource>(
    () => SmartKitchenSetupDatasourceImpl(dio: sl<DioHelper>()),
  );

  // Repository
  sl.registerLazySingleton<SmartKitchenSetupRepository>(
    () => SmartKitchenSetupRepositoryImpl(
      smartKitchenSetupDatasource: sl<SmartKitchenSetupDatasource>(),
    ),
  );

  // Use Case
  sl.registerFactory(() => ScanKitchenImagesUseCase(sl()));
  sl.registerFactory(() => SkipKitchenSetup(sl()));

  // Bloc
  sl.registerFactory<SmartKitchenSetupBloc>(
    () => SmartKitchenSetupBloc(
      scanKitchenImagesUseCase: sl(),
      skipKitchenSetup: sl(),
      userCubit: sl(),
    ),
  );
}

void _initAppCubit() {
  sl.registerLazySingleton<AppCubit>(() => AppCubit());
}

void _dioInjection() {
  sl.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        validateStatus: (status) => true,
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30), // max wait to connect
        receiveTimeout: const Duration(seconds: 60), // max wait for response
        sendTimeout: const Duration(seconds: 30), // max wait to send request
      ),
    ),
  );

  sl.registerLazySingleton<DioHelper>(() => DioHelper(sl()));
}

void _initOnboarding() async {
  // Datasource
  sl
    ..registerFactory<CurrentUserRemoteDatasource>(
      () => CurrentUserRemoteDataSourceImpl(sl(), sl(), sl()),
    )
    // Repository
    ..registerFactory<CurrentUserRepository>(
      () => CurrentUserRepositoryImpl(sl(), sl()),
    )
    // Usecases
    ..registerFactory(() => GetCurrentUserUseCase(sl()))
    // Cubit
    ..registerLazySingleton(
      () => UserCubit(
        commonRemoteDatasource: CommonRemoteDatasourceImpl(dio: sl()),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => UserBloc(
        getCurrentUser: sl(),
        userCubit: sl(),
        sharedPreference: sl(),
      ),
    );
}

void _initAuth() async {
  // Datasource
  sl
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDatasourceImpl(
        connectionChecker: sl(),
        dio: sl(),
        sharedPreferences: sl(),
        userCubit: sl(),
      ),
    )
    // Repository
    ..registerFactory<AuthRepository>(() => AuthRepositoryImpl(sl()))
    // Usecases
    ..registerFactory(() => UserSignUp(sl()))
    // Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        googleSignIn: GoogleSignInUsecase(sl()),
        googleSignup: GoogleSignupUsecase(sl()),
        userSignUp: UserSignUp(sl()),
        sendUserEmailVerificationCode: SendUserEmailVerificationCode(sl()),
        userSignIn: UserSignIn(sl()),
        sendPasswordResetEmail: SendPasswordResetEmail(sl()),
        setUserNewPassword: SetUserNewPassword(sl()),
        verifyUserEmail: VerifyUserEmail(sl()),
        userCubit: sl(),
        getCurrentUser: GetCurrentUserUseCase(sl()),
        appleSignIn: AppleSignInUsecase(sl()),
        appleSignUp: AppleSignUpUsecase(sl()),
      ),
    );
}

void _initHome() async {
  // Datasource
  sl
    ..registerFactory<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(dio: sl(), sharedPreferences: sl()),
    )
    // Repository
    ..registerFactory<HomeRepository>(
      () => HomeRepositoryImpl(
        homeRemoteDataSource: sl(),
        commonRemoteDatasource: sl(),
      ),
    )
    // Usecases
    ..registerFactory(() => CreateKitchen(sl()))
    ..registerFactory(() => JoinKitchen(sl()))
    ..registerFactory(() => GetPantriesForHome(sl()))
    ..registerFactory(() => GetAllWeeklyPlansForHome(sl()))
    ..registerFactory(() => GetRecipeSuggestionUsecase(sl()))
    ..registerFactory(() => RespondToItemRequest(sl()))
    // Bloc
    ..registerLazySingleton(
      () => HomeBloc(
        createKitchen: CreateKitchen(sl()),
        joinKitchen: JoinKitchen(sl()),
        userCubit: sl(),
        getPantriesForHome: GetPantriesForHome(sl()),
        getAllWeeklyPlansForHome: GetAllWeeklyPlansForHome(sl()),
        getRecipeSuggestionUsecase: GetRecipeSuggestionUsecase(sl()),
        getAllRequestedItems: GetAllRequestedItems(sl()),
        respondToItemRequest: RespondToItemRequest(sl()),
      ),
    );
}

void _initKitchen() async {
  // Datasource
  sl
    ..registerFactory<KitchenRemoteDatasource>(
      () => KitchenRemoteDataSourceImpl(sl(), sl()),
    )
    // Repository
    ..registerFactory<KitchenRepository>(() => KitchenRepositoryImpl(sl()))
    // Usecases
    ..registerFactory(() => GetKitchens(sl()))
    ..registerFactory(() => CreateKitchenUseCase(sl()))
    ..registerFactory(() => JoinKitchenUseCase(sl()))
    ..registerFactory(() => LeaveKitchenUsecase(sl()))
    ..registerFactory(() => RemoveKitchenUsecase(sl()))
    ..registerFactory(() => InviteUser(sl()))
    // Bloc
    ..registerLazySingleton(
      () => KitchenBloc(
        userCubit: sl(),
        getKitchens: GetKitchens(sl()),
        createKitchen: CreateKitchenUseCase(sl()),
        joinKitchen: JoinKitchenUseCase(sl()),
        leaveKitchenUsecase: LeaveKitchenUsecase(sl()),
        removeKitchenUsecase: RemoveKitchenUsecase(sl()),
        inviteUser: InviteUser(sl()),
        homeBloc: sl(),
        plannerBloc: sl(),
        groceryBloc: sl(),
      ),
    );
}

void _initDashboard() async {
  // Datasource

  sl
    ..registerFactory<DashboardRemoteDatasource>(
      () => DashboardRemoteDatasourceImpl(sl()),
    )
    // Repository
    ..registerFactory<DashboardRepository>(() => DashboardRepositoryImpl(sl()))
    // Usecases
    ..registerFactory(() => GetKitchenMembers(sl()))
    ..registerFactory(() => MakeCohost(sl()))
    ..registerFactory(() => KickMember(sl()))
    ..registerFactory(() => DemoteCohost(sl()))
    ..registerFactory(() => GetRecipeDetails(sl()))
    // Bloc
    ..registerLazySingleton(
      () => DashboardBloc(
        getMembers: GetKitchenMembers(sl()),
        makeCohost: MakeCohost(sl()),
        kickMember: KickMember(sl()),

        userCubit: sl(),
        kitchenBloc: sl(),
        demoteCohost: DemoteCohost(sl()),
        getRecipeDetails: GetRecipeDetails(sl()),
      ),
    );
}

void _initPantry() async {
  // Datasource
  sl.registerLazySingleton<NotificationService>(() => NotificationService());

  await sl<NotificationService>().init();
  sl
    ..registerFactory<PantryRemoteDatasource>(
      () => PantryRemoteDatasourceImpl(dio: sl(), notificationService: sl()),
    )
    // Repository
    ..registerFactory<PantryRepository>(
      () => PantryRepositoryImpl(
        commonRemoteDatasource: sl(),
        pantryRemoteDatasource: sl(),
      ),
    )
    // Usecases
    ..registerFactory(() => AddPantryItem(sl()))
    ..registerFactory(() => AddPantryRequestItem(sl()))
    ..registerFactory(() => GetPantryItems(sl()))
    ..registerFactory(() => ScanReceiptUseCase(sl()))
    ..registerFactory(() => RequestItems(sl()))
    ..registerFactory(() => ShowNotification(sl()))
    ..registerFactory(() => CreatePantryUsecase(sl()))
    ..registerFactory(() => GetUserStorageAreaForPantryView(sl()))
    ..registerFactory(() => DeletePantry(sl()))
    ..registerFactory(() => CartItems(sl()))
    ..registerFactory(() => DeleteItem(sl()))
    ..registerFactory(() => UpdateItem(sl()))
    // Bloc
    ..registerLazySingleton(
      () => PantryBloc(
        addPantryItem: AddPantryItem(sl()),
        addPantryRequestItem: AddPantryRequestItem(sl()),
        showNotification: ShowNotification(sl()),
        getPantryItems: GetPantryItems(sl()),
        scanReceipt: ScanReceiptUseCase(sl()),
        requestItems: RequestItems(sl()),
        homeBloc: sl(),
        groceryBloc: sl(),
        createPantryUsecase: CreatePantryUsecase(sl()),
        userCubit: sl(),
        deletePantry: DeletePantry(sl()),
        cartItems: CartItems(sl()),
        deleteItem: DeleteItem(sl()),
        updateItem: UpdateItem(sl()),
      ),
    );
}

void _initConsumption() async {
  // Datasource

  sl
    ..registerFactory<ConsumptionRemoteDatasource>(
      () => ConsumptionRemoteDatasourceImpl(sl()),
    )
    // Repository
    ..registerFactory<ConsumptionRepository>(
      () => ConsumptionRepositoryImpl(sl()),
    )
    // Usecases
    ..registerFactory(() => GetConsumptionConfirmationPendingUsecase(sl()))
    ..registerFactory(() => GetConsumptionConfirmationCountUseCase(sl()))
    ..registerFactory(() => RespondConsumptionConfirmationUseCase(sl()))
    // Bloc
    ..registerLazySingleton(
      () => ConsumptionBloc(
        getConsumptionConfirmationPending:
            GetConsumptionConfirmationPendingUsecase(sl()),
        getConsumptionConfirmationCount: GetConsumptionConfirmationCountUseCase(
          sl(),
        ),
        respondConsumptionConfirmation: RespondConsumptionConfirmationUseCase(
          sl(),
        ),
        homeBloc: sl(),
      ),
    );
}

void _initGrocery() async {
  // Datasource

  sl
    ..registerFactory<GroceryRemoteDatasource>(
      () => GroceryRemoteDatasourceImpl(sl()),
    )
    // Repository
    ..registerFactory<GroceryRepository>(() => GroceryRepositoryImpl(sl()))
    // Usecases
    ..registerFactory(() => GetRequestedItems(sl()))
    ..registerFactory(() => UpdateBucketType(sl()))
    ..registerFactory(() => AddMylistToInventory(sl()))
    ..registerFactory(() => GetAiGeneratedItems(sl()))
    ..registerFactory(() => DeleteKitchenItems(sl()))
    ..registerFactory(() => AddCustomItem(sl()))
    // Bloc
    ..registerLazySingleton(
      () => GroceryBloc(
        getRequestedItems: GetRequestedItems(sl()),
        updateBucketType: UpdateBucketType(sl()),
        addMylistToInventory: AddMylistToInventory(sl()),
        getAiGeneratedItems: GetAiGeneratedItems(sl()),
        deleteKitchenItems: DeleteKitchenItems(sl()),
        addCustomItem: AddCustomItem(sl()),
      ),
    );
}

void _initPlanner() async {
  // Datasource

  sl
    ..registerFactory<PlannerRemoteDatasource>(
      () => PlannerRemoteDatasourceImpl(sl()),
    )
    ..registerFactory<PlannerLocalDatasource>(
      () => PlannerLocalDatasourceImpl(sl()),
    )
    // Repository
    ..registerFactory<PlannerRepository>(
      () => PlannerRepositoryImpl(
        plannerLocalDatasource: sl(),
        plannerRemoteDatasource: sl(),
      ),
    )
    // Usecases
    ..registerFactory(() => GenerateRecipes(sl()))
    ..registerFactory(() => FavouriteRecipes(sl()))
    ..registerFactory(() => AddToFavouriteRecipe(sl()))
    ..registerFactory(() => RemoveFromFavouriteRecipe(sl()))
    ..registerFactory(() => AddToWeeklyPlan(sl()))
    ..registerFactory(() => GetAllWeeklyPlans(sl()))
    ..registerFactory(() => DeletePlan(sl()))
    ..registerFactory(() => DeleteMealTypeFromWeeklyPlan(sl()))
    ..registerFactory(() => MarkRecipeFinished(sl()))
    ..registerFactory(() => RequestMissingItems(sl()))
    ..registerFactory(() => CreatePlan(sl()))
    ..registerFactory(() => DeletePlanRemoteDb(sl()))
    ..registerFactory(() => UpdateMealPlan(sl()))
    ..registerFactory(() => GetMealByDate(sl()))
    ..registerFactory(() => GetAllPlans(sl()))
    ..registerFactory(() => GetDateRange(sl()))
    ..registerFactory(() => SetDateRange(sl()))
    // Bloc
    ..registerLazySingleton(
      () => PlannerBloc(
        userCubit: sl(),
        homeBloc: sl(),
        groceryBloc: sl(),
        generateRecipes: GenerateRecipes(sl()),
        favouriteRecipes: FavouriteRecipes(sl()),
        addToFavouriteRecipe: AddToFavouriteRecipe(sl()),
        removeFromFavouriteRecipe: RemoveFromFavouriteRecipe(sl()),
        addToWeeklyPlan: AddToWeeklyPlan(sl()),
        getAllWeeklyPlans: GetAllWeeklyPlans(sl()),
        deletePlan: DeletePlan(sl()),
        deleteMealTypeFromWeeklyPlan: DeleteMealTypeFromWeeklyPlan(sl()),
        markRecipeFinished: MarkRecipeFinished(sl()),
        requestMissingItems: RequestMissingItems(sl()),
        createPlan: CreatePlan(sl()),
        deletePlanRemoteDb: DeletePlanRemoteDb(sl()),
        updateMealPlan: UpdateMealPlan(sl()),
        getMealByDate: GetMealByDate(sl()),
        getAllPlans: GetAllPlans(sl()),
        getDateRange: GetDateRange(sl()),
        setDateRange: SetDateRange(sl()),
      ),
    );
}

void _initHistory() async {
  // Datasource

  sl
    ..registerFactory<ScanHistoryRemoteDatasource>(
      () => ScanHistoryRemoteDatasourceImpl(sl()),
    )
    // Repository
    ..registerFactory<ScanHistoryRepository>(
      () => ScanHistoryRepositoryImpl(sl()),
    )
    // Usecases
    ..registerFactory(() => GetScanHistoryUsecase(sl()))
    // Bloc
    ..registerLazySingleton(
      () =>
          ScanHistoryCubit(getScanHistoryUseCase: GetScanHistoryUsecase(sl())),
    );
}

void _initProfile() async {
  // Datasource

  sl
    ..registerFactory<ProfileRemoteDatasource>(
      () => ProfileRemoteDatasourceImpl(dio: sl()),
    )
    ..registerFactory<ProfileLocalDataSource>(
      () => ProfileLocalDatasourceImpl(sharedPreferences: sl()),
    )
    // Repository
    ..registerFactory<ProfileRepository>(
      () => ProfileRepositoryImpl(
        localDataSource: sl(),
        profileRemoteDatasource: sl(),
      ),
    )
    // Usecases
    ..registerFactory(() => GetProfilePicture(sl()))
    ..registerFactory(() => SetProfilePicture(sl()))
    ..registerFactory(() => EditProfile(sl()))
    ..registerFactory(() => ChangePassword(sl()))
    // Bloc
    ..registerLazySingleton(
      () => ProfileBloc(
        getProfilePicture: GetProfilePicture(sl()),
        setProfilePicture: SetProfilePicture(sl()),
        editProfile: EditProfile(sl()),
        userCubit: sl(),
        changePassword: ChangePassword(sl()),
      ),
    );
}

void _initCommonRemoteRepo() async {
  // Datasource
  sl.registerFactory<CommonRemoteDatasource>(
    () => CommonRemoteDatasourceImpl(dio: sl()),
  );
}
