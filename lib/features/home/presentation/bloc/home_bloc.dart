import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/services/fcm/fcm_service.dart';
import 'package:foodkitchen/core/services/notifications/flutter_local_notifications_service.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/home/domain/entities/kitchen.dart';
import 'package:foodkitchen/features/home/domain/entities/pantry_items.dart';
import 'package:foodkitchen/features/home/domain/usecases/create_kitchen_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/get_all_weekly_plans_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/get_pantries_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/get_recipe_suggestion_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/join_kitchen_usecase.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/planner/domain/entities/ingredient_entity.dart';
import 'package:intl/intl.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserCubit _userCubit;
  final CreateKitchen _createKitchen;
  // ignore: unused_field
  final JoinKitchen _joinKitchen;
  final GetPantriesForHome _getPantriesForHome;
  final GetAllWeeklyPlansForHome _getAllWeeklyPlansForHome;
  final GetRecipeSuggestionUsecase _getRecipeSuggestionUsecase;

  HomeBloc({
    required UserCubit userCubit,
    required CreateKitchen createKitchen,
    required JoinKitchen joinKitchen,
    required GetPantriesForHome getPantriesForHome,
    required GetAllWeeklyPlansForHome getAllWeeklyPlansForHome,
    required GetRecipeSuggestionUsecase getRecipeSuggestionUsecase,
  }) : _userCubit = userCubit,
       _createKitchen = createKitchen,
       _joinKitchen = joinKitchen,
       _getAllWeeklyPlansForHome = getAllWeeklyPlansForHome,
       _getPantriesForHome = getPantriesForHome,
       _getRecipeSuggestionUsecase = getRecipeSuggestionUsecase,

       super(const HomeState()) {
    on<CreateKitchenEventForHome>(_onCreateKitchenEvent);
    on<GetPantriesItemsEventForHome>(_onGetPantryItems);
    on<JoinKitchenEventForHome>(_onJoinKitchenEvent);
    on<GetAllWeeklyPlansEventForHome>(_onGetAllWeeklyPlans);
    on<ResetHomeStateEvent>(_onResetHomeState);
    on<GetUserStorageAreaEvent>(_onGetUserStorageArea);
    on<GenerateGroceryList>(_onGetGenerateGroceryList);
    on<GetRecipeSuggestionEvent>(_onGetRecipeSuggestion);
  }
  Future<void> _onGetRecipeSuggestion(
    GetRecipeSuggestionEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(loadingRecipeSuggestion: true));

    final res = await _getRecipeSuggestionUsecase(
      GetRecipeSuggestionUsecaseParams(event.kitchenId),
    );

    res.fold(
      (failure) {
        emit(
          state.copyWith(
            loadingRecipeSuggestion: false,
            errorMessage: failure.message,
          ),
        );
      },
      (recipe) {
        final bool isValid =
            recipe.title.isNotEmpty && recipe.recipeShortSummary.isNotEmpty;

        emit(
          state.copyWith(
            loadingRecipeSuggestion: false,
            suggestedRecipe: isValid ? [recipe] : [],
          ),
        );
      },
    );
  }

  Future<void> _onGetGenerateGroceryList(
    GenerateGroceryList event,
    Emitter<HomeState> emit,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final allWeeklyPlans = state.dateBasedPlan;

    final List<IngredientEntity> missingIngredientNames = [];

    final dateFormatter = DateFormat('yyyy-MM-dd');

    for (var plan in allWeeklyPlans) {
      try {
        final planDate = dateFormatter.parse(plan.date);

        if (planDate.isBefore(today)) {
          continue;
        }

        for (var ingredient in plan.ingredients) {
          missingIngredientNames.add(ingredient);
          debugPrint(
            'Grocery: ${ingredient.amount} → ${DateFormat('EEE, MMM d').format(planDate)}',
          );
        }
      } on FormatException catch (e) {
        debugPrint('Invalid date format in plan: ${plan.date}, error: $e');
      }
    }

    missingIngredientNames.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    emit(state.copyWith(groceryList: missingIngredientNames));
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
          kitchenName: event.kitchenName,
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
        _userCubit.state.invitationCode,
        _userCubit.state.kitchenName,
        _userCubit.state.role,
        _userCubit.state.activeKitchenId,
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
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, errorMessage: 'An error occurred.'),
      );
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
      (pantries) async {
        final List<PantriesItemsEntity> pantryItems = [];
        final List<PantriesItemsEntity> lowStockItems = [];
        final List<PantriesItemsEntity> expiringItems = [];

        for (final item in pantries.items) {
          if (item.stockStatus == "low_stock") {
            lowStockItems.add(item);
            continue;
          }

          if (item.expiryStatus == "expiring_soon") {
            expiringItems.add(item);

            continue;
          }

          if (item.stockStatus == "in_stock" ||
              item.expiryStatus == "" ||
              item.expiryStatus == "null") {
            pantryItems.add(item);
            continue;
          }

          pantryItems.add(item);
        }

        emit(
          state.copyWith(
            isLoading: false,
            pantryItems: [pantries],
            lowStockItems: lowStockItems,
            expiringItems: expiringItems,
          ),
        );

        await _schedulePantryNotifications(
          lowStockItems: lowStockItems,
          expiringItems: expiringItems,
        );
      },
    );
  }

  Future<void> _schedulePantryNotifications({
    required List<PantriesItemsEntity> lowStockItems,
    required List<PantriesItemsEntity> expiringItems,
  }) async {
    final notificationService = NotificationService();
    final DateTime now = DateTime.now();
    final DateTime morningTime = DateTime(now.year, now.month, now.day, 9, 0);
    final DateTime eveningTime = DateTime(now.year, now.month, now.day, 18, 0);

    // Current items' base IDs
    final currentItemIds = <int>{};
    for (final item in lowStockItems) {
      currentItemIds.add(item.itemId.hashCode & 0x7fffffff); // morning
      currentItemIds.add((item.itemId.hashCode & 0x7fffffff) + 1); // evening
    }
    for (final item in expiringItems) {
      currentItemIds.add(
        (item.itemId.hashCode & 0x7fffffff) + 100000,
      ); // morning
      currentItemIds.add(
        (item.itemId.hashCode & 0x7fffffff) + 100001,
      ); // evening
    }

    // Pending notifications
    final pendingNotifications = await notificationService
        .pendingNotifications();

    // Cancel notifications for items that no longer exist
    for (final pending in pendingNotifications) {
      if (!currentItemIds.contains(pending.id)) {
        await notificationService.cancelNotification(pending.id);
        if (kDebugMode) {
          print("Canceled obsolete notification (ID: ${pending.id})");
        }
      }
    }

    final scheduledIds = pendingNotifications.map((e) => e.id).toSet();
    if (kDebugMode) {
      print("Pending notification IDs: $scheduledIds");
    }
    // Schedule notifications for current low stock items for the new items
    for (final item in lowStockItems) {
      final int morningId = item.itemId.hashCode & 0x7fffffff;
      final int eveningId = morningId + 1;

      if (!scheduledIds.contains(morningId)) {
        await notificationService.scheduleDaily(
          id: morningId,
          title: 'Low stock: ${item.name}',
          body:
              'You are running low on ${item.name} (${item.quantity} ${item.unit}).',
          dailyTime: morningTime,
          payload: jsonEncode({
            'type': 'low_stock',
            "invitationCode": _userCubit.state.invitationCode,
            "kitchenName": _userCubit.state.kitchenName,
            "role": _userCubit.state.role,
            'kitchenId': _userCubit.state.activeKitchenId,
            'item': item.toMap(),
          }),
        );
        if (kDebugMode) {
          print(
            "Scheduled morning low stock notification for ${item.name} (ID: $morningId)",
          );
        }
      }

      if (!scheduledIds.contains(eveningId)) {
        await notificationService.scheduleDaily(
          id: eveningId,
          title: 'Low stock: ${item.name}',
          body: 'Remember to restock ${item.name}.',
          dailyTime: eveningTime,
          payload: jsonEncode({
            'type': 'low_stock',
            "invitationCode": _userCubit.state.invitationCode,
            "kitchenName": _userCubit.state.kitchenName,
            "role": _userCubit.state.role,
            'kitchenId': _userCubit.state.activeKitchenId,
            'item': item.toMap(),
          }),
        );
        if (kDebugMode) {
          print(
            "Scheduled evening low stock notification for ${item.name} (ID: $eveningId)",
          );
        }
      }
    }

    // Schedule notifications for current expiring items
    for (final item in expiringItems) {
      final int morningId = (item.itemId.hashCode & 0x7fffffff) + 100000;
      final int eveningId = morningId + 1;

      if (!scheduledIds.contains(morningId)) {
        await notificationService.scheduleDaily(
          id: morningId,
          title: 'Expiring soon: ${item.name}',
          body: '${item.name} is expiring soon (${item.expireDate}).',
          dailyTime: morningTime,
          payload: jsonEncode({
            'type': 'expiring_soon',
            "invitationCode": _userCubit.state.invitationCode,
            "kitchenName": _userCubit.state.kitchenName,
            "role": _userCubit.state.role,
            'kitchenId': _userCubit.state.activeKitchenId,
            'item': item.toMap(),
          }),
        );
        if (kDebugMode) {
          print(
            "Scheduled morning expiring notification for ${item.name} (ID: $morningId)",
          );
        }
      }

      if (!scheduledIds.contains(eveningId)) {
        await notificationService.scheduleDaily(
          id: eveningId,
          title: 'Expiring soon: ${item.name}',
          body: 'Use ${item.name} before it expires.',
          dailyTime: eveningTime,
          payload: jsonEncode({
            'type': 'expiring_soon',
            "invitationCode": _userCubit.state.invitationCode,
            "kitchenName": _userCubit.state.kitchenName,
            "role": _userCubit.state.role,
            'kitchenId': _userCubit.state.activeKitchenId,
            'item': item.toMap(),
          }),
        );
        if (kDebugMode) {
          print(
            "Scheduled evening expiring notification for ${item.name} (ID: $eveningId)",
          );
        }
      }
    }
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
    if (_userCubit.state.activeKitchenId.isEmpty) return;
    emit(state.copyWith(loadingWeeklyPlans: true, showGroceryShimmer: true));
    final res = await _getAllWeeklyPlansForHome(
      GetAllWeeklyPlansForHomeParams(_userCubit.state.activeKitchenId),
    );

    await res.fold(
      (failure) {
        emit(
          state.copyWith(
            errorMessage: failure.message,
            loadingWeeklyPlans: false,
          ),
        );
      },
      (getAllWeeklyPlans) async {
        emit(
          state.copyWith(
            dateBasedPlan: getAllWeeklyPlans,
            loadingWeeklyPlans: false,
          ),
        );

        add(GenerateGroceryList());
        emit(state.copyWith(showGroceryShimmer: false));
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
      debugPrint(st.toString());
    }
  }
}
