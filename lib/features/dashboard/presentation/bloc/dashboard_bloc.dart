import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/get_kitchen_members.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/kick_member.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/make_cohost.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetKitchenMembers _getKitchenMembers;
  final MakeCohost _makeCohost;
  final KickMember _kickMember;
  DashboardBloc({
    required GetKitchenMembers getMembers,
    required MakeCohost makeCohost,
    required KickMember kickMember,
  }) : _getKitchenMembers = getMembers,
       _makeCohost = makeCohost,
       _kickMember = kickMember,

       super(DashboardInitial()) {
    on<DashboardEvent>((_, emit) => emit(DashboardLoading()));
    on<GetKitchenMembersEvent>(_onGetDashboardMembers);
    on<MakeCohostEvent>(_onMakeCohostEvent);
    on<KickMemberEvent>(_onKickMemberEvent);
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
}
