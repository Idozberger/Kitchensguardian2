import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';

typedef KitchenSetupScanResponse = ({
  String sessionId,
  List<Map<String, dynamic>> items,
});

typedef KitchenSetupConfirmResponse = ({int addedCount, int updatedCount});

abstract class SmartKitchenSetupDatasource {
  Future<KitchenSetupScanResponse> getScanResult({
    required String kitchenId,
    required List<String> fridgeFilePaths,
    required List<String> freezerFilePaths,
    required List<String> pantryFilePaths,
    required List<String> spicesFilePaths,
    required List<String> miscFilePaths,
  });

  Future<void> editSetup({
    required String sessionId,
    required List<Map<String, dynamic>> items,
  });

  Future<KitchenSetupConfirmResponse> confirmSetup({required String sessionId});

  Future<String> skipKitchenSetup({required String kitchenId});
}

class SmartKitchenSetupDatasourceImpl implements SmartKitchenSetupDatasource {
  final DioHelper dio;

  SmartKitchenSetupDatasourceImpl({required this.dio});

  @override
  Future<KitchenSetupScanResponse> getScanResult({
    required String kitchenId,
    required List<String> fridgeFilePaths,
    required List<String> freezerFilePaths,
    required List<String> pantryFilePaths,
    required List<String> spicesFilePaths,
    required List<String> miscFilePaths,
  }) async {
    try {
      final Map<String, dynamic> fields = {'kitchen_id': kitchenId};
      if (fridgeFilePaths.isNotEmpty) {
        await _addImageField(fields, 'image_fridge', fridgeFilePaths.first);
      }
      if (freezerFilePaths.isNotEmpty) {
        await _addImageField(fields, 'image_freezer', freezerFilePaths.first);
      }
      if (pantryFilePaths.isNotEmpty) {
        await _addImageField(fields, 'image_pantry', pantryFilePaths.first);
      }
      if (spicesFilePaths.isNotEmpty) {
        await _addImageField(fields, 'image_spices', spicesFilePaths.first);
      }
      if (miscFilePaths.isNotEmpty) {
        await _addImageField(
          fields,
          'image_miscellaneous',
          miscFilePaths.first,
        );
      }

      final formData = FormData.fromMap(fields);
      devLog(
        "formData: ${formData.files.map((file) => '${file.key} + ${file.value}')}",
      );
      final response = await dio.post(
        AppConstants.kitchenSetupScan,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );
        throw apiExceptionFrom(data['error'] ?? 'Unknown error');
      }

      final Map<String, dynamic> decoded = jsonObjectFromResponseData(
        response.data,
      );

      final sessionId = readJsonString(decoded, 'session_id');
      if (sessionId.isEmpty) {
        throw apiExceptionFrom('Missing setup session id');
      }

      final Object? autoRaw = decoded['auto_confirmed'];
      final List<Map<String, dynamic>> autoConfirmed = autoRaw is List
          ? autoRaw
                .map(jsonObjectFromResponseData)
                .map((m) => m..['needs_review'] = false)
                .toList()
          : <Map<String, dynamic>>[];

      final Object? reviewRaw =
          decoded['needs_review'] ?? decoded['user_review'];
      final List<Map<String, dynamic>> userReview = reviewRaw is List
          ? reviewRaw
                .map(jsonObjectFromResponseData)
                .map((m) => m..['needs_review'] = true)
                .toList()
          : <Map<String, dynamic>>[];

      return (sessionId: sessionId, items: [...autoConfirmed, ...userReview]);
    } on DioException catch (e) {
      throw await dio.handleError(e);
    } catch (e, stacktrace) {
      devPrint('Stacktrace: $stacktrace');
      rethrow;
    }
  }

  @override
  Future<void> editSetup({
    required String sessionId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await dio.put(
        AppConstants.kitchenSetupEdit,
        data: {'session_id': sessionId, 'items': items},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );
        throw apiExceptionFrom(data['error'] ?? 'Unknown error');
      }
    } on DioException catch (e) {
      throw await dio.handleError(e);
    }
  }

  @override
  Future<KitchenSetupConfirmResponse> confirmSetup({
    required String sessionId,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.kitchenSetupConfirm,
        data: {'session_id': sessionId},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );
        throw apiExceptionFrom(data['error'] ?? 'Unknown error');
      }

      final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
      return (
        addedCount: readJsonInt(ok, 'added_count'),
        updatedCount: readJsonInt(ok, 'updated_count'),
      );
    } on DioException catch (e) {
      throw await dio.handleError(e);
    }
  }

  Future<void> _addImageField(
    Map<String, dynamic> fields,
    String key,
    String path,
  ) async {
    devLog("path: $path");
    if (path.isEmpty) return;
    final cleanPath = path.replaceFirst('file://', '');
    final compressed = await FlutterImageCompress.compressWithFile(
      cleanPath,
      minWidth: 1280,
      minHeight: 960,
      quality: 70,
      format: CompressFormat.jpeg,
    );
    fields[key] = compressed != null
        ? MultipartFile.fromBytes(
            compressed,
            filename: '${cleanPath.split('/').last}.jpg',
          )
        : await MultipartFile.fromFile(
            cleanPath,
            filename: cleanPath.split('/').last,
          );
  }

  @override
  Future<String> skipKitchenSetup({required String kitchenId}) async {
    try {
      final pantryList = const [
        "Fridge",
        "Freezer",
        "Pantry",
        "Spices",
      ].map((name) => {"pantry_name": name}).toList();

      final requestData = {"kitchen_id": kitchenId, "pantries": pantryList};

      final response = await dio.post(
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
      throw await dio.handleError(e);
    } catch (e, stacktrace) {
      devPrint('Stacktrace: $stacktrace');
      rethrow;
    }
  }
}
