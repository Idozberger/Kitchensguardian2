class AppConstants {
  static const String baseUrl = 'https://kitchen-guardian-apis.replit.app';

  static const String login = '/api/login';
  static const String createAccount = '/api/register_user';
  static const String sendEmailVerification = '/api/send_verification_code';
  static const String verifyCode = '/api/verify_user';
  static const String forgot = '/api/forgot_password';
  static const String resetPassword = '/api/reset_password';

  ////logged in operations
  static const String createKitchen = "/api/kitchen/create";
  static const String joinKitchen = "/api/kitchen/join_with_code";
  static const String kitchens = "/api/kitchen/list_user_kitchens";
  static const String getMembers = "/api/kitchen/get_members";
  static const String makeCohost = "/api/kitchen/make_cohost";
  static const String kickMember = "/api/kitchen/kick_member";
  static const String leaveKitchen = "/api/kitchen/leave";
  static const String removeKitchen = "/api/kitchen/remove";

  static const String refreshKitchenInvitationCode =
      "/api/kitchen/refresh_invitation_code";
}
