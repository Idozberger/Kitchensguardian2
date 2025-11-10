abstract class ProfileRemoteDatasource {
  Future<String> editProfile({
    required String firstName,
    required String lastName,
  });
}
