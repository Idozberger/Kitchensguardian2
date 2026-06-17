import 'package:get_it/get_it.dart';

/// Global [GetIt] accessor. All registrations happen in [initDependencies]
/// (`lib/app/di.dart`). Import this file (or `app/di.dart`, which re-exports [sl])
/// instead of calling [SharedPreferences.getInstance] ad hoc.
final sl = GetIt.instance;
