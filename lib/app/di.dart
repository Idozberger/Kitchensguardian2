import 'package:dio/dio.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/services/connection/connection_checker.dart';
import 'package:foodkitchen/core/services/jwt_decoder/jwt_decoder.dart';
import 'package:foodkitchen/features/auth/data/data_source/auth_remote_datasource.dart';
import 'package:foodkitchen/features/auth/data/repository/auth_repository_impl.dart';
import 'package:foodkitchen/features/auth/domain/repository/auth_repository.dart';
import 'package:foodkitchen/features/auth/domain/usecase/send_password_reset_email_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/send_user_email_verification_code_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/set_user_new_password_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/user_sign_in_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/user_sign_up_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/verify_user_email_usecase.dart';
import 'package:foodkitchen/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:foodkitchen/core/common/data/datasource/current_user_remote_datasource.dart';
import 'package:foodkitchen/core/common/data/repositories/current_user_respository_impl.dart';
import 'package:foodkitchen/core/common/domain/repository/current_user_repository.dart';
import 'package:foodkitchen/core/common/domain/usecase/get_current_user.dart';
import 'package:foodkitchen/features/dashboard/data/datasource/dashboard_remote_datasource.dart';
import 'package:foodkitchen/features/dashboard/data/repository/dashboard_repository_impl.dart';
import 'package:foodkitchen/features/dashboard/domain/repository/dashboard_repository.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/get_kitchen_members.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/kick_member.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/make_cohost.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:foodkitchen/features/home/data/datasource/home_remote_datasource.dart';
import 'package:foodkitchen/features/home/data/repository/home_repository_impl.dart';
import 'package:foodkitchen/features/home/domain/repository/home_repository.dart';
import 'package:foodkitchen/features/home/domain/usecases/create_kitchen_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/join_kitchen_usecase.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/kitchens/data/datasource/kitchen_remote_datasource.dart';
import 'package:foodkitchen/features/kitchens/data/repository/kitchen_repository_impl.dart';
import 'package:foodkitchen/features/kitchens/domain/repository/kitchen_repository.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/create_kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/get_kitchens.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/join_kitchen.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_bloc.dart';
import 'package:foodkitchen/features/onboarding/presentation/bloc/user_bloc.dart';
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
  _dioInjection();
  _initOnboarding();
  _initHome();
  _initAuth();
  _initKitchen();
  _initDashboard();
}

void _dioInjection() {
  sl.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    ),
  );

  sl.registerLazySingleton<DioHelper>(() => DioHelper(sl()));
}

void _initOnboarding() async {
  // Datasource
  sl
    ..registerFactory<CurrentUserRemoteDatasource>(
      () => CurrentUserRemoteDataSourceImpl(sl(), sl()),
    )
    // Repository
    ..registerFactory<CurrentUserRepository>(
      () => CurrentUserRepositoryImpl(sl(), sl()),
    )
    // Usecases
    ..registerFactory(() => GetCurrentUserUseCase(sl()))
    // Cubit
    ..registerLazySingleton(() => UserCubit())
    // Bloc
    ..registerLazySingleton(
      () => UserBloc(getCurrentUser: sl(), userCubit: sl()),
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
      ),
    )
    // Repository
    ..registerFactory<AuthRepository>(() => AuthRepositoryImpl(sl()))
    // Usecases
    ..registerFactory(() => UserSignUp(sl()))
    // Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: UserSignUp(sl()),
        sendUserEmailVerificationCode: SendUserEmailVerificationCode(sl()),
        userSignIn: UserSignIn(sl()),
        sendPasswordResetEmail: SendPasswordResetEmail(sl()),
        setUserNewPassword: SetUserNewPassword(sl()),
        verifyUserEmail: VerifyUserEmail(sl()),
        userCubit: sl(),
        getCurrentUser: GetCurrentUserUseCase(sl()),
      ),
    );
}

void _initHome() async {
  // Datasource
  sl
    ..registerFactory<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(sl()),
    )
    // Repository
    ..registerFactory<HomeRepository>(() => HomeRepositoryImpl(sl()))
    // Usecases
    ..registerFactory(() => CreateKitchen(sl()))
    ..registerFactory(() => JoinKitchen(sl()))
    // Bloc
    ..registerLazySingleton(
      () => HomeBloc(
        createKitchen: CreateKitchen(sl()),
        joinKitchen: JoinKitchen(sl()),
        userCubit: sl(),
      ),
    );
}

void _initKitchen() async {
  // Datasource
  sl
    ..registerFactory<KitchenRemoteDatasource>(
      () => KitchenRemoteDataSourceImpl(sl()),
    )
    // Repository
    ..registerFactory<KitchenRepository>(() => KitchenRepositoryImpl(sl()))
    // Usecases
    ..registerFactory(() => GetKitchens(sl()))
    ..registerFactory(() => CreateKitchenUseCase(sl()))
    ..registerFactory(() => JoinKitchenUseCase(sl()))
    // Bloc
    ..registerLazySingleton(
      () => KitchenBloc(
        getKitchens: GetKitchens(sl()),
        createKitchen: CreateKitchenUseCase(sl()),
        joinKitchen: JoinKitchenUseCase(sl()),
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
    // Bloc
    ..registerLazySingleton(
      () => DashboardBloc(
        getMembers: GetKitchenMembers(sl()),
        makeCohost: MakeCohost(sl()),
        kickMember: KickMember(sl()),
      ),
    );
}
