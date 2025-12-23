import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/usecase/get_current_user.dart';
import 'package:foodkitchen/features/auth/domain/usecase/google_sign_in_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/google_signup_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/send_password_reset_email_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/send_user_email_verification_code_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/set_user_new_password_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/user_sign_in_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/user_sign_up_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/verify_user_email_usecase.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserCubit _userCubit;
  final GetCurrentUserUseCase _getCurrentUser;
  final UserSignUp _userSignUp;
  final SendUserEmailVerificationCode _sendUserEmailVerificationCode;
  final UserSignIn _userSignIn;
  final SendPasswordResetEmail _sendPasswordResetEmail;
  final SetUserNewPassword _setUserNewPassword;
  final VerifyUserEmail _verifyUserEmail;
  final GoogleSignInUsecase _googleSignInUsecase;
  final GoogleSignupUsecase _googleSignupUsecase;

  AuthBloc({
    required UserCubit userCubit,
    required UserSignUp userSignUp,
    required SendUserEmailVerificationCode sendUserEmailVerificationCode,
    required UserSignIn userSignIn,
    required SendPasswordResetEmail sendPasswordResetEmail,
    required SetUserNewPassword setUserNewPassword,
    required VerifyUserEmail verifyUserEmail,
    required GetCurrentUserUseCase getCurrentUser,
    required GoogleSignInUsecase googleSignIn,
    required GoogleSignupUsecase googleSignup,
  }) : _userCubit = userCubit,
       _userSignUp = userSignUp,
       _sendUserEmailVerificationCode = sendUserEmailVerificationCode,
       _userSignIn = userSignIn,
       _sendPasswordResetEmail = sendPasswordResetEmail,
       _setUserNewPassword = setUserNewPassword,
       _verifyUserEmail = verifyUserEmail,
       _getCurrentUser = getCurrentUser,
       _googleSignInUsecase = googleSignIn,
       _googleSignupUsecase = googleSignup,

       super(AuthInitial()) {
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthSendUserEmailVerficationCode>(_onSendUserEmailVerficationCode);
    on<AuthSignIn>(_onAuthSignIn);
    on<AuthSendPasswordResetEmail>(_onSendPasswordResetEmail);
    on<AuthSetUserNewPassword>(_onSetUserNewPassword);
    on<AuthVerifyEmail>(_onVerifyUserEmail);
    on<AuthGetCurrentUser>(_onGetCurrentUser);
    on<ResendEmailVerficationCodeEvent>(_onResendEmailVerficationCode);
    on<GoogleSignUpEvent>(_onGoogleSignUp);
    on<GoogleSignInEvent>(_onGoogleSignIn);
  }
  Future<void> _onGoogleSignUp(
    GoogleSignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(GoogleAuthsignUpLoading());
    final res = await _googleSignupUsecase(NoParams());

    res.fold((failure) => emit(AuthFailure(failure.message)), (message) {
      emit(AuthUserCreatedSuccess(message));
    });
  }

  Future<void> _onGoogleSignIn(
    GoogleSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(GoogleAuthLoading());
    final res = await _googleSignInUsecase(NoParams());

    res.fold((failure) => emit(AuthFailure(failure.message)), (message) {
      emit(AuthSuccess(message));
      _onGetCurrentUser(AuthGetCurrentUser(), emit);
    });
  }

  Future<void> _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userSignUp(
      UserSignUpParams(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
      ),
    );

    res.fold((failure) => emit(AuthFailure(failure.message)), (message) {
      emit(AuthUserCreatedSuccess(message));
    });
  }

  Future<void> _onSendUserEmailVerficationCode(
    AuthSendUserEmailVerficationCode event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await _sendUserEmailVerificationCode(
      SendUserEmailVerificationCodeParams(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
      ),
    );

    res.fold((failure) => emit(AuthFailure(failure.message)), (message) {
      emit(AuthEmailVerificationCodeSent(message));
    });
  }

  void _onAuthSignIn(AuthSignIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userSignIn(
      UserSignInParams(email: event.email, password: event.password),
    );

    res.fold((failure) => emit(AuthFailure(failure.message)), (message) {
      emit(AuthSuccess(message));

      _onGetCurrentUser(AuthGetCurrentUser(), emit);
    });
  }

  void _onVerifyUserEmail(
    AuthVerifyEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await _verifyUserEmail(
      VerifyUserEmailParams(
        email: event.email,
        verificationCode: event.verificationCode,
      ),
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (message) => emit(AuthUserVerified(message)),
    );
  }

  void _onResendEmailVerficationCode(
    ResendEmailVerficationCodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(CodeResendLoading());
    final res = await _sendPasswordResetEmail(
      SendPasswordResetEmailParams(email: event.email),
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (message) => emit(ResendEmailVerficationCode(message)),
    );
  }

  void _onSendPasswordResetEmail(
    AuthSendPasswordResetEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await _sendPasswordResetEmail(
      SendPasswordResetEmailParams(email: event.email),
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (message) => emit(AuthForgotMailSent(message)),
    );
  }

  void _onSetUserNewPassword(
    AuthSetUserNewPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await _setUserNewPassword(
      SetUserNewPasswordParams(
        email: event.email,
        newPassword: event.newPassword,
        verificationCode: event.verificationCode,
      ),
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (message) => emit(AuthUserPasswordChanged(message)),
    );
  }

  Future<void> _onGetCurrentUser(
    AuthGetCurrentUser event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _getCurrentUser(NoParams());

    res.fold((failure) {}, (user) {
      _userCubit.setUser(
        userId: user?.userId ?? "",
        firstName: user?.firstName ?? "",
        lastName: user?.lastName ?? "",
        email: user?.email ?? "",
      );
    });
  }
}
