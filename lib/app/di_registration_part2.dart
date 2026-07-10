part of 'package:foodkitchen/app/di.dart';

void _initPlanner() async {
  // Datasource

  sl
    ..registerLazySingleton<RecipeStartRequestFirestoreDatasource>(
      RecipeStartRequestFirestoreDatasourceImpl.new,
    )
    ..registerFactory<PlannerRemoteDatasource>(
      () => PlannerRemoteDatasourceImpl(sl()),
    )
    ..registerFactory<PlannerLocalDatasource>(
      () => PlannerLocalDatasourceImpl(sl(), sl()),
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
    ..registerFactory(() => CheckMissingIngredients(sl()))
    ..registerFactory(() => SubmitRecipeStartRequest(sl()))
    ..registerFactory(() => CompleteRecipeStartRequestForHost(sl()))
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
        checkMissingIngredients: CheckMissingIngredients(sl()),
        submitRecipeStartRequest: SubmitRecipeStartRequest(sl()),
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
      () => ProfileRemoteDatasourceImpl(dio: sl(), profileCache: sl()),
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
    ..registerFactory(() => DeleteAccount(sl()))
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

void _initCommonRemoteRepo() {
  sl.registerFactory<UnitSystemLocalDataSource>(
    () => UnitSystemLocalDatasourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<ProfileResponseCache>(ProfileResponseCache.new);
  sl.registerLazySingleton<UserEntitlementSnapshot>(
    UserEntitlementSnapshot.new,
  );
  sl.registerLazySingleton<BillingRepository>(NoOpBillingRepository.new);
  sl.registerLazySingleton<CommonRemoteDatasource>(
    () => CommonRemoteDatasourceImpl(dio: sl(), profileCache: sl()),
  );
  sl.registerLazySingleton<SubscriptionRemoteDatasource>(
    () => SubscriptionRemoteDatasourceImpl(dio: sl(), profileCache: sl()),
  );
}
