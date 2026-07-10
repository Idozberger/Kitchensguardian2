import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/cubits/user_state.dart';

/// Runs [onChanged] whenever the active kitchen's measurement system changes
/// (BRD UC-04: "existing application data is automatically converted").
///
/// Quantities are converted by the backend on read, so reflecting a new system
/// is just a re-fetch. Dashboard tabs live in an `IndexedStack` and therefore
/// keep their state across tab switches — without this they never re-run
/// `initState` and would keep rendering the previous system's units. Pages that
/// are pushed as routes (pantry, recipe details) re-fetch on their own.
class UnitSystemChangeListener extends StatelessWidget {
  /// Re-fetch the unit-bearing data this page renders.
  final VoidCallback onChanged;
  final Widget child;

  const UnitSystemChangeListener({
    super.key,
    required this.onChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listenWhen: (previous, current) =>
          previous.unitSystem != current.unitSystem,
      listener: (_, _) => onChanged(),
      child: child,
    );
  }
}
