import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';

abstract interface class CurrentUserRemoteDatasource {
  Future<String> getCurrentUser();
}

class CurrentUserRemoteDataSourceImpl implements CurrentUserRemoteDatasource {
  final DioHelper dio;
  CurrentUserRemoteDataSourceImpl(this.dio);
  @override
  Future<String> getCurrentUser() async {
    dio.get(AppConstants.createAccount);
    return "";
  }
}
