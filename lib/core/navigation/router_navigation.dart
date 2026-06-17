import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:foodkitchen/app/app_router.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:go_router/go_router.dart';

/// Pops the current route when the stack allows it; otherwise [go]es to
/// [fallbackLocation]. Uses [GoRouter.maybeOf] so missing router ancestry
/// does not throw (e.g. error overlays or root-only routes).
void popOrGo(
  BuildContext context, {
  String fallbackLocation = Routes.splash,
}) {
  final router = _resolveRouter(context);
  if (router != null) {
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(fallbackLocation);
    }
    return;
  }

  final navigator = Navigator.maybeOf(context);
  if (navigator != null && navigator.canPop()) {
    navigator.pop();
  }
}

GoRouter? _resolveRouter(BuildContext context) {
  final direct = GoRouter.maybeOf(context);
  if (direct != null) return direct;

  final rootContext = rootNavigatorKey.currentContext;
  if (rootContext != null) {
    return GoRouter.maybeOf(rootContext);
  }

  return null;
}

/// Resolves a valid navigation [BuildContext] after the current frame, for use
/// when [pageContext] may be disposed before the callback runs.
void goNamedAfterFrame({
  required String name,
  Object? extra,
  required bool Function() isPageMounted,
  required BuildContext Function() pageContext,
}) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    final navContext = isPageMounted()
        ? pageContext()
        : rootNavigatorKey.currentContext;
    if (navContext == null || !navContext.mounted) return;

    navContext.goNamed(name, extra: extra);
  });
}
