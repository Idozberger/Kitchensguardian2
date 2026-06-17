// ignore_for_file: use_build_context_synchronously
// FCM init and routing use context after async setup.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/app_state.dart';
import 'package:foodkitchen/core/common/cubits/user_state.dart';
import 'package:foodkitchen/core/services/firebase_messenging/firebase_messenging_service.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';

import 'user_cubit.dart';

class AppCubit extends Cubit<AppState> {
  static const Duration _fcmInitDelay = Duration(seconds: 2);

  AppCubit() : super(const AppState.initial());

  Future<void> initializeApp(UserCubit userCubit, BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(_fcmInitDelay);

      try {
        final userState = userCubit.state;

        if (_canInitializeFCM(userState)) {
          await FirebaseMessagingService.instance().init(
            userId: userState.userId,
            firstName: userState.firstName,
            lastName: userState.lastName,
            email: userState.email,
            context: context,
          );

          emit(state.copyWith(fcmInitialized: true));
        } else {
          devPrint('Skipping FCM init — missing userId or email.');
        }
      } catch (e, st) {
        devPrint('Error initializing FCM: $e\n$st');
      }
    });
  }

  bool _canInitializeFCM(UserState userState) {
    return userState.userId.isNotEmpty && userState.email.isNotEmpty;
  }
}
