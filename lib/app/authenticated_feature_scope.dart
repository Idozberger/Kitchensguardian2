import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/app/di.dart';
import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_bloc.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/history/presentation/bloc/scan_history_cubit.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/bloc/smart_kitchen_setup_bloc.dart';

/// Provides feature-level blocs for the whole app subtree (including modal routes).
///
/// Wrapped from [AppBase] so overlays such as [showDialog] inherit the same
/// [BlocProvider]s as shell routes. Blocs remain **singletons** from GetIt; this
/// widget only **scopes** them in the element tree. App-wide session state stays
/// in [main.dart] (`UserBloc`, `UserCubit`, `AuthBloc`, `AppCubit`).
class AuthenticatedFeatureScope extends StatelessWidget {
  const AuthenticatedFeatureScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>.value(value: sl<HomeBloc>()),
        BlocProvider<KitchenBloc>.value(value: sl<KitchenBloc>()),
        BlocProvider<DashboardBloc>.value(value: sl<DashboardBloc>()),
        BlocProvider<PantryBloc>.value(value: sl<PantryBloc>()),
        BlocProvider<GroceryBloc>.value(value: sl<GroceryBloc>()),
        BlocProvider<PlannerBloc>.value(value: sl<PlannerBloc>()),
        BlocProvider<ScanHistoryCubit>.value(value: sl<ScanHistoryCubit>()),
        BlocProvider<ProfileBloc>.value(value: sl<ProfileBloc>()),
        BlocProvider<ConsumptionBloc>.value(value: sl<ConsumptionBloc>()),
        BlocProvider<SmartKitchenSetupBloc>.value(
          value: sl<SmartKitchenSetupBloc>(),
        ),
      ],
      child: child,
    );
  }
}
