import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/common/domain/usecase/get_current_user.dart';
import 'package:foodkitchen/core/global/functions/logs.dart';
import 'package:foodkitchen/core/services/fcm/fcm_service.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/home/domain/entities/kitchen.dart';
import 'package:foodkitchen/features/home/domain/usecases/create_kitchen_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/get_all_weekly_plans_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/get_pantries_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/join_kitchen_usecase.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/planner/data/models/merged_meal_plan_model.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';
import 'package:intl/intl.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserCubit _userCubit;
  final CreateKitchen _createKitchen;
  // ignore: unused_field
  final JoinKitchen _joinKitchen;
  final GetPantriesForHome _getPantriesForHome;
  final GetAllWeeklyPlansForHome _getAllWeeklyPlansForHome;

  HomeBloc({
    required UserCubit userCubit,
    required CreateKitchen createKitchen,
    required JoinKitchen joinKitchen,
    required GetPantriesForHome getPantriesForHome,
    required GetAllWeeklyPlansForHome getAllWeeklyPlansForHome,
  }) : _userCubit = userCubit,
       _createKitchen = createKitchen,
       _joinKitchen = joinKitchen,
       _getAllWeeklyPlansForHome = getAllWeeklyPlansForHome,
       _getPantriesForHome = getPantriesForHome,

       super(const HomeState()) {
    on<CreateKitchenEventForHome>(_onCreateKitchenEvent);
    on<GetPantriesItemsEventForHome>(_onGetPantryItems);
    on<JoinKitchenEventForHome>(_onJoinKitchenEvent);
    on<GetAllWeeklyPlansEventForHome>(_onGetAllWeeklyPlans);
    on<ResetHomeStateEvent>(_onResetHomeState);
    on<GetUserStorageAreaEvent>(_onGetUserStorageArea);
  }

  Future<void> _onCreateKitchenEvent(
    CreateKitchenEventForHome event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final res = await _createKitchen(
      CreateKitchenParams(kitchenName: event.kitchenName),
    );

    await res.fold(
      (failure) async {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
      },
      (kitchen) async {
        _userCubit.updateActiveKitchenIdInvitationCodeAndRole(
          activeKitchenId: kitchen.kitchenId,
          invitationCode: kitchen.invitationCode,
          role: "host",
        );

        await _saveOrUpdateUserKitchen(
          kitchen: kitchen,
          kitchenName: event.kitchenName,
        );

        emit(state.copyWith(isLoading: false, successMessage: kitchen.message));
        add(GetPantriesItemsEventForHome(kitchenId: kitchen.kitchenId));
      },
    );
  }

  Future<void> _onJoinKitchenEvent(
    JoinKitchenEventForHome event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final kitchenDoc = await FirebaseFirestore.instance
          .collection('kitchens')
          .where('invitation_code', isEqualTo: event.invitationCode)
          .limit(1)
          .get();

      if (kitchenDoc.docs.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: "Invitation code is not valid",
          ),
        );
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
        add(
          GetPantriesItemsEventForHome(
            kitchenId: _userCubit.state.activeKitchenId,
          ),
        );
        return;
      }
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: "Kitchen host not found",
          ),
        );
        return;
      }

      final userData = userDoc.data();
      final userDeviceToken = userData?['user_device_token'];

      if (userDeviceToken == null) {
        emit(state.copyWith(isLoading: false, errorMessage: "User not found"));
        return;
      }

      await FCMService().sendNotification(
        userDeviceToken,
        "Request to join your kitchen",
        "User ${_userCubit.state.firstName} wants to join your kitchen: $kitchenName.",
      );
      final random = Random();
      final notificationId = random.nextInt(999999);
      final notificationData = {
        "status": false,
        'id': notificationId,
        'title': "Request to join your kitchen",
        'body':
            "User ${_userCubit.state.firstName} wants to join your kitchen: $kitchenName.",
        'host_user_id': userId,
        'sender_user_id': _userCubit.state.userId,
        'kitchen_id': kitchenData['kitchen_id'],
        'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        'sender_name':
            "${_userCubit.state.firstName} ${_userCubit.state.lastName}",
        'read': false,
      };
      debugPrint('📦 Sending notification data: $notificationData');

      await FirebaseFirestore.instance
          .collection('notifications')
          .add(notificationData);

      add(
        GetPantriesItemsEventForHome(
          kitchenId: _userCubit.state.activeKitchenId,
        ),
      );

      emit(
        state.copyWith(
          isLoading: false,
          successMessage: "Join request sent to the host.",
        ),
      );
    } catch (e, st) {
      emit(
        state.copyWith(isLoading: false, errorMessage: 'An error occurred.'),
      );
      debugPrint('❌ Error: $e');
      debugPrint('🧾 Stack Trace: $st');
    }
  }

  Future<void> _onGetPantryItems(
    GetPantriesItemsEventForHome event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final res = await _getPantriesForHome(
      GetPantriesForHomeParams(kitchenId: event.kitchenId),
    );

    res.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (pantries) =>
          emit(state.copyWith(isLoading: false, pantryItems: [pantries])),
    );
  }

  Future<void> _onGetUserStorageArea(
    GetUserStorageAreaEvent event,
    Emitter<HomeState> emit,
  ) async {
    _userCubit.getUserStorageArea(kitchenId: event.kitchenId);
  }

  Future<void> _onGetAllWeeklyPlans(
    GetAllWeeklyPlansEventForHome event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(loadingWeeklyPlans: true));
    final res = await _getAllWeeklyPlansForHome(
      GetAllWeeklyPlansForHomeParams(_userCubit.state.activeKitchenId),
    );

    res.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message, isLoading: false));
      },
      (getAllWeeklyPlans) {
        emit(
          state.copyWith(dateBasedPlan: getAllWeeklyPlans, isLoading: false),
        );
      },
    );
  }

  void _onResetHomeState(ResetHomeStateEvent event, Emitter<HomeState> emit) {
    emit(state.copyWith(pantryItems: []));
  }

  Future<void> _saveOrUpdateUserKitchen({
    required Kitchen kitchen,
    String? kitchenName,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final kitchenRef = firestore
          .collection('kitchens')
          .doc(kitchen.kitchenId);

      final data = {
        'kitchen_id': kitchen.kitchenId,
        'user_id': _userCubit.state.userId,
        'kitchen_name': kitchenName,
        'role': "host",
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
