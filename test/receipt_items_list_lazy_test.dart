import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/data/datasource/common_remote_datasource.dart';
import 'package:foodkitchen/core/common/data/datasource/unit_system_local_datasource.dart';
import 'package:foodkitchen/core/common/entitlement/user_entitlement_snapshot.dart';
import 'package:foodkitchen/features/kitchens/domain/repository/kitchen_repository.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/get_unit_system.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/set_unit_system.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/receipt_details/receipt_scanned_details_page.dart';

/// Guards KG-15 (high-volume receipt handling): the items list must stay a
/// lazily-built `ListView.builder`, not the old `SingleChildScrollView` +
/// `ListView.separated(shrinkWrap: true, physics: NeverScrollableScrollPhysics())`
/// pattern, which built every row up front regardless of scroll position.
class _UnimplementedCalls {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeCommonRemoteDatasource extends _UnimplementedCalls
    implements CommonRemoteDatasource {}

class _FakeUnitSystemLocalDataSource extends _UnimplementedCalls
    implements UnitSystemLocalDataSource {}

class _FakeKitchenRepository extends _UnimplementedCalls
    implements KitchenRepository {}

// UserCubit is a required field on ReceiptItemsListView but is never read
// on the code path this test exercises (items is empty, so the item row
// branch that would touch userCubit never builds) - these fakes only need
// to satisfy the constructor's types, never to actually do anything.
UserCubit _inertUserCubit() {
  final repository = _FakeKitchenRepository();
  return UserCubit(
    commonRemoteDatasource: _FakeCommonRemoteDatasource(),
    entitlementSnapshot: UserEntitlementSnapshot(),
    unitSystemLocalDataSource: _FakeUnitSystemLocalDataSource(),
    getUnitSystem: GetUnitSystem(repository),
    setUnitSystem: SetUnitSystem(repository),
  );
}

void main() {
  testWidgets('receipt items list stays a lazy ListView.builder', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReceiptItemsListView(
            imagePath: 'unused.jpg',
            items: const [],
            userCubit: _inertUserCubit(),
            onItemRemoved: (_) {},
            onFieldChanged: () {},
          ),
        ),
      ),
    );

    final listView = tester.widget<ListView>(find.byType(ListView));

    expect(listView.shrinkWrap, isFalse);
    expect(listView.physics, isNot(isA<NeverScrollableScrollPhysics>()));
    expect(
      (listView.childrenDelegate as SliverChildBuilderDelegate).childCount,
      1,
    );
    // The old implementation nested a shrinkWrap list inside this - if it
    // comes back, the list stops being independently scrollable/lazy again.
    expect(find.byType(SingleChildScrollView), findsNothing);
  });
}
