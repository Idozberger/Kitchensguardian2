import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/di/service_locator.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/pantry/domain/repository/item_search_repository.dart';

/// "Item name" field with debounced, backend-searched autocomplete.
///
/// Selecting a suggestion links the row to the shared ingredient catalog via
/// [onCatalogIdChanged]; typing a custom name afterwards clears that link.
class ItemNameSearchField extends StatefulWidget {
  const ItemNameSearchField({
    super.key,
    required this.controller,
    this.onCatalogIdChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String?>? onCatalogIdChanged;

  @override
  State<ItemNameSearchField> createState() => _ItemNameSearchFieldState();
}

class _ItemNameSearchFieldState extends State<ItemNameSearchField> {
  final _repository = sl<ItemSearchRepository>();
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

  @override
  void initState() {
    super.initState();
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
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(query));
  }

  Future<void> _search(String query) async {
    final token = ++_searchToken;
    if (query.trim().length < 2) {
      _removeOverlay();
      return;
    }
    _query = query;
    final result = await _repository.searchItems(query);
    if (!mounted || token != _searchToken) return;
    result.match((_) => _removeOverlay(), (res) {
      _page = 1;
      _hasMore = res.hasMore;
      _showResults(res.items);
    });
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
    _overlayEntry?.markNeedsBuild();
    final result = await _repository.searchItems(_query, page: _page + 1);
    if (!mounted || token != _searchToken) return;
    _loadingMore = false;
    result.match((_) {}, (res) {
      _page += 1;
      _hasMore = res.hasMore;
      _results = [..._results, ...res.items];
      _overlayEntry?.markNeedsBuild();
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _showResults(List<ItemSearchResult> items) {
    _results = items;
    if (items.isEmpty || !_focusNode.hasFocus) {
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
  }

  void _selectItem(ItemSearchResult item) {
    widget.controller.text = item.name;
    widget.controller.selection = TextSelection.collapsed(
      offset: item.name.length,
    );
    widget.onCatalogIdChanged?.call(item.id);
    _removeOverlay();
    _focusNode.unfocus();
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
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _results.length + (_loadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _results.length) {
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
                    final item = _results[index];
                    return InkWell(
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
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
        onTap: () {
          if (_results.isNotEmpty) _showResults(_results);
        },
      ),
    );
  }
}
