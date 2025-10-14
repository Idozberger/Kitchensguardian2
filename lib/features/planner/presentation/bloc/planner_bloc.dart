import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/features/planner/domain/usecases/generate_recipes.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';

class PlannerBloc extends Bloc<PlannerEvent, PlannerState> {
  final GenerateRecipes _generateRecipes;

  PlannerBloc({required GenerateRecipes generateRecipes})
    : _generateRecipes = generateRecipes,

      super(PlannerInitial()) {
    on<PlannerEvent>((_, emit) => emit(PlannerLoading()));
    on<GenerateRecipesEvent>(_onGenerateRecipes);
  }
  Future<void> _onGenerateRecipes(
    GenerateRecipesEvent event,
    Emitter<PlannerState> emit,
  ) async {
    final res = await _generateRecipes(
      GenerateRecipesParams(
        instructions: event.instructions,
        kitchenId: event.kitchenId,
      ),
    );

    res.fold((failure) => emit(PlannerFailure(failure.message)), (recipes) {
      emit(PlannerRecipesLoaded(recipes));
    });
  }
}
