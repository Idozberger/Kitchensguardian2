import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/usecase/get_current_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserCubit _userCubit;
  final GetCurrentUserUseCase _getCurrentUser;
  final SharedPreferences _sharedPreferences;

  UserBloc({
    required UserCubit userCubit,
    required GetCurrentUserUseCase getCurrentUser,
    required SharedPreferences sharedPreference,
  }) : _userCubit = userCubit,
       _getCurrentUser = getCurrentUser,
       _sharedPreferences = sharedPreference,

       super(UserInitial()) {
    on<UserEvent>((_, emit) => emit(UserLoading()));
    on<GetCurrentUser>(_onGetCurrentUser);
    on<GetStartedEvent>(_onGetStarted);
  }
  Future<void> _onGetCurrentUser(
    GetCurrentUser event,
    Emitter<UserState> emit,
  ) async {
    bool? isOnboard = _sharedPreferences.getBool("is_onboard");

    final res = await _getCurrentUser(NoParams());

    await Future.delayed(const Duration(seconds: 2));

    res.fold(
      (failure) => emit(
        failure.message.contains("No Internet") ? NoInternet() : UserInitial(),
      ),
      (user) {
        if (user == null) {
          if (isOnboard != null && isOnboard) {
            emit(UserOnBoarded());
          } else {
            emit(UserInitial());
          }

          return;
        }
        if (user.hasExpired == true) {
          emit(TokenExpired());
          return;
        }

        _userCubit.setUser();

        emit(UserSuccess());
      },
    );
  }

  Future<void> _onGetStarted(
    GetStartedEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      await _sharedPreferences.setBool("is_onboard", true);

      _sharedPreferences.getBool("is_onboard");

      emit(UserGetStarted());
    } catch (e) {
      emit(UserGetStarted());
    }
  }
}
