import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:foodkitchen/core/common/data/datasource/common_remote_datasource.dart';
import 'package:foodkitchen/core/common/data/model/recipe_model.dart';
import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:foodkitchen/features/home/data/datasource/home_remote_datasource.dart';
import 'package:foodkitchen/features/home/data/models/item_request_model.dart';
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
      final Map<String, dynamic> r = jsonObjectFromResponseData(response);
      final kitchenModel = KitchenModel(
        invitationCode: readJsonString(r, 'invitation_code'),
        kitchenId: readJsonString(r, 'kitchen_id'),
        message: readJsonString(r, 'message'),
      );

      return right(kitchenModel);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(unknownFailureFrom(e));
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
      return Left(unknownFailureFrom(e));
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
      return Left(f);
    } catch (e) {
      return Left(unknownFailureFrom(e));
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
          devPrint("Thumbnail decode failed: $e");
          mergedJson["thumbnail"] = null;
        }
      }

      final recipe = RecipeModel.fromJson(mergedJson);

      return Right(recipe);
    } on Failure catch (f) {
      return Left(f);
    } catch (e, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);
      return Left(UnknownFailure("Failed to load recipe suggestion"));
    }
  }

  @override
  Future<Either<Failure, List<ItemRequestModel>>> getAllRequestedItems({
    required String kitchenId,
  }) async {
    try {
      final response = await homeRemoteDataSource.getAllRequestedItems(
        kitchenId: kitchenId,
      );

      final pantryItems = <ItemRequestModel>[];

      for (int i = 0; i < (response as List).length; i++) {
        try {
          devLog("Parsing item $i: ${response[i]}");
          final item = ItemRequestModel.fromJson(response[i]);
          devLog("Parsed item $i successfully: $item");
          pantryItems.add(item);
        } catch (e, stack) {
          devLog("FAILED at item $i: ${response[i]}");
          devLog("ERROR: $e");
          devLog("STACK: $stack");
        }
      }

      devLog("Total parsed: ${pantryItems.length}");
      return Right(pantryItems);
    } on Failure catch (f) {
      return Left(f);
    } catch (e, stack) {
      devLog("OUTER ERROR: $e");
      devLog("OUTER STACK: $stack");
      return Left(unknownFailureFrom(e));
    }
  }

  @override
  Future<Either<Failure, String>> respondToItemRequest({
    required String action,
    required String rejectReason,
    required String requestId,
  }) async {
    try {
      final response = await homeRemoteDataSource.respondToItemRequest(
        action: action,
        rejectReason: rejectReason,
        requestId: requestId,
      );
      return right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(unknownFailureFrom(e));
    }
  }
}
