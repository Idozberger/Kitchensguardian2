part of 'package:foodkitchen/features/pantry/data/datasource/pantry_remote_datasource.dart';

Future<String> _pantryImplCompressImage(
  PantryRemoteDatasourceImpl ds,
  File imageFile,
) async {
  var result = await FlutterImageCompress.compressWithList(
    imageFile.readAsBytesSync(),
    minWidth: 800,
    minHeight: 600,
    quality: 15,
    rotate: 0,
    inSampleSize: 1,
    autoCorrectionAngle: true,
    format: CompressFormat.jpeg,
    keepExif: false,
  );
  String base64Thumbnail = base64Encode(result);

  String dataUri = "data:image/jpeg;base64,$base64Thumbnail";

  return dataUri;
}

Future<String> _pantryImplAddPantryItem(
  PantryRemoteDatasourceImpl ds, {
  required PantryModel pantryModel,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.addPantryItem,
      data: pantryModel.toJson(),
    );
    devLog("add pantry status: $response");
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'];
      throw apiExceptionFrom(message);
    }
    final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
    return readJsonString(ok, 'message');
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}

Future<({List<Map<String, dynamic>> results, bool hasMore})>
_pantryImplSearchSharedIngredients(
  PantryRemoteDatasourceImpl ds, {
  required String query,
  required int page,
}) async {
  try {
    final url =
        "${AppConstants.searchSharedIngredients}?q=${Uri.encodeQueryComponent(query)}&page_size=${AppConstants.sharedIngredientsSearchPageSize}&page=$page";

    final response = await ds.dio.get(url);

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );
      throw apiExceptionFrom(data['error'] ?? 'Unknown error');
    }

    final Map<String, dynamic> root = jsonObjectFromResponseData(response.data);
    final Object? resultsRaw = root['results'];
    final results = resultsRaw is List
        ? resultsRaw.map(jsonObjectFromResponseData).toList()
        : <Map<String, dynamic>>[];
    final totalPages = readJsonInt(root, 'total_pages', fallback: 1);
    return (results: results, hasMore: page < totalPages);
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}

Future<List<Map<String, dynamic>>> _pantryImplGetPantryItems(
  PantryRemoteDatasourceImpl ds, {
  required String kitchenId,
}) async {
  try {
    devLog("Get pantry items");
    final url = "${AppConstants.getPantryItems}?kitchen_id=$kitchenId";

    final response = await ds.dio.get(url);

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'] ?? 'Unknown error';

      throw apiExceptionFrom(message);
    }

    final Map<String, dynamic> root = jsonObjectFromResponseData(response.data);
    final Object? itemsRaw = root['items'];

    if (itemsRaw is List) {
      final parsedList = itemsRaw.map(jsonObjectFromResponseData).toList();

      return parsedList;
    } else {
      throw Exception("Invalid data");
    }
  } on DioException catch (e) {
    final Object error = await ds.dio.handleError(e);

    throw error;
  } catch (e) {
    rethrow;
  }
}

Future<Map<String, dynamic>> _pantryImplScanRecipt(
  PantryRemoteDatasourceImpl ds, {
  required String filePath,
  required String currency,
  required String country,
  required String kitchenId,
}) async {
  try {
    if (!File(filePath).existsSync()) {
      throw const Failure(
        'Receipt photo could not be found. Please retake the photo.',
      );
    }

    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
        contentType: DioMediaType('image', 'jpeg'),
      ),
      "kitchen_id": kitchenId,
      "currency": currency,
      "country": country,
      "use_google_document": false,
    });

    final response = await ds.dio.post(
      AppConstants.scanRecipt,
      data: formData,
      // KG-13: AI recognition can run longer than the app-wide 60s default
      // under load — give this call its own headroom without loosening the
      // timeout for every other endpoint.
      options: Options(receiveTimeout: const Duration(seconds: 120)),
    );
    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 202) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );
      final Object? message = data['error'] ?? 'Unknown error';
      throw ServerFailure(message.toString());
    }

    final Map<String, dynamic> body = jsonObjectFromResponseData(response.data);

    // Some environments still answer synchronously with the full result on
    // the POST itself; only poll when the backend actually queued an async
    // job (job_id present, no items yet).
    if (body.containsKey('items')) {
      final String syncMessage = readJsonString(
        body,
        'message',
        fallback: 'Unknown response',
      );
      final syncItems = parseScanReceiptItems(body['items']);
      return {"message": syncMessage, "items": syncItems};
    }

    final String jobId = readJsonString(body, 'job_id');
    if (jobId.isEmpty) {
      throw const ServerFailure('Receipt scan could not be started.');
    }

    const pollInterval = Duration(seconds: 2);
    const maxAttempts = 90; // ~3 minutes, matches suggested UX cap

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      await Future<void>.delayed(pollInterval);

      final statusResponse = await ds.dio.get(
        AppConstants.scanReciptJobStatus(jobId),
      );
      final outcome = parseScanReceiptJob(
        jsonObjectFromResponseData(statusResponse.data),
      );

      if (outcome.status == ScanReceiptJobStatus.finished) {
        final Map<String, dynamic> result = outcome.result ?? {};
        final String message = readJsonString(
          result,
          'message',
          fallback: 'Unknown response',
        );
        final parsedItems = parseScanReceiptItems(result['items']);

        devLog(
          "ParsedItems: ${parsedItems.map((item) => item['recommended_storage'])}",
        );

        return {"message": message, "items": parsedItems};
      }

      if (outcome.status == ScanReceiptJobStatus.failed) {
        throw ServerFailure(outcome.message);
      }
      // queued / started — keep polling
    }

    throw const ServerFailure('Receipt scan timed out. Please try again.');
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  } catch (e) {
    rethrow;
  }
}

Future<String> _pantryImplRequestItems(
  PantryRemoteDatasourceImpl ds, {
  required PantryModel pantryModel,
}) async {
  devLog("${pantryModel.toJson()}");
  try {
    final response = await ds.dio.post(
      AppConstants.requestItems,
      data: pantryModel.toJson(),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'] ?? 'Unknown error';

      devPrint(" API Error");
      devPrint("Status Code: ${response.statusCode}");
      devPrint("Response Data: $data");

      throw apiExceptionFrom(message);
    }

    final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
    return readJsonString(ok, 'message');
  } on DioException catch (e) {
    devPrint(" DioException");
    devPrint("Message: ${e.message}");
    devPrint("Type: ${e.type}");
    devPrint("Path: ${e.requestOptions.path}");

    if (e.response != null) {
      devPrint("Status Code: ${e.response?.statusCode}");
      devPrint("Response Data: ${e.response?.data}");
    }

    throw await ds.dio.handleError(e);
  } catch (e) {
    devPrint(" Unexpected Error: $e");
    rethrow;
  }
}

Future<String> _pantryImplShowNotification(
  PantryRemoteDatasourceImpl ds, {
  required int id,
  required String title,
  required String body,
  String? payload,
}) async {
  try {
    await ds.notificationService.showNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
    );
    return "Notfication scheduled";
  } catch (e) {
    throw apiExceptionFrom(e);
  }
}

Future<String> _pantryImplCreatePantry(
  PantryRemoteDatasourceImpl ds, {
  required String kitchenId,
  required List<String> pantries,
}) async {
  try {
    final pantryList = pantries.map((name) => {"pantry_name": name}).toList();

    final requestData = {"kitchen_id": kitchenId, "pantries": pantryList};

    final response = await ds.dio.post(
      AppConstants.createPantry,
      data: requestData,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'];
      devPrint('[createPantry] Error Message: $message');
      throw apiExceptionFrom(message);
    }

    final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
    return readJsonString(ok, 'message');
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  } catch (e, stacktrace) {
    devPrint('Stacktrace: $stacktrace');
    rethrow;
  }
}

Future<String> _pantryImplDeletePantry(
  PantryRemoteDatasourceImpl ds, {
  required String kitchenId,
  required String pantryId,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.deletePantry,
      data: {"kitchen_id": kitchenId, "pantry_id": pantryId},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'];

      throw apiExceptionFrom(message);
    }

    final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
    return readJsonString(ok, 'message');
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  } catch (e, stacktrace) {
    devPrint('Stacktrace: $stacktrace');
    rethrow;
  }
}
