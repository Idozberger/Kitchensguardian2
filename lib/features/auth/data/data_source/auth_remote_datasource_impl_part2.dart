part of 'package:foodkitchen/features/auth/data/data_source/auth_remote_datasource.dart';

Future<String> _authImplSignInWithGoogle(AuthRemoteDatasourceImpl ds) async {
  try {
    GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: Env.googleSignInServerClientId,
      scopes: ['email', 'profile'],
    );

    await googleSignIn.signOut();
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      devLog("No cached session → showing Google picker", name: "Auth");

      if (googleUser == null) {
        devLog("User cancelled Google Sign-In", name: "Auth");
        throw apiExceptionFrom('Sign in cancelled');
      }
    }

    devLog("Google Sign-In successful: ${googleUser.email}", name: "Auth");

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    if (googleAuth.idToken != null) {
      devLog("idToken received", name: "Auth");
    }

    final String googlePermanentId = googleUser.id;
    final String email = googleUser.email;

    devLog(
      "Attempting login → Email: $email | GoogleID: $googlePermanentId",
      name: "Auth",
    );
    ds.userCubit.setGoogleSignUpUserModel(
      firstName: "",
      lastName: "",
      email: email,
    );
    final response = await ds.dio.post(
      AppConstants.login,
      data: {"email": email, "password": googlePermanentId},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );
      final Object? errorMsg =
          data['error'] ?? data['message'] ?? 'Login failed';
      devLog("Login failed: $errorMsg", name: "Auth");

      throw apiExceptionFrom(errorMsg);
    }

    final Map<String, dynamic> body = jsonObjectFromResponseData(response.data);
    final String token = readJsonString(body, 'access_token');
    final String message = readJsonString(
      body,
      'message',
      fallback: 'Welcome back!',
    );

    if (token.isEmpty) {
      devLog("Login succeeded but no access_token returned!", name: "Auth");
      throw apiExceptionFrom('Invalid response from server');
    }

    await ds.sharedPreferences.setString("access-token", token);

    devLog("GOOGLE LOGIN SUCCESS → Token saved", name: "Auth");
    return message;
  } on DioException catch (e) {
    String errorMsg = "Login failed";

    if (e.response?.statusCode == 401 || e.response?.statusCode == 404) {
      errorMsg =
          "No account found with this Google email. Please sign up first.";
    } else if (e.response != null) {
      final Map<String, dynamic> errBody = jsonObjectFromResponseData(
        e.response?.data,
      );
      errorMsg = readJsonString(errBody, 'error').isNotEmpty
          ? readJsonString(errBody, 'error')
          : readJsonString(errBody, 'message', fallback: 'Login failed');
    } else {
      errorMsg = "No internet connection";
    }

    devLog("Google Sign-In failed: $errorMsg", name: "Auth", error: e);
    throw apiExceptionFrom(errorMsg);
  } on PlatformException catch (e) {
    devLog("Platform error", name: "Auth", error: e);
    throw apiExceptionFrom('Sign in failed. Please try again.');
  } catch (e) {
    throw apiExceptionFrom(e);
  }
}

Future<String> _authImplSignUpWithGoogle(AuthRemoteDatasourceImpl ds) async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: Env.googleSignInServerClientId,
      scopes: ['email', 'profile'],
    );
    await googleSignIn.signOut();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      devLog("User cancelled Google Sign-Up", name: "Auth");
      throw apiExceptionFrom('Sign up cancelled by user');
    }

    devLog("Google Sign-Up: User selected → ${googleUser.email}", name: "Auth");

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    if (googleAuth.idToken != null) {
      devLog("idToken received for signup", name: "Auth");
    }

    final String googlePermanentId = googleUser.id;
    final String email = googleUser.email;
    final String displayName = googleUser.displayName ?? "User";

    final List<String> nameParts = displayName.trim().split(RegExp(r'\s+'));
    final String firstName = nameParts.first;
    final String lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(" ")
        : "";

    devLog("Creating account → $firstName $lastName | $email", name: "Auth");

    final UserModel userModel = UserModel(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: googlePermanentId,
    );
    ds.userCubit.setGoogleSignUpUserModel(
      firstName: firstName,
      lastName: "sdfadsf",
      email: email,
    );
    devLog("missing fields: ${userModel.toJson()}");
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
      devLog("Google Sign-Up failed: $errorMsg", name: "Auth");
      throw apiExceptionFrom(errorMsg);
    }

    final Map<String, dynamic> body = jsonObjectFromResponseData(response.data);
    final String message = readJsonString(
      body,
      'message',
      fallback: 'Account created successfully!',
    );

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

    devLog("Google Sign-Up error: $errorMsg", name: "Auth", error: e);
    throw apiExceptionFrom(errorMsg);
  } on PlatformException catch (e) {
    devLog("Platform error during Google Sign-Up", name: "Auth", error: e);
    throw apiExceptionFrom('Sign up failed. Please try again.');
  } catch (e) {
    devLog("Unexpected error in Google Sign-Up", name: "Auth", error: e);
    throw apiExceptionFrom(e);
  }
}
