import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/network/profile_response_cache.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:foodkitchen/features/subscription/data/models/backend_subscription_plan.dart';

abstract interface class SubscriptionRemoteDatasource {
  Future<List<BackendSubscriptionPlan>> fetchPlans();

  /// Activates premium for the signed-in user (dummy / server-managed billing).
  Future<Map<String, dynamic>> subscribe({required String planId});

  /// Re-applies server-side entitlement (e.g. after reinstall).
  Future<Map<String, dynamic>> restoreSubscription();
}

class SubscriptionRemoteDatasourceImpl implements SubscriptionRemoteDatasource {
  SubscriptionRemoteDatasourceImpl({
    required DioHelper dio,
    required ProfileResponseCache profileCache,
  }) : _dio = dio,
       _profileCache = profileCache;

  final DioHelper _dio;
  final ProfileResponseCache _profileCache;

  @override
  Future<List<BackendSubscriptionPlan>> fetchPlans() async {
    try {
      final response = await _dio.get(AppConstants.subscriptionPlans);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw await _errorFromResponse(response);
      }
      final body = jsonObjectFromResponseData(response.data);
      final plansRaw = body['plans'];
      if (plansRaw is! List) {
        throw Exception('Invalid plans response');
      }
      final plans = plansRaw
          .map((e) => BackendSubscriptionPlan.fromJson(jsonObjectFromResponseData(e)))
          .where((p) => p.planId.isNotEmpty)
          .toList();
      if (plans.isEmpty) {
        throw Exception('No subscription plans returned');
      }
      return _sortPlans(plans);
    } on DioException catch (e) {
      throw await _dio.handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> subscribe({required String planId}) async {
    try {
      final response = await _dio.post(
        AppConstants.subscriptionSubscribe,
        data: {'plan_id': planId},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw await _errorFromResponse(response);
      }
      _profileCache.invalidate();
      return jsonObjectFromResponseData(response.data);
    } on DioException catch (e) {
      throw await _dio.handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> restoreSubscription() async {
    try {
      final response = await _dio.post(AppConstants.subscriptionRestore);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw await _errorFromResponse(response);
      }
      _profileCache.invalidate();
      return jsonObjectFromResponseData(response.data);
    } on DioException catch (e) {
      throw await _dio.handleError(e);
    }
  }

  List<BackendSubscriptionPlan> _sortPlans(List<BackendSubscriptionPlan> plans) {
    final copy = List<BackendSubscriptionPlan>.from(plans);
    copy.sort((a, b) {
      if (a.isMonthly != b.isMonthly) {
        return a.isMonthly ? -1 : 1;
      }
      if (a.isAnnual != b.isAnnual) {
        return a.isAnnual ? 1 : -1;
      }
      return a.priceAmount.compareTo(b.priceAmount);
    });
    return copy;
  }

  Future<Exception> _errorFromResponse(Response<dynamic> response) async {
    final body = jsonObjectFromResponseData(response.data);
    final message = body['error'] ?? body['message'] ?? 'Request failed';
    return apiExceptionFrom(message);
  }
}
