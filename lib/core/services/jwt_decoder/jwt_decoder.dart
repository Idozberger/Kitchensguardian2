import 'package:foodkitchen/core/global/functions/logs.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class DartJwtDecoder {
  Future<Map<String, dynamic>> decodeTokenAndReturnUser({
    required String userToken,
  }) async {
    try {
      final decodedToken = JwtDecoder.decode(userToken);
      logSuccess(decodedToken);

      final sub = decodedToken['sub'] ?? {};

      final hasExpired = JwtDecoder.isExpired(userToken);
      final expirationDate = JwtDecoder.getExpirationDate(userToken);
      final formattedDate = DateFormat('dd/MM/yyyy').format(expirationDate);

      final Map<String, dynamic> userMap = {
        "first_name": sub["first_name"],
        "last_name": sub["last_name"],
        "email": sub["email"],
        "has_expired": hasExpired,
        "expiration_date": formattedDate,
      };

      return userMap;
    } catch (e) {
      logError("JWT Decode Error: $e");
      return {};
    }
  }
}
