part of 'package:foodkitchen/features/auth/data/data_source/auth_remote_datasource.dart';

Future<String> _authImplSignInWithApple(AuthRemoteDatasourceImpl ds) async {
  try {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    devLog("apple sign in ${credential.email}");

    final String applePermanentId = credential.userIdentifier ?? "";
    final String email = credential.email ?? "";

    if (applePermanentId.isEmpty) {
      throw apiExceptionFrom('Sign in failed');
    }

    ds.userCubit.setGoogleSignUpUserModel(
      firstName: "",
      lastName: "",
      email: email,
    );

    final response = await ds.dio.post(
      AppConstants.login,
      data: {"email": email, "password": applePermanentId},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );
      final Object? err = data['error'] ?? data['message'] ?? 'Login failed';
      throw apiExceptionFrom(err);
    }

    final Map<String, dynamic> body = jsonObjectFromResponseData(response.data);
    final String token = readJsonString(body, 'access_token');
    final String message = readJsonString(
      body,
      'message',
      fallback: 'Welcome back!',
    );

    if (token.isEmpty) {
      throw apiExceptionFrom('Invalid response from server');
    }

    await ds.sharedPreferences.setString("access-token", token);

    return message;
  } on DioException catch (e) {
    if (e.response?.statusCode == 401 || e.response?.statusCode == 404) {
      throw apiExceptionFrom(
        'No account found with this Apple ID. Please sign up first.',
      );
    }
    final Map<String, dynamic> data = jsonObjectFromResponseData(
      e.response?.data,
    );
    final String errMessage = readJsonString(data, 'error').isNotEmpty
        ? readJsonString(data, 'error')
        : readJsonString(data, 'message', fallback: 'Login failed');
    throw apiExceptionFrom(errMessage);
  } catch (e) {
    devLog("apple sign in $e");
    throw apiExceptionFrom(e);
  }
}

Future<String> _authImplSignUpWithApple(AuthRemoteDatasourceImpl ds) async {
  try {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    if (credential.userIdentifier == null) {
      devLog("Apple Sign-Up cancelled or failed", name: "Auth");
      throw apiExceptionFrom('Sign up cancelled by user');
    }

    final String applePermanentId = credential.userIdentifier!;

    final String email = credential.email ?? "";
    final String displayName =
        "${credential.givenName ?? ""} ${credential.familyName ?? ""}".trim();

    final List<String> nameParts = displayName.split(RegExp(r'\s+'));
    final String firstName = nameParts.isNotEmpty ? nameParts.first : "User";
    final String lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(" ")
        : "";

    devLog("Apple Sign-Up → $firstName $lastName | $email", name: "Auth");

    final UserModel userModel = UserModel(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: applePermanentId,
    );
    devLog("Apple sign up, ${userModel.toJson()}");
    ds.userCubit.setGoogleSignUpUserModel(
      firstName: firstName,
      lastName: lastName,
      email: email,
    );

    devLog("Sending user data to server: ${userModel.toJson()}", name: "Auth");

    final response = await ds.dio.post(
      AppConstants.createAccount,
      data: userModel.toJson(),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );
      final Object? errorMsg =
          data['error'] ?? data['message'] ?? 'Sign up failed';
      devLog("Apple Sign-Up failed: $errorMsg", name: "Auth");
      throw apiExceptionFrom(errorMsg);
    }

    final Map<String, dynamic> body = jsonObjectFromResponseData(response.data);
    final String message = readJsonString(
      body,
      'message',
      fallback: 'Account created successfully!',
    );
    devLog("Apple Sign-Up successful: $message", name: "Auth");
    return message;
  } on DioException catch (e) {
    String errorMsg = "Sign up failed";
    if (e.response != null) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        e.response!.data,
      );
      errorMsg = readJsonString(data, 'error').isNotEmpty
          ? readJsonString(data, 'error')
          : readJsonString(data, 'message', fallback: 'Sign up failed');
    } else {
      errorMsg = "No internet connection";
    }
    devLog("Apple Sign-Up error: $errorMsg", name: "Auth", error: e);
    throw apiExceptionFrom(errorMsg);
  } on SignInWithAppleAuthorizationException catch (e) {
    devLog("Apple Sign-In authorization error", name: "Auth", error: e);
    if (e.code == AuthorizationErrorCode.canceled) {
      throw apiExceptionFrom('Sign up cancelled by user');
    }
    throw apiExceptionFrom('Sign up failed. Please try again.');
  } catch (e) {
    devLog("Unexpected error in Apple Sign-Up", name: "Auth", error: e);
    throw apiExceptionFrom(e);
  }
}

Future<void> _authImplSignOut(AuthRemoteDatasourceImpl ds) async {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  await googleSignIn.signOut();
  await ds.sharedPreferences.remove("access-token");
}
