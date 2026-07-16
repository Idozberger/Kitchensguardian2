import 'package:flutter_test/flutter_test.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/pantry/data/datasource/pantry_remote_datasource.dart';
import 'package:foodkitchen/features/pantry/data/repository/item_search_repository_impl.dart';
import 'package:foodkitchen/features/pantry/domain/repository/item_search_repository.dart';
import 'package:fpdart/fpdart.dart';

class _FakePantryRemoteDatasource implements PantryRemoteDatasource {
  _FakePantryRemoteDatasource({required this.searchHandler});

  final Future<({List<Map<String, dynamic>> results, bool hasMore})> Function({
    required String query,
    required int page,
  })
  searchHandler;

  @override
  Future<({List<Map<String, dynamic>> results, bool hasMore})>
  searchSharedIngredients({required String query, required int page}) =>
      searchHandler(query: query, page: page);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ItemSearchRepositoryImpl', () {
    test('maps id and display_name from JSON', () async {
      final repo = ItemSearchRepositoryImpl(
        _FakePantryRemoteDatasource(
          searchHandler: ({required query, required page}) async => (
            results: [
              {'id': 'ing-1', 'display_name': 'Milk'},
              {'id': 'ing-2', 'display_name': 'Eggs'},
            ],
            hasMore: false,
          ),
        ),
      );

      final result = await repo.searchItems('mil');
      expect(
        result,
        isA<Right<Failure, ({List<ItemSearchResult> items, bool hasMore})>>(),
      );
      result.match((_) => fail('expected Right'), (data) {
        expect(data.items, hasLength(2));
        expect(data.items[0].id, 'ing-1');
        expect(data.items[0].name, 'Milk');
        expect(data.items[1].id, 'ing-2');
        expect(data.items[1].name, 'Eggs');
        expect(data.hasMore, isFalse);
      });
    });

    test('passes hasMore from datasource', () async {
      final repo = ItemSearchRepositoryImpl(
        _FakePantryRemoteDatasource(
          searchHandler: ({required query, required page}) async => (
            results: [
              {'id': 'ing-1', 'display_name': 'Milk'},
            ],
            hasMore: true,
          ),
        ),
      );

      final result = await repo.searchItems('mil', page: 1);
      result.match((_) => fail('expected Right'), (data) {
        expect(data.hasMore, isTrue);
      });
    });

    test('returns empty list when datasource has no results', () async {
      final repo = ItemSearchRepositoryImpl(
        _FakePantryRemoteDatasource(
          searchHandler: ({required query, required page}) async =>
              (results: <Map<String, dynamic>>[], hasMore: false),
        ),
      );

      final result = await repo.searchItems('xyz');
      result.match((_) => fail('expected Right'), (data) {
        expect(data.items, isEmpty);
        expect(data.hasMore, isFalse);
      });
    });

    test('returns Left on Failure from datasource', () async {
      final repo = ItemSearchRepositoryImpl(
        _FakePantryRemoteDatasource(
          searchHandler: ({required query, required page}) async {
            throw const NetworkFailure('offline');
          },
        ),
      );

      final result = await repo.searchItems('mil');
      expect(
        result,
        isA<Left<Failure, ({List<ItemSearchResult> items, bool hasMore})>>(),
      );
      result.match(
        (failure) => expect(failure.message, 'offline'),
        (_) => fail('expected Left'),
      );
    });

    test('returns Left on unexpected exception', () async {
      final repo = ItemSearchRepositoryImpl(
        _FakePantryRemoteDatasource(
          searchHandler: ({required query, required page}) async {
            throw Exception('boom');
          },
        ),
      );

      final result = await repo.searchItems('mil');
      expect(
        result,
        isA<Left<Failure, ({List<ItemSearchResult> items, bool hasMore})>>(),
      );
    });
  });
}
