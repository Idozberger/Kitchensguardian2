import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/usecase/get_current_user.dart';
import 'package:foodkitchen/core/global/functions/logs.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserCubit _userCubit;
  final GetCurrentUserUseCase _getCurrentUser;

  UserBloc({
    required UserCubit userCubit,
    required GetCurrentUserUseCase getCurrentUser,
  }) : _userCubit = userCubit,
       _getCurrentUser = getCurrentUser,

       super(UserInitial()) {
    on<UserEvent>((_, emit) => emit(UserLoading()));
    on<GetCurrentUser>(_onGetCurrentUser);
  }
  Future<void> _onGetCurrentUser(
    GetCurrentUser event,
    Emitter<UserState> emit,
  ) async {
    final res = await _getCurrentUser(NoParams());

    await Future.delayed(const Duration(seconds: 2));

    res.fold(
      (failure) => emit(
        failure.message.contains("No Internet") ? NoInternet() : UserInitial(),
      ),
      (user) {
        if (user == null) {
          emit(UserInitial());
          return;
        }
        if (user.hasExpired == true) {
          emit(TokenExpired());
          return;
        }

        _userCubit.setUser(
          userId: user.userId ?? "",
          firstName: user.firstName ?? "",
          lastName: user.lastName ?? "",
          email: user.email ?? "",
        );

        emit(UserSuccess());
      },
    );
  }
}
