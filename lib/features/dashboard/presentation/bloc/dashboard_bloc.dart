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
    on<DashboardEvent>((_, emit) => emit(DashboardLoading()));
    on<GetKitchenMembersEvent>(_onGetDashboardMembers);
    on<MakeCohostEvent>(_onMakeCohostEvent);
    on<KickMemberEvent>(_onKickMemberEvent);
    on<ApproveRequestEvent>(_onApproveRequestEvent);
    // on<DeclineRequest>(_onDeclineRequest);
  }

  Future<void> _onGetDashboardMembers(
    GetKitchenMembersEvent event,
    Emitter<DashboardState> emit,
  ) async {
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

    final userData = userDoc.data();
    final userDeviceToken = userData?['user_device_token'];

    if (userDeviceToken == null || userDeviceToken.isEmpty) {
      emit(DashboardFailure("User device token not found"));
      return;
    }

    final notificationData = {
      "status": true,
      'title': "Your kitchen join request is approved",
      'body':
          "Your request to join the kitchen \"${event.kitchenName}\" has been approved. You can now join again using this invitation code: $inviteCode",
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
      "Your kitchen join request is approved",
      "Your request to join the kitchen \"${event.kitchenName}\" has been approved. You can now join again using this invitation code: $inviteCode",
    );
    _kitchenBloc.add(MemberApprovedEvent(inviteCode));
    await FirebaseFirestore.instance
        .collection('notifications')
        .add(notificationData);
    updateNotificationStatus(event.id);
    AppToast.show("Kitchen approval notification sent", ToastType.success);
    emit(DashboardSuccess("Approved"));
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
