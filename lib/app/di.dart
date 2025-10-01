import 'package:dio/dio.dart';
import 'package:foodkitchen/features/auth/data/data_source/auth_remote_datasource.dart';
import 'package:foodkitchen/features/auth/data/repository/auth_repository_impl.dart';
import 'package:foodkitchen/features/auth/domain/repository/auth_repository.dart';
import 'package:foodkitchen/features/auth/domain/usecase/send_password_reset_email_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/set_user_new_password_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/user_sign_in_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/user_sign_up_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/verify_user_email_usecase.dart';
import 'package:foodkitchen/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/network/dio_helper.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  _dioInjection();
  _initAuth();
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

void _initAuth() {
  // Datasource
  sl
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDatasourceImpl(sl()),
    )
    // Repository
    ..registerFactory<AuthRepository>(() => AuthRepositoryImpl(sl()))
    // Usecases
    ..registerFactory(() => UserSignUp(sl()))
    // Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: UserSignUp(sl()),
        userSignIn: UserSignIn(sl()),
        sendPasswordResetEmail: SendPasswordResetEmail(sl()),
        setUserNewPassword: SetUserNewPassword(sl()),
        verifyUserEmail: VerifyUserEmail(sl()),
      ),
    );
}
