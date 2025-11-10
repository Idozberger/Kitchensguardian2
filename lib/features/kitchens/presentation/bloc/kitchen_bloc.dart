import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/global/functions/logs.dart';
import 'package:foodkitchen/core/services/fcm/fcm_service.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/kitchens/domain/entities/kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/create_kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/get_kitchens.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/invite_user.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/join_kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/leave_kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/remove_kitchen.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_event.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_state.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:intl/intl.dart';

class KitchenBloc extends Bloc<KitchenEvent, KitchenState> {
  final GetKitchens _getKitchens;
  final CreateKitchenUseCase _createKitchen;
  final JoinKitchenUseCase _joinKitchen;
  final LeaveKitchenUsecase _leaveKitchenUsecase;
  final RemoveKitchenUsecase _removeKitchenUsecase;
  final HomeBloc _homeBloc;
  final UserCubit _userCubit;
  final PlannerBloc _plannerBloc;
  final GroceryBloc _groceryBloc;
  final InviteUser _inviteUser;

  KitchenBloc({
    required GetKitchens getKitchens,
    required CreateKitchenUseCase createKitchen,
    required JoinKitchenUseCase joinKitchen,
    required HomeBloc homeBloc,
    required PlannerBloc plannerBloc,
    required GroceryBloc groceryBloc,
    required UserCubit userCubit,
    required LeaveKitchenUsecase leaveKitchenUsecase,
    required RemoveKitchenUsecase removeKitchenUsecase,
    required InviteUser inviteUser,
  }) : _getKitchens = getKitchens,
       _createKitchen = createKitchen,
       _joinKitchen = joinKitchen,
       _leaveKitchenUsecase = leaveKitchenUsecase,
       _removeKitchenUsecase = removeKitchenUsecase,
       _inviteUser = inviteUser,
       _homeBloc = homeBloc,
       _userCubit = userCubit,
       _plannerBloc = plannerBloc,
       _groceryBloc = groceryBloc,
       super(KitchenInitial()) {
    on<FetchKitchens>(_onFetchKitchens);
    on<CreateKitchenEvent>(_onCreateKitchenEvent);
    on<JoinKitchenEvent>(_onJoinKitchenEvent);
    on<SwitchKitchenEvent>(_onSwitchKitchen);
    on<LeaveKitchenEvent>(_onLeaveKitchen);
    on<RemoveKitchenEvent>(_onRemoveKitchen);
    on<DeleteOrLeaveKitchenEvent>(_onDeleteOrLeaveKitchen);
    on<FetchAllUsers>(_onFetchAllUsers);
    on<InviteUserEvent>(_onInviteUser);
    on<MemberApprovedEvent>(_onMemberApproved);
  }
  Future<void> _onMemberApproved(
    MemberApprovedEvent event,
    Emitter<KitchenState> emit,
  ) async {
    emit(KitchensLoading());
    final res = await _joinKitchen(
      JoinKitchenUsecaseParams(invitationCode: event.invitationCode),
    );

    res.fold(
      (failure) => emit(KitchenFailure(failure.message)),
      (message) => emit(KitchenSuccess(message)),
    );
    add(FetchKitchens());
  }

  Future<void> _onFetchKitchens(
    FetchKitchens event,
    Emitter<KitchenState> emit,
  ) async {
    emit(KitchensLoading());

    final res = await _getKitchens(NoParams());
    res.fold((failure) => emit(KitchenFailure(failure.message)), (kitchens) {
      emit(KitchensLoaded(kitchens));
    });
  }

  Future<void> _onCreateKitchenEvent(
    CreateKitchenEvent event,
    Emitter<KitchenState> emit,
  ) async {
    emit(KitchensLoading());
    final res = await _createKitchen(
      CreateKitchenParams(kitchenName: event.kitchenName),
    );

    res.fold((failure) => emit(KitchenFailure(failure.message)), (message) {
      emit(KitchenSuccess(message));
    });
  }

  Future<void> _onJoinKitchenEvent(
    JoinKitchenEvent event,
    Emitter<KitchenState> emit,
  ) async {
    emit(KitchensLoading());

    try {
      final kitchenDoc = await FirebaseFirestore.instance
          .collection('kitchens')
          .where('invitation_code', isEqualTo: event.invitationCode)
          .limit(1)
          .get();

      if (kitchenDoc.docs.isEmpty) {
        emit(KitchenFailure("Invitation code is not valid"));
        return;
      }

      final kitchenData = kitchenDoc.docs.first.data();
      final userId = kitchenData['user_id'];
      final kitchenName = kitchenData['kitchen_name'];
      if (_userCubit.state.userId == userId) {
        AppToast.show(
          "You are the host of this kitchen: $kitchenName. You already have access.",
          ToastType.error,
        );
        add(FetchKitchens());

        return;
      }
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        emit(KitchenFailure("Kitchen host not found"));

        return;
      }

      final userData = userDoc.data();
      final userDeviceToken = userData?['user_device_token'];

      if (userDeviceToken == null) {
        emit(KitchenFailure("User not found"));

        return;
      }
      final random = Random();
      final notificationId = random.nextInt(999999);
      final notificationData = {
        "status": false,
        "id": notificationId,
        'title': "Request to join your kitchen",
        'body':
            "User ${_userCubit.state.firstName} wants to join your kitchen: $kitchenName.",
        'host_user_id': userId,
        'sender_user_id': _userCubit.state.userId,
        'sender_name':
            "${_userCubit.state.firstName} ${_userCubit.state.lastName}",
        'kitchen_id': kitchenData['kitchen_id'],
        'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        'read': false,
      };
      await FCMService().sendNotification(
        userDeviceToken,
        "Request to join your kitchen",
        "User ${_userCubit.state.firstName} wants to join your kitchen: $kitchenName.",
      );

      await FirebaseFirestore.instance
          .collection('notifications')
          .add(notificationData);
      AppToast.show("Kitchen join request sent", ToastType.success);
      add(FetchKitchens());
    } catch (e, st) {
      emit(KitchenFailure("An error accured"));

      debugPrint('🧾 Stack Trace: $st');
    }
  }

  Future<void> _onLeaveKitchen(
    LeaveKitchenEvent event,
    Emitter<KitchenState> emit,
  ) async {
    emit(KitchensLoading());
    final res = await _leaveKitchenUsecase(
      LeaveKitchenParams(kitchenId: event.kitchenId),
    );

    res.fold((failure) => emit(KitchenFailure(failure.message)), (message) {
      add(DeleteOrLeaveKitchenEvent());
      emit(KitchenSuccess(message));
    });
  }

  Future<void> _onRemoveKitchen(
    RemoveKitchenEvent event,
    Emitter<KitchenState> emit,
  ) async {
    emit(KitchensLoading());
    final res = await _removeKitchenUsecase(
      RemoveKitchenParams(kitchenId: event.kitchenId),
    );

    res.fold((failure) => emit(KitchenFailure(failure.message)), (message) {
      add(DeleteOrLeaveKitchenEvent());
      emit(KitchenSuccess(message));
    });
  }

  Future<void> _onSwitchKitchen(
    SwitchKitchenEvent event,
    Emitter<KitchenState> emit,
  ) async {
    emit(KitchensLoading());
    _homeBloc.add(
      GetPantriesItemsEventForHome(kitchenId: event.kitchen.kitchenId),
    );
    _groceryBloc.add(RequestedGroceryEvent(kitchenId: event.kitchen.kitchenId));
    _plannerBloc.add(GetAllWeeklyPlansEvent());
    if (event.kitchen.invitationCode.isNotEmpty) {
      await _saveOrUpdateUserKitchen(kitchen: event.kitchen);
    }
    add(FetchKitchens());
  }

  Future<void> _onDeleteOrLeaveKitchen(
    DeleteOrLeaveKitchenEvent event,
    Emitter<KitchenState> emit,
  ) async {
    emit(KitchensLoading());
    _userCubit.updateKitchenIdAndRefferalCode("", "");
    _homeBloc.add(ResetHomeStateEvent());
    _groceryBloc.add(ResetGroceryStateEvent());
    _plannerBloc.add(ResetPlannerStateEvent());

    add(FetchKitchens());
  }

  Future<void> _onInviteUser(
    InviteUserEvent event,
    Emitter<KitchenState> emit,
  ) async {
    emit(
      (state as AllUserLoaded).copyWith(isLoading: true, index: event.index),
    );

    final res = await _inviteUser(
      InviteUserKitchenParams(kitchenId: event.kitchenId, email: event.email),
    );

    res.fold(
      (failure) {
        emit(
          (state as AllUserLoaded).copyWith(
            isLoading: false,
            index: -1,
            errorMessage: failure.message,
          ),
        );
      },
      (successMessage) {
        emit(
          (state as AllUserLoaded).copyWith(
            isLoading: false,
            index: -1,
            successMessage: successMessage,
          ),
        );
      },
    );
  }

  Future<void> _onFetchAllUsers(
    FetchAllUsers event,
    Emitter<KitchenState> emit,
  ) async {
    emit(AllUserLoaded(isLoading: true));
    await Future.delayed(Duration(seconds: 3));
    emit(AllUserLoaded(isLoading: false));
  }

  Future<void> _saveOrUpdateUserKitchen({required Kitchen kitchen}) async {
    try {
      final _firestore = FirebaseFirestore.instance;

      final kitchenRef = _firestore
          .collection('kitchens')
          .doc(kitchen.kitchenId);

      final data = {
        'kitchen_id': kitchen.kitchenId,
        'user_id': _userCubit.state.userId,
        'kitchen_name': kitchen.kitchenName,
        'role': kitchen.role,
        'invitation_code': kitchen.invitationCode,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await kitchenRef.set(data);
    } catch (e, st) {
      logError(st.toString());
    }
  }
}
