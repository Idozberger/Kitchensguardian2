import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/dashboard/domain/entities/member.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class DashboardRepository {
  Future<Either<Failure, List<Member>>> getKichenMembers({
    required String kitchenId,
  });
  Future<Either<Failure, String>> makeCohost({
    required String kitchenId,
    required String memberId,
  });
  Future<Either<Failure, String>> kickMember({
    required String kitchenId,
    required String memberId,
  });
  Future<Either<Failure, String>> demoteCohost({
    required String kitchenId,
    required String memberId,
  });
  Future<Either<Failure, RecipeEntity>> getRecipeDetails({
    required String recipeId,
    required String kitchenId,
  });
}
