import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/services/fcm/fcm_service.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/get_kitchen_members.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/kick_member.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/make_cohost.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_bloc.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_event.dart';
import 'package:intl/intl.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetKitchenMembers _getKitchenMembers;
  final MakeCohost _makeCohost;
  final KickMember _kickMember;
  // ignore: unused_field
  final KitchenBloc _kitchenBloc;
  final UserCubit _userCubit;
  DashboardBloc({
    required GetKitchenMembers getMembers,
    required MakeCohost makeCohost,
    required KickMember kickMember,
    required KitchenBloc kitchenBloc,
    required UserCubit userCubit,
  }) : _getKitchenMembers = getMembers,
       _makeCohost = makeCohost,
       _kickMember = kickMember,
       _kitchenBloc = kitchenBloc,
       _userCubit = userCubit,

       super(DashboardInitial()) {
    on<GetKitchenMembersEvent>(_onGetDashboardMembers);
    on<MakeCohostEvent>(_onMakeCohostEvent);
    on<KickMemberEvent>(_onKickMemberEvent);
    on<ApproveRequestEvent>(_onApproveRequestEvent);
    on<DeclineRequestEvent>(_onDeclineRequestEvent);
    // on<DeclineRequest>(_onDeclineRequest);
  }

  Future<void> _onGetDashboardMembers(
    GetKitchenMembersEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    final res = await _getKitchenMembers(
      GetKitchenMembersParams(kitchenId: event.activeKitchenId),
    );

    res.fold((failure) => emit(DashboardFailure(failure.message)), (members) {
      emit(DashboardLoaded(members));
    });
  }

  Future<void> _onMakeCohostEvent(
    MakeCohostEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    final res = await _makeCohost(
      MakeCohostParams(
        kitchenId: event.activeKitchenId,
        memberId: event.memberId,
      ),
    );

    res.fold((failure) => emit(DashboardFailure(failure.message)), (message) {
      emit(DashboardSuccess(message));
    });
  }

  Future<void> _onKickMemberEvent(
    KickMemberEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    final res = await _kickMember(
      KickMemberParams(
        kitchenId: event.activeKitchenId,
        memberId: event.memberId,
      ),
    );

    res.fold((failure) => emit(DashboardFailure(failure.message)), (message) {
      emit(DashboardSuccess(message));
    });
  }

  Future<void> _onApproveRequestEvent(
    ApproveRequestEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(ApproveLoading());
    final userId = event.memberId;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (!userDoc.exists) {
      emit(DashboardFailure("User not found"));
      return;
    }

    final kitchenQuery = await FirebaseFirestore.instance
        .collection('kitchens')
        .where("user_id", isEqualTo: _userCubit.state.userId)
        .where("kitchen_id", isEqualTo: event.kitchenId)
        .get();

    if (kitchenQuery.docs.isEmpty) {
      emit(DashboardFailure("Kitchen not found"));
      return;
    }

    final kitchenDoc = kitchenQuery.docs.first;
    final kitchenData = kitchenDoc.data();
    final inviteCode = kitchenData['invitation_code'] ?? '';
    final kitchenName = kitchenData['kitchen_name'] ?? '';

    final userData = userDoc.data();
    final userDeviceToken = userData?['user_device_token'];

    if (userDeviceToken == null || userDeviceToken.isEmpty) {
      emit(DashboardFailure("User device token not found"));
      return;
    }

    final notificationData = {
      "status": true,
      'title': "You have been added to the kitchen",
      'body':
          // ignore: unnecessary_brace_in_string_interps
          "Your request to join the kitchen \"${kitchenName}\" has been approved by the host. You are now added to the kitchen. You can access it anytime using this invitation code: $inviteCode",
      'host_user_id': userId,
      'sender_user_id': _userCubit.state.userId,
      'sender_name':
          "${_userCubit.state.firstName} ${_userCubit.state.lastName}",
      'kitchen_id': event.kitchenId,
      'invitation_code': inviteCode,
      'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'read': false,
    };

    await FCMService().sendNotification(
      userDeviceToken,
      "You have been added to the kitchen",
      "Your request to join the kitchen \"$kitchenName\" has been approved by the host. You are now added to the kitchen. You can access it anytime using this invitation code: $inviteCode",
    );

    _kitchenBloc.add(MemberApprovedEvent(inviteCode));
    await FirebaseFirestore.instance
        .collection('notifications')
        .add(notificationData);
    updateNotificationStatus(event.id);
    AppToast.show("Kitchen approval notification sent", ToastType.success);
    emit(DashboardSuccess("Approved"));
  }

  Future<void> _onDeclineRequestEvent(
    DeclineRequestEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DeclineLoading());
    final userId = event.memberId;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (!userDoc.exists) {
      emit(DashboardFailure("User not found"));
      return;
    }

    final kitchenQuery = await FirebaseFirestore.instance
        .collection('kitchens')
        .where("user_id", isEqualTo: _userCubit.state.userId)
        .where("kitchen_id", isEqualTo: event.kitchenId)
        .get();

    if (kitchenQuery.docs.isEmpty) {
      emit(DashboardFailure("Kitchen not found"));
      return;
    }

    final kitchenDoc = kitchenQuery.docs.first;
    final kitchenData = kitchenDoc.data();
    final inviteCode = kitchenData['invitation_code'] ?? '';
    final kitchenName = kitchenData['kitchen_name'] ?? '';
    final userData = userDoc.data();
    final userDeviceToken = userData?['user_device_token'];

    if (userDeviceToken == null || userDeviceToken.isEmpty) {
      emit(DashboardFailure("User device token not found"));
      return;
    }

    final notificationData = {
      "status": false,
      'title': "Your request to join the kitchen was declined",
      'body':
          "Your request to join the kitchen \"$kitchenName\" has been declined by the host. You can try again later or contact the host for more details.",
      'host_user_id': userId,
      'sender_user_id': _userCubit.state.userId,
      'sender_name':
          "${_userCubit.state.firstName} ${_userCubit.state.lastName}",
      'kitchen_id': event.kitchenId,
      'invitation_code': inviteCode,
      'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'read': false,
    };

    await FCMService().sendNotification(
      userDeviceToken,
      "Your request to join the kitchen was declined",
      "Your request to join the kitchen \"$kitchenName\" has been declined by the host. You can try again later or contact the host for more details.",
    );

    await FirebaseFirestore.instance
        .collection('notifications')
        .add(notificationData);
    updateNotificationStatus(event.id);
    AppToast.show("Request Declined Successfully", ToastType.success);
    emit(DashboardSuccess("Declined"));
  }

  Future<void> updateNotificationStatus(int id) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('id', isEqualTo: id)
        .get();

    for (final doc in querySnapshot.docs) {
      await doc.reference.update({'status': true});
    }
  }
}
