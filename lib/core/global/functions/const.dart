class AppConstants {
  static const bool entitlementIsActive = false;
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
  static const String leaveKitchen = "/api/kitchen/leave";
  static const String getMembers = "/api/kitchen/get_members";
  static const String makeCohost = "/api/kitchen/make_cohost";
  static const String kickMember = "/api/kitchen/kick_member";

  static const String removeKitchen = "/api/kitchen/remove";

  static const String refreshKitchenInvitationCode =
      "/api/kitchen/refresh_invitation_code";
  static const String addPantryItem = "/api/kitchen/add_items";
  static const String getPantryItems = "/api/kitchen/list_items";
  static const String scanRecipt = "/api/scan_recipt";
  static const String getRequestedItems =
      "/api/kitchen/get_user_requested_items";

  static const String generateRecipes = "/api/generate_recipes";
  static const String favouriteRecipes = "/api/recipe/list_fav";
  static const String removeFromFavourite = "/api/recipe/remove_from_fav";
  static const String addToFavourite = "/api/recipe/add_to_fav";
  static const String requestItems = "/api/kitchen/request_item";
  static const String updateBucketType = "/api/kitchen/update_bucket_type";
  static const String addMyListItemToKitchenInventory =
      "/api/kitchen/add_mylist_items_to_kitchen_inventory";
  static const String getAiGeneratedList = "/api/kitchen/get_ai_generated_list";
  static const String deleteKitchenItems = "/api/kitchen/delete_items";
  static const String addItemToList = "/api/kitchen/add_item_to_list";
  static const String getScanHistory = "/api/get_scan_history";

  static const String markRecipeFinished = "/api/kitchen/mark_recipe_finished";
  static const String updateKitchenItems = "/api/kitchen/update_items";
  static const String removeItems = "/api/kitchen/remove_items";
  static const String inviteUser = "/api/kitchen/invite";
  static const String createPantry = "/api/kitchen/pantry/create";
  static const String getPantries = "/api/kitchen/pantry/list";
  static const String deletePantry = "/api/kitchen/pantry/delete";
}
