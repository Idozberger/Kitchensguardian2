import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/di/service_locator.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/pantry/domain/repository/item_search_repository.dart';

enum _OverlayState { idle, searching, results, empty, error }

/// Applies a catalog suggestion to the name field and optional catalog link.
void applyItemSearchSelection({
  required TextEditingController controller,
  required ItemSearchResult item,
  ValueChanged<String?>? onCatalogIdChanged,
}) {
  controller.text = item.name;
  controller.selection = TextSelection.collapsed(offset: item.name.length);
  onCatalogIdChanged?.call(item.id);
}

/// "Item name" field with debounced, backend-searched autocomplete.
///
/// Selecting a suggestion links the row to the shared ingredient catalog via
/// [onCatalogIdChanged]; typing a custom name afterwards clears that link.
class ItemNameSearchField extends StatefulWidget {
  const ItemNameSearchField({
    super.key,
    required this.controller,
    this.onCatalogIdChanged,
    this.onEdited,
    this.repository,
  });

  final TextEditingController controller;
  final ValueChanged<String?>? onCatalogIdChanged;

  /// Called when the user edits the text (before debounced search).
  final VoidCallback? onEdited;

  /// Optional override for tests; production uses [sl].
  final ItemSearchRepository? repository;

  @override
  State<ItemNameSearchField> createState() => _ItemNameSearchFieldState();
}

class _ItemNameSearchFieldState extends State<ItemNameSearchField> {
  static const _minQueryLength = 3;
  static const _debounceMs = 300;

  late final ItemSearchRepository _repository;
  final _layerLink = LayerLink();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  Timer? _debounce;
  OverlayEntry? _overlayEntry;
  List<ItemSearchResult> _results = [];
  int _searchToken = 0;
  String _query = '';
  int _page = 1;
  bool _hasMore = false;
  bool _loadingMore = false;
  _OverlayState _overlayState = _OverlayState.idle;
  String? _errorMessage;
  String? _loadMoreError;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? sl<ItemSearchRepository>();
    _focusNode.addListener(_handleFocusChange);
    _scrollController.addListener(_onScroll);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) _removeOverlay();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.removeListener(_handleFocusChange);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _removeOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    widget.onCatalogIdChanged?.call(null);
    widget.onEdited?.call();
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: _debounceMs),
      () => _search(query),
    );
  }

  Future<void> _search(String query) async {
    final token = ++_searchToken;
    final trimmed = query.trim();
    if (trimmed.length < _minQueryLength) {
      _removeOverlay();
      return;
    }
    _query = query;
    _loadMoreError = null;
    _setOverlayState(_OverlayState.searching);
    final result = await _repository.searchItems(query);
    if (!mounted || token != _searchToken) return;
    result.match(
      (failure) {
        _errorMessage = failure.userMessage;
        _setOverlayState(_OverlayState.error);
      },
      (res) {
        _page = 1;
        _hasMore = res.hasMore;
        _errorMessage = null;
        if (res.items.isEmpty) {
          _results = [];
          _setOverlayState(_OverlayState.empty);
        } else {
          _results = res.items;
          _setOverlayState(_OverlayState.results);
        }
      },
    );
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore) return;
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 40) {
      return;
    }
    _loadMore();
  }

  Future<void> _loadMore() async {
    final token = _searchToken;
    _loadingMore = true;
    _loadMoreError = null;
    _overlayEntry?.markNeedsBuild();
    final result = await _repository.searchItems(_query, page: _page + 1);
    if (!mounted || token != _searchToken) return;
    _loadingMore = false;
    result.match(
      (failure) {
        _loadMoreError = failure.userMessage;
        _overlayEntry?.markNeedsBuild();
      },
      (res) {
        _page += 1;
        _hasMore = res.hasMore;
        _results = [..._results, ...res.items];
        _overlayEntry?.markNeedsBuild();
      },
    );
  }

  void _setOverlayState(_OverlayState state) {
    _overlayState = state;
    if (!_focusNode.hasFocus) {
      _removeOverlay();
      return;
    }
    if (state == _OverlayState.idle) {
      _removeOverlay();
      return;
    }
    if (_overlayEntry == null) {
      _overlayEntry = _buildOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _overlayState = _OverlayState.idle;
  }

  void _selectItem(ItemSearchResult item) {
    applyItemSearchSelection(
      controller: widget.controller,
      item: item,
      onCatalogIdChanged: widget.onCatalogIdChanged,
    );
    _removeOverlay();
    _focusNode.unfocus();
  }

  void _retrySearch() {
    if (_query.trim().length >= _minQueryLength) {
      unawaited(_search(_query));
    }
  }

  Widget _buildOverlayContent(BuildContext context) {
    switch (_overlayState) {
      case _OverlayState.searching:
        return Padding(
          padding: EdgeInsets.symmetric(vertical: h(16)),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      case _OverlayState.empty:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: w(12), vertical: h(16)),
          child: Text(
            'No ingredients found',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: const Color(0xff787878),
            ),
          ),
        );
      case _OverlayState.error:
        return InkWell(
          onTap: _retrySearch,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w(12), vertical: h(16)),
            child: Text(
              _errorMessage ?? 'Search failed. Tap to retry.',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: Colors.red.shade700),
            ),
          ),
        );
      case _OverlayState.results:
        return Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount:
                _results.length +
                (_loadingMore ? 1 : 0) +
                (_loadMoreError != null ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < _results.length) {
                final item = _results[index];
                return InkWell(
                  key: ValueKey('item_search_${item.id}'),
                  onTap: () => _selectItem(item),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: w(12),
                      vertical: h(12),
                    ),
                    child: Text(
                      item.name,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: const Color(0xff787878)),
                    ),
                  ),
                );
              }
              if (_loadingMore && index == _results.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: h(12)),
                  child: const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return InkWell(
                onTap: _loadMore,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: w(12),
                    vertical: h(12),
                  ),
                  child: Text(
                    _loadMoreError ?? 'Failed to load more. Tap to retry.',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      case _OverlayState.idle:
        return const SizedBox.shrink();
    }
  }

  OverlayEntry _buildOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final width = renderBox.size.width;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, renderBox.size.height + h(4)),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(h(8)),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffF9F9F9),
                borderRadius: BorderRadius.circular(h(8)),
                border: Border.all(color: AppColors.greyColor),
              ),
              constraints: BoxConstraints(maxHeight: h(220)),
              child: _buildOverlayContent(context),
            ),
          ),
        ),
      ),
    );
  }

  void _restoreOverlayIfNeeded() {
    if (!_focusNode.hasFocus || _overlayState == _OverlayState.idle) return;
    _setOverlayState(_overlayState);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: AppTextField(
        focusNode: _focusNode,
        textInputAction: TextInputAction.next,
        color: AppColors.apptextFieldStyleTextColor,
        controller: widget.controller,
        hintText: "Enter item name",
        fillColor: const Color(0xFFF9F9F9),
        isFilled: true,
        isLabled: false,
        keyboardType: TextInputType.text,
        label: '',
        onChanged: _onChanged,
        onTap: _restoreOverlayIfNeeded,
      ),
    );
  }
}
