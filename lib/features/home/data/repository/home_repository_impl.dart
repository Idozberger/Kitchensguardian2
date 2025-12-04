import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:foodkitchen/core/common/data/datasource/common_remote_datasource.dart';
import 'package:foodkitchen/core/common/data/model/recipe_model.dart';
import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/global/functions/logs.dart';
import 'package:foodkitchen/features/home/data/datasource/home_remote_datasource.dart';
import 'package:foodkitchen/features/home/data/models/kitchen_model.dart';
import 'package:foodkitchen/features/home/data/models/pantry_data_model.dart';
import 'package:foodkitchen/features/home/domain/entities/kitchen.dart';
import 'package:foodkitchen/features/home/domain/entities/pantry_data.dart';
import 'package:foodkitchen/features/home/domain/repository/home_repository.dart';
import 'package:fpdart/fpdart.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource homeRemoteDataSource;
  final CommonRemoteDatasource commonRemoteDatasource;
  HomeRepositoryImpl({
    required this.homeRemoteDataSource,
    required this.commonRemoteDatasource,
  });
  @override
  Future<Either<Failure, Kitchen>> createKitchen({
    required String kitchenName,
  }) async {
    try {
      final response = await homeRemoteDataSource.createKitchen(
        kitchenName: kitchenName,
      );
      final kitchenModel = KitchenModel(
        invitationCode: response["invitation_code"],
        kitchenId: response["kitchen_id"],
        message: response["message"],
      );

      return right(kitchenModel);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> joinKitchen({
    required String invitationCode,
  }) async {
    try {
      final response = await homeRemoteDataSource.joinKitchen(
        invitationCode: invitationCode,
      );
      return right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PantriesDataEntity>> getItems({
    required String kitchenId,
  }) async {
    try {
      final response = await homeRemoteDataSource.getPantriesItems(
        kitchenId: kitchenId,
      );
      final pantryData = PantriesDataModel.fromJson(response);

      return Right(pantryData);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RecipeEntity>>> getAllWeeklyPlans({
    required String kicthenId,
  }) async {
    try {
      final response = await homeRemoteDataSource.getWeeklyPlans(
        kitchenId: kicthenId,
      );

      final generatedRecipes = (response as List).map((e) {
        return RecipeModel.fromJson(e as Map<String, dynamic>);
      }).toList();

      return Right(generatedRecipes);
    } on Failure catch (f) {
      logInfo("Failure: ${f.message}");
      return Left(f);
    } catch (e) {
      logInfo("Error: ${e.toString()}");
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RecipeEntity>> getRecipeSuggestion({
    required String kicthenId,
  }) async {
    try {
      final response = await homeRemoteDataSource.getRecipeSuggestion(
        kitchenId: kicthenId,
      );

      final Map<String, dynamic> recipeJson = Map<String, dynamic>.from(
        response["recipe"] as Map? ?? {},
      );

      print("(suggestionapi)-- Raw recipe: $recipeJson");

      final Map<String, dynamic> mergedJson = {
        ...recipeJson,
        "expiring_items": response["expiring_items"],
        "expiring_items_count": response["expiring_items_count"],
        if (recipeJson.containsKey("expiring_items_used"))
          "expiring_items_used": recipeJson["expiring_items_used"],
      };

      if (mergedJson["thumbnail"] != null &&
          mergedJson["thumbnail"] is String) {
        try {
          final String thumb = mergedJson["thumbnail"] as String;
          final String cleanedBase64 = thumb.contains(',')
              ? thumb.split(',').last.trim()
              : thumb.trim();

          mergedJson["thumbnail"] = base64Decode(cleanedBase64);
        } catch (e) {
          print("Thumbnail decode failed: $e");
          mergedJson["thumbnail"] = Uint8List(0);
        }
      }

      print(
        "(suggestionapi)-- Final merged JSON with decoded thumbnail: $mergedJson",
      );

      // Now safe to parse
      final recipe = RecipeModel.fromJson(mergedJson);

      print("(suggestionapi)-- Success: $recipe");
      return Right(recipe);
    } on Failure catch (f) {
      logInfo("Known Failure: ${f.message}");
      return Left(f);
    } catch (e, stackTrace) {
      logInfo("Unexpected Error: $e");
      debugPrintStack(stackTrace: stackTrace);
      return Left(UnknownFailure("Failed to load recipe suggestion"));
    }
  }
}
