import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const UserState());

  void setUser({
    required String firstName,
    required String lastName,
    required String email,
    required String userId,
  }) {
    emit(
      state.copyWith(
        firstName: firstName,
        lastName: lastName,
        email: email,
        userId: userId,
      ),
    );
  }

  void updateActiveKitchenIdInvitationCodeAndRole({
    required String activeKitchenId,
    required String invitationCode,
    required String role,
  }) {
    emit(
      state.copyWith(
        activeKitchenId: activeKitchenId,
        invitationCode: invitationCode,
        role: role,
      ),
    );
  }

  void toggleLoading(bool value) {
    emit(state.copyWith(isLoading: value));
  }

  void clearUser() {
    emit(const UserState());
  }
}
