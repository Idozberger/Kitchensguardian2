part of 'package:foodkitchen/app/di.dart';

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
  sl.registerFactory(() => FinalizeKitchenSetup(sl()));
  sl.registerFactory(() => SkipKitchenSetup(sl()));

  // Bloc
  sl.registerFactory<SmartKitchenSetupBloc>(
    () => SmartKitchenSetupBloc(
      scanKitchenImagesUseCase: sl(),
      finalizeKitchenSetup: sl(),
      skipKitchenSetup: sl(),
      userCubit: sl(),
    ),
  );
}

void _initAppCubit() {
  sl.registerLazySingleton<AppCubit>(AppCubit.new);
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
        commonRemoteDatasource: sl(),
        entitlementSnapshot: sl(),
        unitSystemLocalDataSource: sl(),
        getUnitSystem: GetUnitSystem(sl()),
        setUnitSystem: SetUnitSystem(sl()),
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
    ..registerLazySingleton<KitchenJoinRequestFirestoreDatasource>(
      KitchenJoinRequestFirestoreDatasourceImpl.new,
    )
    ..registerLazySingleton<KitchenDocumentFirestoreDatasource>(
      KitchenDocumentFirestoreDatasourceImpl.new,
    )
    ..registerLazySingleton<KitchenJoinStatusFirestoreDatasource>(
      KitchenJoinStatusFirestoreDatasourceImpl.new,
    )
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
    ..registerFactory(() => GetPantriesForHome(sl()))
    ..registerFactory(() => GetAllWeeklyPlansForHome(sl()))
    ..registerFactory(() => GetRecipeSuggestionUsecase(sl()))
    ..registerFactory(() => RespondToItemRequest(sl()))
    ..registerFactory(() => SubmitKitchenJoinRequest(sl()))
    // Bloc
    ..registerLazySingleton(
      () => HomeBloc(
        createKitchen: CreateKitchen(sl()),
        userCubit: sl(),
        getPantriesForHome: GetPantriesForHome(sl()),
        getAllWeeklyPlansForHome: GetAllWeeklyPlansForHome(sl()),
        getRecipeSuggestionUsecase: GetRecipeSuggestionUsecase(sl()),
        getAllRequestedItems: GetAllRequestedItems(sl()),
        respondToItemRequest: RespondToItemRequest(sl()),
        submitKitchenJoinRequest: SubmitKitchenJoinRequest(sl()),
        kitchenDocumentFirestore: sl(),
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
    ..registerFactory(() => GetUnitSystem(sl()))
    ..registerFactory(() => SetUnitSystem(sl()))
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
        submitKitchenJoinRequest: SubmitKitchenJoinRequest(sl()),
        kitchenDocumentFirestore: sl(),
      ),
    );
}
