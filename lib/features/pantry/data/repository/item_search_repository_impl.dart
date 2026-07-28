import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
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
              iconUrl: _resolveIconUrl(json),
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

  /// This endpoint returns `image_url` (a backend-relative
  /// `/api/shared_ingredients/<id>/image` path that redirects to the actual
  /// file) with `icon_url` always null; other endpoints (pantry items, scan
  /// results) use `icon_url`/`thumbnail` for the same purpose, so both shapes
  /// are accepted here. Relative paths resolve against the API host. Empty
  /// when the response carries no icon at all — the UI shows a placeholder.
  String _resolveIconUrl(Map<String, dynamic> json) {
    for (final key in const [
      'icon_url',
      'image_url',
      'thumbnail_url',
      'thumbnail',
      'icon',
      'image',
    ]) {
      final value = readJsonString(json, key).trim();
      if (value.isEmpty) continue;
      return value.startsWith('/') ? '${AppConstants.baseUrl}$value' : value;
    }
    return '';
  }
}
