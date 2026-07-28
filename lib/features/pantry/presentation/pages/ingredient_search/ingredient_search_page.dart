import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/di/service_locator.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/core/widgets/safe_image.dart';
import 'package:foodkitchen/features/pantry/domain/repository/item_search_repository.dart';
import 'package:foodkitchen/features/pantry/presentation/models/pantry_items.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/add_item/add_item_page_chrome.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

/// Catalog-first entry point for "Add Item": browse/search the shared
/// ingredient catalog, tap a row to open the add-item form (quantity, unit,
/// pantry, expiry) prefilled with that ingredient.
///
/// Items missing from the catalog are still addable through "Create New Item",
/// which opens the same form with the typed name and no catalog link.
class IngredientSearchPage extends StatefulWidget {
  const IngredientSearchPage({
    super.key,
    this.isMember = false,
    this.repository,
  });

  final bool isMember;

  /// Optional override for tests; production uses [sl].
  final ItemSearchRepository? repository;

  @override
  State<IngredientSearchPage> createState() => _IngredientSearchPageState();
}

class _IngredientSearchPageState extends State<IngredientSearchPage> {
  static const _debounceMs = 300;

  late final ItemSearchRepository _repository;
  final _queryController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  List<ItemSearchResult> _results = [];
  int _searchToken = 0;
  String _query = '';
  int _page = 1;
  bool _hasMore = false;
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? sl<ItemSearchRepository>();
    _scrollController.addListener(_onScroll);
    // Empty query = browse the catalog, so the list isn't blank on open.
    unawaited(_search(''));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: _debounceMs),
      () => unawaited(_search(query)),
    );
  }

  Future<void> _search(String query) async {
    final token = ++_searchToken;
    setState(() {
      _query = query.trim();
      _loading = true;
      _error = null;
    });

    final result = await _repository.searchItems(_query);
    if (!mounted || token != _searchToken) return;

    setState(() {
      _loading = false;
      result.match(
        (failure) {
          _results = [];
          _hasMore = false;
          // Browsing with an empty query may not be supported by the backend —
          // show the "type to search" hint instead of an unactionable error.
          _error = _query.isEmpty ? null : failure.userMessage;
        },
        (res) {
          _page = 1;
          _results = res.items;
          _hasMore = res.hasMore;
        },
      );
    });
  }

  void _onScroll() {
    if (!_hasMore || _loading || _loadingMore) return;
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 40) {
      return;
    }
    unawaited(_loadMore());
  }

  Future<void> _loadMore() async {
    final token = _searchToken;
    setState(() => _loadingMore = true);

    final result = await _repository.searchItems(_query, page: _page + 1);
    if (!mounted || token != _searchToken) return;

    setState(() {
      _loadingMore = false;
      result.match(
        (failure) {
          _hasMore = false;
          AppToast.show(failure.userMessage, ToastType.error);
        },
        (res) {
          _page += 1;
          _hasMore = res.hasMore;
          _results = [..._results, ...res.items];
        },
      );
    });
  }

  /// Opens the add-item form with a single prefilled row.
  void _openAddItemForm({
    required String name,
    String? sharedIngredientId,
    String? iconUrl,
  }) {
    final item = PantryItem(
      nameController: TextEditingController(text: name),
      qtyController: TextEditingController(),
      expireDate: TextEditingController(),
      manuFacturingDate: TextEditingController(),
      iconUrl: iconUrl,
    )..sharedIngredientId = sharedIngredientId;

    context.pushNamed(
      Routes.addItem,
      extra: {
        'pantryItems': [item],
        'isMember': widget.isMember,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AddItemPageAppBar(
        isMember: widget.isMember,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: gapOnly(left: 20, right: 20, top: 8, bottom: 14),
              child: _searchField(context),
            ),
            Padding(
              padding: gapOnly(left: 20, right: 20, bottom: 10),
              child: Text(
                "Ingredients (tap one to add)",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: t(15),
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(child: _content(context)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: const Color(0xFFF9F9F9),
          padding: gapOnly(left: 20, right: 20, top: 14, bottom: 14),
          child: GenericButtonWidget(
            text: "Create New Item",
            onPressed: () =>
                _openAddItemForm(name: _queryController.text.trim()),
          ),
        ),
      ),
    );
  }

  Widget _searchField(BuildContext context) {
    return AppTextField(
      controller: _queryController,
      onChanged: _onQueryChanged,
      isFilled: true,
      fillColor: Colors.white,
      color: AppColors.apptextFieldStyleTextColor,
      prefixIcon: Padding(
        padding: gapAll(12),
        child: SvgPicture.asset(AppAssets.searchSvg),
      ),
      hintText: "Type ingredient name to search...",
      label: '',
      isLabled: false,
      textInputAction: TextInputAction.search,
    );
  }

  Widget _content(BuildContext context) {
    if (_loading) {
      return Center(child: Lottie.asset(AppAssets.loader));
    }

    final error = _error;
    if (error != null) {
      return _centeredMessage(
        context,
        error,
        color: AppColors.errorColor,
        onRetry: () => unawaited(_search(_query)),
      );
    }

    if (_results.isEmpty) {
      return _centeredMessage(
        context,
        _query.isEmpty
            ? "Type an ingredient name to search the catalog"
            : "No ingredients found",
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: gapOnly(left: 20, right: 20, bottom: 8),
      itemCount: _results.length + (_loadingMore ? 1 : 0),
      separatorBuilder: (context, index) => SizedBox(height: h(10)),
      itemBuilder: (context, index) {
        if (index >= _results.length) {
          return Padding(
            padding: gapSymmetric(vertical: 12),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final item = _results[index];
        return _IngredientTile(
          item: item,
          onTap: () => _openAddItemForm(
            name: item.name,
            sharedIngredientId: item.id,
            iconUrl: item.iconUrl,
          ),
        );
      },
    );
  }

  Widget _centeredMessage(
    BuildContext context,
    String message, {
    Color? color,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: gapSymmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: t(14),
                color: color ?? AppColors.apptextFieldStyleTextColor,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: h(12)),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  "Try again",
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontSize: t(14),
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Catalog row: icon + name only — no trailing info action.
class _IngredientTile extends StatelessWidget {
  const _IngredientTile({required this.item, required this.onTap});

  final ItemSearchResult item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('ingredient_search_${item.id}'),
      borderRadius: BorderRadius.circular(h(14)),
      onTap: onTap,
      child: Container(
        padding: gapSymmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(h(14)),
          border: Border.all(color: const Color(0xffD4D2D2)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(h(10)),
              child: SafeNetworkImage(
                url: item.iconUrl,
                width: h(40),
                height: h(40),
                fallback: Container(
                  width: h(40),
                  height: h(40),
                  alignment: Alignment.center,
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.food_bank,
                    size: h(22),
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ),
            SizedBox(width: w(12)),
            Expanded(
              child: Text(
                item.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: t(15),
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
