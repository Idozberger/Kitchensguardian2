import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/approve_kitchen_join_request.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/decline_kitchen_join_request.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/demote_cohost.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/get_kitchen_members.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/get_recipe_details.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/kick_member.dart';
import 'package:foodkitchen/features/dashboard/domain/usecases/make_cohost.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_bloc.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_event.dart';

part 'dashboard_bloc_handlers.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetKitchenMembers _getKitchenMembers;
  final MakeCohost _makeCohost;
  final KickMember _kickMember;
  final DemoteCohost _demoteCohost;

  final KitchenBloc _kitchenBloc;
  final UserCubit _userCubit;
  final GetRecipeDetails _getRecipeDetails;
  final ApproveKitchenJoinRequest _approveKitchenJoinRequest;
  final DeclineKitchenJoinRequest _declineKitchenJoinRequest;

  DashboardBloc({
    required GetKitchenMembers getMembers,
    required MakeCohost makeCohost,
    required KickMember kickMember,
    required KitchenBloc kitchenBloc,
    required DemoteCohost demoteCohost,
    required UserCubit userCubit,
    required GetRecipeDetails getRecipeDetails,
    required ApproveKitchenJoinRequest approveKitchenJoinRequest,
    required DeclineKitchenJoinRequest declineKitchenJoinRequest,
  }) : _getKitchenMembers = getMembers,
       _makeCohost = makeCohost,
       _kickMember = kickMember,
       _demoteCohost = demoteCohost,
       _kitchenBloc = kitchenBloc,
       _getRecipeDetails = getRecipeDetails,
       _userCubit = userCubit,
       _approveKitchenJoinRequest = approveKitchenJoinRequest,
       _declineKitchenJoinRequest = declineKitchenJoinRequest,
       super(DashboardInitial()) {
    on<GetKitchenMembersEvent>((e, em) => _onGetDashboardMembers(this, e, em));
    on<MakeCohostEvent>((e, em) => _onMakeCohostEvent(this, e, em));
    on<KickMemberEvent>((e, em) => _onKickMemberEvent(this, e, em));
    on<DemoteCohostEvent>((e, em) => _onDemoteCohostEvent(this, e, em));
    on<ApproveRequestEvent>((e, em) => _onApproveRequestEvent(this, e, em));
    on<DeclineRequestEvent>((e, em) => _onDeclineRequestEvent(this, e, em));
    on<GetRecipeDetailsEvent>((e, em) => _onGetRecipeDetailsEvent(this, e, em));
  }
}
