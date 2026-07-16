import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/pantry/domain/repository/item_search_repository.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/add_item/item_name_search_field.dart';
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

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  );
}

void _setTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _typeAndSearch(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
}

void main() {
  group('ItemNameSearchField', () {
    testWidgets('debounces search and shows results', (tester) async {
      _setTallViewport(tester);
      final controller = TextEditingController();
      final repo = _FakeItemSearchRepository(
        handler: (query, {page = 1}) async => Right((
          items: [const ItemSearchResult(id: '1', name: 'Milk')],
          hasMore: false,
        )),
      );

      await tester.pumpWidget(
        _wrap(ItemNameSearchField(controller: controller, repository: repo)),
      );
      await tester.enterText(find.byType(TextField), 'mil');
      await tester.pump(const Duration(milliseconds: 299));
      expect(repo.calls, isEmpty);

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      expect(repo.calls, hasLength(1));
      expect(repo.calls.first.query, 'mil');
      expect(find.text('Milk'), findsOneWidget);
    });

    testWidgets('shows empty state when no results', (tester) async {
      _setTallViewport(tester);
      final controller = TextEditingController();
      final repo = _FakeItemSearchRepository(
        handler: (query, {page = 1}) async =>
            const Right((items: <ItemSearchResult>[], hasMore: false)),
      );

      await tester.pumpWidget(
        _wrap(ItemNameSearchField(controller: controller, repository: repo)),
      );
      await _typeAndSearch(tester, 'xyz');

      expect(find.text('No ingredients found'), findsOneWidget);
    });

    testWidgets('shows error state on search failure', (tester) async {
      _setTallViewport(tester);
      final controller = TextEditingController();
      final repo = _FakeItemSearchRepository(
        handler: (query, {page = 1}) async =>
            const Left(NetworkFailure('Network error')),
      );

      await tester.pumpWidget(
        _wrap(ItemNameSearchField(controller: controller, repository: repo)),
      );
      await _typeAndSearch(tester, 'mil');

      expect(find.text('Network error'), findsOneWidget);
    });

    testWidgets('shows selectable suggestion row', (tester) async {
      _setTallViewport(tester);
      final controller = TextEditingController();
      final repo = _FakeItemSearchRepository(
        handler: (query, {page = 1}) async => Right((
          items: [const ItemSearchResult(id: 'ing-42', name: 'Milk')],
          hasMore: false,
        )),
      );

      await tester.pumpWidget(
        _wrap(ItemNameSearchField(controller: controller, repository: repo)),
      );
      await _typeAndSearch(tester, 'mil');

      expect(find.byKey(const ValueKey('item_search_ing-42')), findsOneWidget);
      expect(find.text('Milk'), findsOneWidget);
    });

    test('applyItemSearchSelection updates controller and catalog id', () {
      final controller = TextEditingController();
      String? catalogId;

      applyItemSearchSelection(
        controller: controller,
        item: const ItemSearchResult(id: 'ing-42', name: 'Milk'),
        onCatalogIdChanged: (id) => catalogId = id,
      );

      expect(controller.text, 'Milk');
      expect(catalogId, 'ing-42');
    });

    testWidgets('clears catalog link when user edits text', (tester) async {
      _setTallViewport(tester);
      final controller = TextEditingController();
      String? catalogId = 'ing-42';
      final repo = _FakeItemSearchRepository(
        handler: (query, {page = 1}) async =>
            const Right((items: <ItemSearchResult>[], hasMore: false)),
      );

      await tester.pumpWidget(
        _wrap(
          ItemNameSearchField(
            controller: controller,
            repository: repo,
            onCatalogIdChanged: (id) => catalogId = id,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'mil');
      expect(catalogId, isNull);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
    });

    testWidgets('does not search when query shorter than 3 chars', (
      tester,
    ) async {
      _setTallViewport(tester);
      final controller = TextEditingController();
      final repo = _FakeItemSearchRepository(
        handler: (query, {page = 1}) async =>
            const Right((items: <ItemSearchResult>[], hasMore: false)),
      );

      await tester.pumpWidget(
        _wrap(ItemNameSearchField(controller: controller, repository: repo)),
      );
      await _typeAndSearch(tester, 'mi');

      expect(repo.calls, isEmpty);
      expect(find.text('No ingredients found'), findsNothing);
    });

    testWidgets('requests page 2 when scrolling near list end', (tester) async {
      _setTallViewport(tester);
      final controller = TextEditingController();
      var page2Requested = false;
      final repo = _FakeItemSearchRepository(
        handler: (query, {page = 1}) async {
          if (page == 1) {
            return Right((
              items: List.generate(
                12,
                (i) => ItemSearchResult(id: '$i', name: 'Item $i'),
              ),
              hasMore: true,
            ));
          }
          page2Requested = true;
          return Right((
            items: [const ItemSearchResult(id: '12', name: 'Item 12')],
            hasMore: false,
          ));
        },
      );

      await tester.pumpWidget(
        _wrap(ItemNameSearchField(controller: controller, repository: repo)),
      );
      await _typeAndSearch(tester, 'item');

      expect(find.text('Item 0'), findsOneWidget);

      final listView = tester.widget<ListView>(find.byType(ListView));
      listView.controller?.jumpTo(
        listView.controller!.position.maxScrollExtent,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(page2Requested, isTrue);
      expect(repo.calls.where((c) => c.page == 2), isNotEmpty);
    });
  });
}
