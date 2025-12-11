// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_nullable_for_final_variable_declarations

import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:foodkitchen/core/services/connection/connection_checker.dart';
import 'package:foodkitchen/features/auth/data/model/user_model.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AuthRemoteDataSource {
  Future<String> signUpUserWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });
  Future<String> sendUserEmailVerificationCode({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });
  Future<String> signInUserWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<String> sendPasswordResetEmail({required String email});
  Future<String> setUsersNewPassword({
    required String email,
    required String newPassword,
    required String verificationCode,
  });

  Future<String> verifyUserEmailWithVerificationCode({
    required String verficationCode,
    required String email,
  });
  Future<String> signInWithGoogle();
  Future<String> signUpWithGoogle();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDataSource {
  final DioHelper dio;
  final ConnectionChecker connectionChecker;
  final SharedPreferences sharedPreferences;
  AuthRemoteDatasourceImpl({
    required this.connectionChecker,
    required this.dio,
    required this.sharedPreferences,
  });
  @override
  Future<String> signUpUserWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      UserModel userModel = UserModel(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );

      final response = await dio.post(
        AppConstants.createAccount,
        data: userModel.toJson(),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> verifyUserEmailWithVerificationCode({
    required String verficationCode,
    required String email,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.verifyCode,
        data: {"verification_code": verficationCode, "email": email},
      );

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      final message = data["message"];

      return message ?? "Verification successful";
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> sendPasswordResetEmail({required String email}) async {
    try {
      final response = await dio.post(
        AppConstants.forgot,
        data: {"email": email},
      );

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      final message = data["message"];

      return message ?? "Password reset code sent successfully";
    } on DioException catch (e) {
      await dio.handleError(e);
      rethrow;
    }
  }

  @override
  Future<String> setUsersNewPassword({
    required String email,
    required String newPassword,
    required String verificationCode,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.resetPassword,
        data: {
          "email": email,
          "new_password": newPassword,
          "reset_code": verificationCode,
        },
      );
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      final message = data["message"];

      return message ?? "Password changed successfully";
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> signInUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.login,
        data: {"email": email, "password": password},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"] ?? data["message"] ?? "Login failed";
        throw message;
      }

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      final String? accessToken = data["access_token"];
      final String message = data["message"] ?? "Logged in successfully";

      if (accessToken == null || accessToken.isEmpty) {
        throw "Invalid response: Access token is missing";
      }

      await sharedPreferences.setString("access-token", accessToken);

      await Future.delayed(const Duration(milliseconds: 100));

      final savedToken = sharedPreferences.getString("access-token");
      if (savedToken == null || savedToken != accessToken) {
        debugPrint("Token save failed! Retrying...");
        await sharedPreferences.setString("access-token", accessToken);
      }

      debugPrint("Access token saved & verified successfully");

      return message;
    } on DioException catch (e) {
      throw dio.handleError(e);
    } catch (e) {
      debugPrint("Unexpected login error: $e");
      rethrow;
    }
  }

  @override
  Future<String> sendUserEmailVerificationCode({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      UserModel userModel = UserModel(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );

      final response = await dio.post(
        AppConstants.sendEmailVerification,
        data: userModel.toJson(),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      final message = data["message"];
      return message ?? "Verification Code Sent";
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId:
            "295968556562-3e8sicsicb6m6kh744bon398o8gaqu3k.apps.googleusercontent.com",
        scopes: ['email', 'profile'],
      );

      GoogleSignInAccount? googleUser = await googleSignIn.signInSilently();

      if (googleUser == null) {
        log("No cached session → showing Google picker", name: "Auth");
        googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          log("User cancelled Google Sign-In", name: "Auth");
          throw "Sign in cancelled";
        }
      }

      log("Google Sign-In successful: ${googleUser.email}", name: "Auth");

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken != null) {
        log("idToken received", name: "Auth");
      }

      final String googlePermanentId = googleUser.id;
      final String email = googleUser.email;

      log(
        "Attempting login → Email: $email | GoogleID: $googlePermanentId",
        name: "Auth",
      );

      final response = await dio.post(
        AppConstants.login,
        data: {"email": email, "password": googlePermanentId},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        final errorMsg = data["error"] ?? data["message"] ?? "Login failed";
        log("Login failed: $errorMsg", name: "Auth");
        throw errorMsg;
      }

      final String? token = response.data["access_token"];
      final String message = response.data["message"] ?? "Welcome back!";

      if (token == null || token.isEmpty) {
        log("Login succeeded but no access_token returned!", name: "Auth");
        throw "Invalid response from server";
      }

      await sharedPreferences.setString("access-token", token);
      await sharedPreferences.commit();

      log("GOOGLE LOGIN SUCCESS → Token saved", name: "Auth");
      return message;
    } on DioException catch (e) {
      String errorMsg = "Login failed";

      if (e.response?.statusCode == 401 || e.response?.statusCode == 404) {
        errorMsg =
            "No account found with this Google email. Please sign up first.";
      } else if (e.response != null) {
        final data = e.response?.data is String
            ? jsonDecode(e.response!.data)
            : e.response?.data;
        errorMsg = data?["error"] ?? data?["message"] ?? "Login failed";
      } else {
        errorMsg = "No internet connection";
      }

      log("Google Sign-In failed: $errorMsg", name: "Auth", error: e);
      throw errorMsg;
    } on PlatformException catch (e) {
      log("Platform error", name: "Auth", error: e);
      throw "Sign in failed. Please try again.";
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<String> signUpWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId:
            "428640146273-a3i750lldh1etatql54i10b2sqebcqus.apps.googleusercontent.com",
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        log("User cancelled Google Sign-Up", name: "Auth");
        throw "Sign up cancelled by user";
      }

      log("Google Sign-Up: User selected → ${googleUser.email}", name: "Auth");

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken != null) {
        log("idToken received for signup", name: "Auth");
      }

      final String googlePermanentId = googleUser.id;
      final String email = googleUser.email;
      final String displayName = googleUser.displayName ?? "User";

      final List<String> nameParts = displayName.trim().split(RegExp(r'\s+'));
      final String firstName = nameParts.first;
      final String lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(" ")
          : "";

      log("Creating account → $firstName $lastName | $email", name: "Auth");

      final UserModel userModel = UserModel(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: googlePermanentId,
      );

      final response = await dio.post(
        AppConstants.createAccount,
        data: userModel.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        final errorMsg = data["error"] ?? data["message"] ?? "Sign up failed";
        log("Google Sign-Up failed: $errorMsg", name: "Auth");
        throw errorMsg;
      }

      final String? token = response.data["access_token"];
      final String message =
          response.data["message"] ?? "Account created successfully!";

      if (token == null || token.isEmpty) {
        log("Sign up succeeded but no token returned!", name: "Auth");
        throw "Account created but login failed. Please try again.";
      }

      await sharedPreferences.setString("access-token", token);
      await sharedPreferences.commit();

      log("GOOGLE SIGN-UP SUCCESS → Account created & logged in", name: "Auth");
      return message;
    } on DioException catch (e) {
      String errorMsg = "Sign up failed";

      if (e.response != null) {
        final data = e.response!.data is String
            ? jsonDecode(e.response!.data)
            : e.response!.data;
        errorMsg = data?["error"] ?? data?["message"] ?? "Sign up failed";
      } else {
        errorMsg = "No internet connection";
      }

      log("Google Sign-Up error: $errorMsg", name: "Auth", error: e);
      throw errorMsg;
    } on PlatformException catch (e) {
      log("Platform error during Google Sign-Up", name: "Auth", error: e);
      throw "Sign up failed. Please try again.";
    } catch (e) {
      log("Unexpected error in Google Sign-Up", name: "Auth", error: e);
      throw e.toString();
    }
  }

  Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await sharedPreferences.remove("access-token");
  }
}
