import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:foodkitchen/features/pantry/data/datasource/pantry_remote_datasource.dart';
import 'package:foodkitchen/features/pantry/domain/repository/item_search_repository.dart';
import 'package:fpdart/fpdart.dart';

class ItemSearchRepositoryImpl implements ItemSearchRepository {
  final PantryRemoteDatasource _datasource;

  ItemSearchRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, ({List<ItemSearchResult> items, bool hasMore})>>
  searchItems(String query, {int page = 1}) async {
    try {
      final response = await _datasource.searchSharedIngredients(
        query: query,
        page: page,
      );
      final items = response.results
          .map(
            (json) => ItemSearchResult(
              id: readJsonString(json, 'id'),
              name: readJsonString(json, 'display_name'),
            ),
          )
          .toList();
      return Right((items: items, hasMore: response.hasMore));
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(unknownFailureFrom(e));
    }
  }
}
