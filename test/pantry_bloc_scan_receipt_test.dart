import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt.dart';
import 'package:foodkitchen/features/pantry/domain/repository/pantry_repository.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/add_pantry_item.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/cart_items.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/create_pantry_usecase.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/delete_item.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/delete_pantry.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/get_pantry_items.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/request_items.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/scan_receipt.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/show_notification.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/update_item.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:fpdart/fpdart.dart';

// `PantryBloc` is constructed with 4 sibling blocs/cubits and 9 use cases,
// none of which `_onScanReceipt` ever touches - fake every one of them with
// the same `implements X { noSuchMethod }` pattern already used elsewhere
// in this repo (see item_search_repository_impl_test.dart), so this test
// exercises the *real* PantryBloc without needing bloc_test or a new
// dev dependency.
class _FakeHomeBloc implements HomeBloc {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGroceryBloc implements GroceryBloc {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlannerBloc implements PlannerBloc {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserCubit implements UserCubit {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddPantryItem implements AddPantryItem {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetPantryItems implements GetPantryItems {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRequestItems implements RequestItems {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeShowNotification implements ShowNotification {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCreatePantryUsecase implements CreatePantryUsecase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDeletePantry implements DeletePantry {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCartItems implements CartItems {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDeleteItem implements DeleteItem {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUpdateItem implements UpdateItem {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePantryRepository implements PantryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Overrides `call` directly instead of going through [PantryRepository],
/// so the test controls the scan outcome without a fake network layer.
class _FakeScanReceiptUseCase extends ScanReceiptUseCase {
  _FakeScanReceiptUseCase(this.handler) : super(_FakePantryRepository());

  final Future<Either<Failure, ScanReceiptEntity>> Function(
    ScanReceiptUseCaseParams params,
  )
  handler;

  @override
  Future<Either<Failure, ScanReceiptEntity>> call(
    ScanReceiptUseCaseParams params,
  ) => handler(params);
}

PantryBloc _buildBloc(ScanReceiptUseCase scanReceiptUseCase) {
  return PantryBloc(
    homeBloc: _FakeHomeBloc(),
    userCubit: _FakeUserCubit(),
    groceryBloc: _FakeGroceryBloc(),
    plannerBloc: _FakePlannerBloc(),
    addPantryItem: _FakeAddPantryItem(),
    getPantryItems: _FakeGetPantryItems(),
    scanReceipt: scanReceiptUseCase,
    requestItems: _FakeRequestItems(),
    showNotification: _FakeShowNotification(),
    createPantryUsecase: _FakeCreatePantryUsecase(),
    cartItems: _FakeCartItems(),
    deletePantry: _FakeDeletePantry(),
    deleteItem: _FakeDeleteItem(),
    updateItem: _FakeUpdateItem(),
  );
}

ScanReceiptEvent _event() => ScanReceiptEvent(
  filePath: '/tmp/receipt.jpg',
  country: 'USA',
  currency: 'USD',
  kitchenId: 'kitchen-1',
);

void main() {
  group('PantryBloc._onScanReceipt', () {
    test('emits loading then ScanReceiptLoaded on success', () async {
      final bloc = _buildBloc(
        _FakeScanReceiptUseCase(
          (params) async =>
              Right(ScanReceiptEntity(successMessage: 'ok', items: const [])),
        ),
      );
      addTearDown(bloc.close);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([isA<PantryScanItemsLoading>(), isA<ScanReceiptLoaded>()]),
      );
      bloc.add(_event());
      await expectation;
    });

    test(
      'emits loading then PantryFailure with the sanitized message on failure',
      () async {
        final bloc = _buildBloc(
          _FakeScanReceiptUseCase(
            (params) async =>
                const Left(ServerFailure('Receipt scan timed out.')),
          ),
        );
        addTearDown(bloc.close);

        late PantryFailure failure;
        final expectation = expectLater(
          bloc.stream,
          emitsInOrder([
            isA<PantryScanItemsLoading>(),
            predicate<PantryState>((s) {
              failure = s as PantryFailure;
              return true;
            }, 'PantryFailure'),
          ]),
        );
        bloc.add(_event());
        await expectation;

        expect(failure.errorMessage, 'Receipt scan timed out.');
      },
    );

    test(
      'ignores a second ScanReceiptEvent while a scan is already in progress',
      () async {
        var callCount = 0;
        final bloc = _buildBloc(
          _FakeScanReceiptUseCase((params) async {
            callCount++;
            // Never resolves during the test - keeps the bloc in
            // PantryScanItemsLoading so the dedup guard is exercised.
            return Completer<Either<Failure, ScanReceiptEntity>>().future;
          }),
        );
        addTearDown(bloc.close);

        bloc.add(_event());
        await expectLater(bloc.stream, emits(isA<PantryScanItemsLoading>()));

        bloc.add(_event());
        // No further state should be emitted for the ignored duplicate -
        // give the event handler a turn to (not) run.
        await Future<void>.delayed(Duration.zero);

        expect(callCount, 1);
        expect(bloc.state, isA<PantryScanItemsLoading>());
      },
    );
  });
}
