import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/kitchens/domain/datasources/kitchen_document_firestore_datasource.dart';
import 'package:foodkitchen/features/kitchens/domain/entities/kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/create_kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/get_kitchens.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/invite_user.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/join_kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/leave_kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/remove_kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/submit_kitchen_join_request.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_event.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_state.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';

part 'kitchen_bloc_handlers.dart';

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
  final SubmitKitchenJoinRequest _submitKitchenJoinRequest;
  final KitchenDocumentFirestoreDatasource _kitchenDocumentFirestore;

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
    required SubmitKitchenJoinRequest submitKitchenJoinRequest,
    required KitchenDocumentFirestoreDatasource kitchenDocumentFirestore,
  }) : _getKitchens = getKitchens,
       _createKitchen = createKitchen,
       _joinKitchen = joinKitchen,
       _leaveKitchenUsecase = leaveKitchenUsecase,
       _removeKitchenUsecase = removeKitchenUsecase,
       _inviteUser = inviteUser,
       _submitKitchenJoinRequest = submitKitchenJoinRequest,
       _kitchenDocumentFirestore = kitchenDocumentFirestore,
       _homeBloc = homeBloc,
       _userCubit = userCubit,

       _plannerBloc = plannerBloc,
       _groceryBloc = groceryBloc,
       super(KitchenInitial()) {
    on<FetchKitchens>((e, em) => _onFetchKitchens(this, e, em));
    on<CreateKitchenEvent>((e, em) => _onCreateKitchenEvent(this, e, em));
    on<JoinKitchenEvent>((e, em) => _onJoinKitchenEvent(this, e, em));
    on<SwitchKitchenEvent>((e, em) => _onSwitchKitchen(this, e, em));
    on<LeaveKitchenEvent>((e, em) => _onLeaveKitchen(this, e, em));
    on<RemoveKitchenEvent>((e, em) => _onRemoveKitchen(this, e, em));
    on<DeleteOrLeaveKitchenEvent>(
      (e, em) => _onDeleteOrLeaveKitchen(this, e, em),
    );
    on<FetchAllUsers>((e, em) => _onFetchAllUsers(this, e, em));
    on<InviteUserEvent>((e, em) => _onInviteUser(this, e, em));
    on<MemberApprovedEvent>((e, em) => _onMemberApproved(this, e, em));
  }

  Future<void> _saveOrUpdateUserKitchen({required Kitchen kitchen}) async {
    try {
      if (kitchen.role != 'host') {
        devPrint('Skipping kitchen update — user is not host');
        return;
      }

      await _kitchenDocumentFirestore.mergeUpdateKitchenForHost(
        kitchenId: kitchen.kitchenId,
        userId: _userCubit.state.userId,
        kitchenName: kitchen.kitchenName,
        role: kitchen.role,
        invitationCode: kitchen.invitationCode,
      );
    } catch (e, st) {
      devPrint('Kitchen update failed: $e\n$st');
    }
  }
}
