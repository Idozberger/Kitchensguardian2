class AppConstants {
  static const String baseUrl = 'https://kitchen-guardian-apis.replit.app';

  // const dataToSend = {email: email, password: pwd};
  static const String login = '/api/login';

  ///[SIGNUP]
  /// const dataToSend = {
  //   first_name: fname,
  //   last_name: lname,
  //   email: email,
  //   password: pwd,
  // };
  static const String createAccount = '/api/register_user';
  static const String emailVerification = '/api/send_verification_code';

  // const dataToSend = {
  //   email: email,
  //   verification_code: verifyCode,
  // };
  static const String verifyUsersEmail = "/api/verify_user";
  // const dataToSend = {
  //   email: email,
  //   reset_code: verifyCode,
  //   new_password: newPwd,
  // };
  static const String resetPassword = '/api/reset_password';
  static const String setNewPassword = '/newPassword';
  static const String verifyCode = '/verifyCode';
  // const dataToSend = {email: email};
  static const String forgot = '/api/forgot_password';
}
