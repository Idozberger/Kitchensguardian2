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

        final message = data["error"];
        throw message;
      }

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      final accessToken = data["access_token"];
      final message = data["message"];

      if (accessToken != null) {
        await sharedPreferences.setString("access-token", accessToken);
        debugPrint("Access token saved ✅");
      }

      return message ?? "Logged In Successfully";
    } on DioException catch (e) {
      throw dio.handleError(e);
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
    log("Google Sign-In: Starting Google Sign-In process...", name: "Auth");

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId:
            "428640146273-a3i750lldh1etatql54i10b2sqebcqus.apps.googleusercontent.com",
        scopes: ['email', 'profile'],
      );

      log("GoogleSignIn instance created with serverClientId", name: "Auth");

      log("Google Sign-In: Showing Google account picker...", name: "Auth");
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        log("Google Sign-In: Cancelled by user", name: "Auth");
        return "Google Sign-In was cancelled";
      }

      log(
        "Google Sign-In: User selected account → ${googleUser.email}",
        name: "Auth",
      );

      log("Google Sign-In: Requesting authentication tokens...", name: "Auth");
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        log(
          "Google Sign-In: Failed to retrieve idToken (null)",
          name: "Auth",
          error: "Check serverClientId in Google Cloud Console",
        );
        return "Failed to get ID token. Check serverClientId configuration.";
      }

      log(
        "Google Sign-In: idToken received (length: ${idToken.length})",
        name: "Auth",
      );
      if (accessToken != null) {
        log("Google Sign-In: accessToken also received", name: "Auth");
      }

      final String email = googleUser.email;
      final String? displayName = googleUser.displayName;
      final String googleId = googleUser.id;

      final String firstName = displayName?.split(" ").first ?? "User";
      final String lastName = displayName != null && displayName.contains(" ")
          ? displayName.split(" ").sublist(1).join(" ")
          : "";

      log(
        "Google User Info → Email: $email | Name: $firstName $lastName | GoogleID: $googleId",
        name: "Auth",
      );

      // Try Login First
      log("Auth: Attempting login with email: $email", name: "Auth");
      try {
        final response = await dio.post(
          AppConstants.login,
          data: {"email": email, "password": googleId},
        );

        final token = response.data["access_token"];
        final message = response.data["message"] ?? "Login successful";

        if (token != null) {
          await sharedPreferences.setString("access-token", token);
          log("Login SUCCESS → Token saved | Message: $message", name: "Auth");
        } else {
          log("Login succeeded but no token returned", name: "Auth");
        }

        return message;
      } catch (loginError) {
        log(
          "Login FAILED → Trying to create new account...",
          name: "Auth",
          error: loginError,
        );

        // Create New Account
        log("Auth: Creating new account for $email", name: "Auth");
        final signupResponse = await dio.post(
          AppConstants.createAccount,
          data: {
            "first_name": firstName,
            "last_name": lastName,
            "email": email,
            "password": googleId,
            "login_type": "google",
          },
        );

        final token = signupResponse.data["access_token"];
        final message =
            signupResponse.data["message"] ?? "Account created successfully";

        if (token != null) {
          await sharedPreferences.setString("access-token", token);
          log(
            "Signup SUCCESS → New account created & token saved",
            name: "Auth",
          );
        }

        log("Signup completed → $message", name: "Auth");
        return message;
      }
    } on PlatformException catch (e) {
      log("Google Sign-In: Platform Exception", name: "Auth", error: e);
      return "Sign-in failed: Network or platform issue";
    }
  }

  Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await sharedPreferences.remove("access-token");
  }
}
