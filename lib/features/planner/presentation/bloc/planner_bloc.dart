// ignore_for_file: unused_local_variable
// Debug/temp locals left near complex merge logic; remove when stabilizing bloc.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/data/model/recipe_model.dart';
import 'package:foodkitchen/core/services/notifications/flutter_local_notifications_service.dart';
import 'package:foodkitchen/core/services/recipe_limit/recipe_limit_service.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/planner/data/models/merged_meal_plan_model.dart';
import 'package:foodkitchen/features/planner/domain/entities/ingredient_entity.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';
import 'package:foodkitchen/features/planner/domain/usecases/add_to_favourite_recipe.dart';
import 'package:foodkitchen/features/planner/domain/usecases/add_to_weekly_plan.dart';
import 'package:foodkitchen/features/planner/domain/usecases/check_missing_ingredients.dart';
import 'package:foodkitchen/features/planner/domain/usecases/create_plan.dart';
import 'package:foodkitchen/features/planner/domain/usecases/delete_meal_type_from_weekly_plan.dart';
import 'package:foodkitchen/features/planner/domain/usecases/delete_plan.dart';
import 'package:foodkitchen/features/planner/domain/usecases/delete_plan_remote_db.dart';
import 'package:foodkitchen/features/planner/domain/usecases/favourite_recipes.dart';
import 'package:foodkitchen/features/planner/domain/usecases/generate_recipes.dart';
import 'package:foodkitchen/features/planner/domain/usecases/get_all_plans.dart';
import 'package:foodkitchen/features/planner/domain/usecases/get_date_range.dart';
import 'package:foodkitchen/features/planner/domain/usecases/get_meal_by_date.dart';
import 'package:foodkitchen/features/planner/domain/usecases/mark_recipe_finished.dart';
import 'package:foodkitchen/features/planner/domain/usecases/remove_from_favourite_recipe.dart';
import 'package:foodkitchen/features/planner/domain/usecases/request_missing_items.dart';
import 'package:foodkitchen/features/planner/domain/usecases/set_date_range.dart';
import 'package:foodkitchen/features/planner/domain/usecases/submit_recipe_start_request.dart';
import 'package:foodkitchen/features/planner/domain/usecases/update_meal_plan.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_date_range_rollforward.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_meal_plan_merge.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_recipe_missing_helpers.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/planner_date_formatter.dart';

part 'planner_bloc_handlers_cooking_session.dart';
part 'planner_bloc_handlers_date_and_plans.dart';
part 'planner_bloc_handlers_favourites_and_weekly.dart';
part 'planner_bloc_handlers_meal_editor.dart';
part 'planner_bloc_handlers_plans_remote.dart';
part 'planner_bloc_handlers_requests.dart';

class PlannerBloc extends Bloc<PlannerEvent, PlannerState> {
  final UserCubit _userCubit;
  final HomeBloc _homeBloc;
  final GroceryBloc _groceryBloc;
  final GenerateRecipes _generateRecipes;
  final FavouriteRecipes _favouriteRecipes;
  final AddToFavouriteRecipe _addToFavouriteRecipe;
  final RemoveFromFavouriteRecipe _removeFromFavouriteRecipe;
  final AddToWeeklyPlan _addToWeeklyPlan;
  final DeletePlan _deletePlan;
  final DeleteMealTypeFromWeeklyPlan _deleteMealTypeFromWeeklyPlan;
  final MarkRecipeFinished _markRecipeFinished;
  final RequestMissingItems _requestMissingItems;
  final CreatePlan _createPlan;
  final DeletePlanRemoteDb _deletePlanRemoteDb;
  final UpdateMealPlan _updateMealPlan;
  final GetMealByDate _getMealByDate;
  final GetAllPlans _getAllPlans;
  final GetDateRange _getDateRange;
  final SetDateRange _setDateRange;
  final CheckMissingIngredients _checkMissingIngredients;
  final SubmitRecipeStartRequest _submitRecipeStartRequest;

  PlannerBloc({
    required UserCubit userCubit,
    required HomeBloc homeBloc,
    required GenerateRecipes generateRecipes,
    required FavouriteRecipes favouriteRecipes,
    required AddToFavouriteRecipe addToFavouriteRecipe,
    required RemoveFromFavouriteRecipe removeFromFavouriteRecipe,
    required AddToWeeklyPlan addToWeeklyPlan,
    required DeletePlan deletePlan,
    required RequestMissingItems requestMissingItems,
    required GroceryBloc groceryBloc,
    required DeleteMealTypeFromWeeklyPlan deleteMealTypeFromWeeklyPlan,
    required MarkRecipeFinished markRecipeFinished,
    required CreatePlan createPlan,
    required DeletePlanRemoteDb deletePlanRemoteDb,
    required UpdateMealPlan updateMealPlan,
    required GetMealByDate getMealByDate,
    required GetAllPlans getAllPlans,
    required GetDateRange getDateRange,
    required SetDateRange setDateRange,
    required CheckMissingIngredients checkMissingIngredients,
    required SubmitRecipeStartRequest submitRecipeStartRequest,
  }) : _generateRecipes = generateRecipes,
       _favouriteRecipes = favouriteRecipes,
       _addToFavouriteRecipe = addToFavouriteRecipe,
       _removeFromFavouriteRecipe = removeFromFavouriteRecipe,
       _addToWeeklyPlan = addToWeeklyPlan,
       _deletePlan = deletePlan,
       _homeBloc = homeBloc,
       _deleteMealTypeFromWeeklyPlan = deleteMealTypeFromWeeklyPlan,
       _markRecipeFinished = markRecipeFinished,
       _userCubit = userCubit,
       _requestMissingItems = requestMissingItems,
       _groceryBloc = groceryBloc,
       _createPlan = createPlan,
       _deletePlanRemoteDb = deletePlanRemoteDb,
       _updateMealPlan = updateMealPlan,
       _getMealByDate = getMealByDate,
       _getAllPlans = getAllPlans,
       _getDateRange = getDateRange,
       _setDateRange = setDateRange,
       _checkMissingIngredients = checkMissingIngredients,
       _submitRecipeStartRequest = submitRecipeStartRequest,

       super(PlannerState()) {
    on<GetFavouriteRecipesEvent>(
      (e, em) => _onGetFavouriteRecipes(this, e, em),
    );
    on<GenerateRecipesEvent>((e, em) => _onGenerateRecipes(this, e, em));
    on<AddToFavouriteRecipeEvent>(
      (e, em) => _onAddToFavouriteRecipe(this, e, em),
    );
    on<RemoveFromFavouriteRecipeEvent>(
      (e, em) => _onRemoveFromFavouriteRecipe(this, e, em),
    );
    on<ClearAiGeneratedRecipes>(
      (e, em) => _onClearAiGeneratedRecipes(this, e, em),
    );
    on<AddToWeeklyPlanEvent>((e, em) => _onAddToWeeklyPlan(this, e, em));
    on<GetAllWeeklyPlansEvent>((e, em) => _onGetAllMealPlans(this, e, em));
    on<DeletePlanEvent>((e, em) => _onDeletePlan(this, e, em));
    on<GetDateBasedPlans>((e, em) => _onGetDateBasedPlans(this, e, em));
    on<DeleteMealTypeFromWeeklyPlanEvent>(
      (e, em) => _onDeleteMealTypeFromWeeklyPlan(this, e, em),
    );
    on<MarkRecipeFinishedEvent>((e, em) => _onMarkRecipeFinished(this, e, em));
    on<UpdateStartRecipeEvent>((e, em) => _onUpdateStartRecipe(this, e, em));
    on<CancelInProgressRecipeEvent>(
      (e, em) => _onCancelInProgressRecipe(this, e, em),
    );
    on<ResetPlannerStateEvent>((e, em) => _onResetPlanner(this, e, em));
    on<AddMealPlanEvent>((e, em) => _onAddMealPlan(this, e, em));
    on<RequestMissingItemsEvent>(
      (e, em) => _onRequestMissingItems(this, e, em),
    );
    on<RemoveMissingIngredientEvent>(
      (e, em) => _onRemoveMissingIngredient(this, e, em),
    );
    on<ResetMealPlanState>((e, em) => _onResetMealPlanState(this, e, em));
    on<DeleteMealPlanEvent>((e, em) => _onDeleteMealPlan(this, e, em));
    on<UpdateTypeSelectedAndDateEvent>(
      (e, em) => _onUpdateMealTypeSelectedAndDate(this, e, em),
    );
    on<CreatePlanEvent>((e, em) => _onCreatePlan(this, e, em));
    on<DeletePlanFromRemoteDbEvent>(
      (e, em) => _onDeletePlanFromRemoteDb(this, e, em),
    );
    on<UpdateMealPlanEvent>((e, em) => _onUpdateMealPlan(this, e, em));
    on<GetMealByDateEvent>((e, em) => _onGetMealByDate(this, e, em));
    on<EditMealEvent>((e, em) => _onEditMeal(this, e, em));
    on<GetDateRangeEvent>((e, em) => _onGetDateRangeEvent(this, e, em));
    on<SetDateRangeEvent>((e, em) => _onSetDateRange(this, e, em));
    on<UpdateRecipeFinishedState>(
      (e, em) => _onUpdateRecipeFinishedState(this, e, em),
    );
    on<RequestStartRecipeEvent>((e, em) => _onRequestStartRecipe(this, e, em));
    on<RemoveMissingIngredientFromPlanEvent>(
      (e, em) => _onRemoveMissingIngredientFromPlanEvent(this, e, em),
    );
    on<CheckMissingIngredientsEvent>(
      (e, em) => _onCheckMissingIngredientsEvent(this, e, em),
    );
  }

  void updateStartEndDate() {
    queueDefaultPlannerDateRange(userCubit: _userCubit, enqueue: add);
  }
}
