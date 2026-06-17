import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/data/model/recipe_model.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/home/domain/entities/kitchen.dart';
import 'package:foodkitchen/features/home/domain/entities/pantry_items.dart';
import 'package:foodkitchen/features/home/domain/usecases/create_kitchen_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/get_all_requested_items.dart';
import 'package:foodkitchen/features/home/domain/usecases/get_all_weekly_plans_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/get_pantries_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/get_recipe_suggestion_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/respond_to_item_request.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_pantry_notifications.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/kitchens/domain/datasources/kitchen_document_firestore_datasource.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/submit_kitchen_join_request.dart';
import 'package:foodkitchen/features/planner/domain/entities/ingredient_entity.dart';
import 'package:intl/intl.dart';

part 'home_bloc_handlers.dart';
part 'home_bloc_handlers_part2.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserCubit _userCubit;
  final CreateKitchen _createKitchen;
  final RespondToItemRequest _respondToItemRequest;
  final GetPantriesForHome _getPantriesForHome;
  final GetAllWeeklyPlansForHome _getAllWeeklyPlansForHome;
  final GetRecipeSuggestionUsecase _getRecipeSuggestionUsecase;
  final GetAllRequestedItems _getAllRequestedItems;
  final SubmitKitchenJoinRequest _submitKitchenJoinRequest;
  final KitchenDocumentFirestoreDatasource _kitchenDocumentFirestore;

  HomeBloc({
    required UserCubit userCubit,
    required RespondToItemRequest respondToItemRequest,
    required CreateKitchen createKitchen,
    required GetPantriesForHome getPantriesForHome,
    required GetAllWeeklyPlansForHome getAllWeeklyPlansForHome,
    required GetRecipeSuggestionUsecase getRecipeSuggestionUsecase,
    required GetAllRequestedItems getAllRequestedItems,
    required SubmitKitchenJoinRequest submitKitchenJoinRequest,
    required KitchenDocumentFirestoreDatasource kitchenDocumentFirestore,
  }) : _userCubit = userCubit,
       _createKitchen = createKitchen,
       _getAllWeeklyPlansForHome = getAllWeeklyPlansForHome,
       _getPantriesForHome = getPantriesForHome,
       _getRecipeSuggestionUsecase = getRecipeSuggestionUsecase,
       _getAllRequestedItems = getAllRequestedItems,
       _respondToItemRequest = respondToItemRequest,
       _submitKitchenJoinRequest = submitKitchenJoinRequest,
       _kitchenDocumentFirestore = kitchenDocumentFirestore,

       super(const HomeState()) {
    on<CreateKitchenEventForHome>(
      (e, em) => _onCreateKitchenEvent(this, e, em),
    );
    on<GetPantriesItemsEventForHome>((e, em) => _onGetPantryItems(this, e, em));
    on<JoinKitchenEventForHome>((e, em) => _onJoinKitchenEvent(this, e, em));
    on<GetAllWeeklyPlansEventForHome>(
      (e, em) => _onGetAllWeeklyPlans(this, e, em),
    );
    on<ResetHomeStateEvent>((e, em) => _onResetHomeState(this, e, em));
    on<GetUserStorageAreaEvent>((e, em) => _onGetUserStorageArea(this, e, em));
    on<GenerateGroceryList>((e, em) => _onGetGenerateGroceryList(this, e, em));
    on<GetRecipeSuggestionEvent>(
      (e, em) => _onGetRecipeSuggestion(this, e, em),
    );
    on<GetAllRequestedItemsEvent>(
      (e, em) => _onGetAllRequestedItems(this, e, em),
    );
    on<RespondToItemRequestEvent>(
      (e, em) => _onRespondToItemRequestEvent(this, e, em),
    );
    on<RespondToItemRejectRequestEvent>(
      (e, em) => _onRespondToItemRejectRequestEvent(this, e, em),
    );
    on<RemoveMissingIngredientFromSuggestedEvent>(
      (e, em) => _onRemoveMissingIngredientFromSuggested(this, e, em),
    );
  }

  Future<void> _saveOrUpdateUserKitchen({
    required Kitchen kitchen,
    String? kitchenName,
  }) async {
    try {
      await _kitchenDocumentFirestore.setKitchenDocumentForNewHost(
        kitchenId: kitchen.kitchenId,
        userId: _userCubit.state.userId,
        invitationCode: kitchen.invitationCode,
        kitchenName: kitchenName,
      );
    } catch (e, st) {
      devPrint(st.toString());
    }
  }
}
