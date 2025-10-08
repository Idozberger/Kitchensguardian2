import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/features/auth/domain/usecase/send_password_reset_email_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/send_user_email_verification_code_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/set_user_new_password_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/user_sign_in_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/user_sign_up_usecase.dart';
import 'package:foodkitchen/features/auth/domain/usecase/verify_user_email_usecase.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final SendUserEmailVerificationCode _sendUserEmailVerificationCode;
  final UserSignIn _userSignIn;
  final SendPasswordResetEmail _sendPasswordResetEmail;
  final SetUserNewPassword _setUserNewPassword;
  final VerifyUserEmail _verifyUserEmail;

  AuthBloc({
    required UserSignUp userSignUp,
    required SendUserEmailVerificationCode sendUserEmailVerificationCode,
    required UserSignIn userSignIn,
    required SendPasswordResetEmail sendPasswordResetEmail,
    required SetUserNewPassword setUserNewPassword,
    required VerifyUserEmail verifyUserEmail,
  }) : _userSignUp = userSignUp,
       _sendUserEmailVerificationCode = sendUserEmailVerificationCode,
       _userSignIn = userSignIn,
       _sendPasswordResetEmail = sendPasswordResetEmail,
       _setUserNewPassword = setUserNewPassword,
       _verifyUserEmail = verifyUserEmail,

       super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthSendUserEmailVerficationCode>(_onSendUserEmailVerficationCode);
    on<AuthSignIn>(_onAuthSignIn);
    on<AuthSendPasswordResetEmail>(_onSendPasswordResetEmail);
    on<AuthSetUserNewPassword>(_onSetUserNewPassword);
    on<AuthVerifyEmail>(_onVerifyUserEmail);
  }
  Future<void> _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
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
    final res = await _sendUserEmailVerificationCode(
      SendUserEmailVerificationCodeParams(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
      ),
    );

    res.fold((failure) => emit(AuthFailure(failure.message)), (message) {
      emit(AuthSuccess(message));
    });
  }

  void _onAuthSignIn(AuthSignIn event, Emitter<AuthState> emit) async {
    final res = await _userSignIn(
      UserSignInParams(email: event.email, password: event.password),
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  void _onVerifyUserEmail(
    AuthVerifyEmail event,
    Emitter<AuthState> emit,
  ) async {
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

  void _onSendPasswordResetEmail(
    AuthSendPasswordResetEmail event,
    Emitter<AuthState> emit,
  ) async {
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
}
