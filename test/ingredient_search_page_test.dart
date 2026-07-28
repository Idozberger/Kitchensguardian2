import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/pantry/domain/repository/item_search_repository.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/ingredient_search/ingredient_search_page.dart';
import 'package:fpdart/fpdart.dart';

class _FakeItemSearchRepository implements ItemSearchRepository {
  _FakeItemSearchRepository({required this.handler});

  final Future<Either<Failure, ({List<ItemSearchResult> items, bool hasMore})>>
  Function(String query, {int page})
  handler;

  final List<({String query, int page})> calls = [];

  @override
  Future<Either<Failure, ({List<ItemSearchResult> items, bool hasMore})>>
  searchItems(String query, {int page = 1}) {
    calls.add((query: query, page: page));
    return handler(query, page: page);
  }
}

Future<void> _pumpPage(WidgetTester tester, ItemSearchRepository repo) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(home: IngredientSearchPage(repository: repo)),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('IngredientSearchPage', () {
    testWidgets('browses the catalog with an empty query on open', (
      tester,
    ) async {
      final repo = _FakeItemSearchRepository(
        handler: (query, {page = 1}) async => Right((
          items: const [
            ItemSearchResult(id: '1', name: 'acacia honey'),
            ItemSearchResult(id: '2', name: 'Acai Powder'),
          ],
          hasMore: false,
        )),
      );

      await _pumpPage(tester, repo);

      expect(repo.calls, hasLength(1));
      expect(repo.calls.first.query, '');
      expect(find.text('acacia honey'), findsOneWidget);
      expect(find.byKey(const ValueKey('ingredient_search_2')), findsOneWidget);
    });

    testWidgets('debounces typed queries', (tester) async {
      final repo = _FakeItemSearchRepository(
        handler: (query, {page = 1}) async => Right((
          items: [ItemSearchResult(id: '1', name: 'Milk ($query)')],
          hasMore: false,
        )),
      );

      await _pumpPage(tester, repo);
      await tester.enterText(find.byType(TextFormField), 'mil');
      await tester.pump(const Duration(milliseconds: 299));
      expect(repo.calls, hasLength(1));

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();

      expect(repo.calls.last.query, 'mil');
      expect(find.text('Milk (mil)'), findsOneWidget);
    });

    testWidgets('shows the empty state when a query has no results', (
      tester,
    ) async {
      final repo = _FakeItemSearchRepository(
        handler: (query, {page = 1}) async =>
            const Right((items: <ItemSearchResult>[], hasMore: false)),
      );

      await _pumpPage(tester, repo);
      await tester.enterText(find.byType(TextFormField), 'xyz');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('No ingredients found'), findsOneWidget);
    });

    testWidgets('surfaces a failed query but not a failed empty browse', (
      tester,
    ) async {
      final repo = _FakeItemSearchRepository(
        handler: (query, {page = 1}) async =>
            const Left(NetworkFailure('Network error')),
      );

      await _pumpPage(tester, repo);
      expect(find.text('Network error'), findsNothing);

      await tester.enterText(find.byType(TextFormField), 'mil');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Network error'), findsOneWidget);
    });

    testWidgets('requests page 2 when scrolling near the list end', (
      tester,
    ) async {
      final repo = _FakeItemSearchRepository(
        handler: (query, {page = 1}) async {
          if (page == 1) {
            return Right((
              items: List.generate(
                60,
                (i) => ItemSearchResult(id: '$i', name: 'Item $i'),
              ),
              hasMore: true,
            ));
          }
          return Right((
            items: [const ItemSearchResult(id: '60', name: 'Item 60')],
            hasMore: false,
          ));
        },
      );

      await _pumpPage(tester, repo);
      expect(find.text('Item 0'), findsOneWidget);

      final listView = tester.widget<ListView>(find.byType(ListView));
      listView.controller?.jumpTo(
        listView.controller!.position.maxScrollExtent,
      );
      await tester.pumpAndSettle();

      expect(repo.calls.where((c) => c.page == 2), isNotEmpty);
    });
  });
}
