abstract class RecipeStartRequestFirestoreDatasource {
  Future<Map<String, dynamic>?> fetchKitchenByKitchenId(String kitchenId);

  Future<Map<String, dynamic>?> fetchUserDocument(String userId);

  Future<void> addRecipeStartRequest(Map<String, dynamic> data);

  Future<void> completePendingRequestForHost({
    required String hostUserId,
    required String recipeId,
  });

  Stream<List<Map<String, dynamic>>> watchRecipeStartRequestsForKitchen(
    String kitchenId,
  );
}
