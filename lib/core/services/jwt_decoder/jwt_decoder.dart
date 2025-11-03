import 'package:foodkitchen/core/global/functions/logs.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class DartJwtDecoder {
  Future<Map<String, dynamic>> decodeTokenAndReturnUser({
    required String userToken,
  }) async {
    try {
      final decodedToken = JwtDecoder.decode(userToken);

      final hasExpired = JwtDecoder.isExpired(userToken);
      final expirationDate = JwtDecoder.getExpirationDate(userToken);
      final formattedDate = DateFormat('dd/MM/yyyy').format(expirationDate);

      final Map<String, dynamic> userMap = {
        "first_name": decodedToken["first_name"],
        "user_id": decodedToken["user_id"],
        "last_name": decodedToken["last_name"],
        "email": decodedToken["email"],
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
