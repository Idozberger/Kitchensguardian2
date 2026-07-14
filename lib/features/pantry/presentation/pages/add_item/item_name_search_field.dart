import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/di/service_locator.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/pantry/domain/repository/item_search_repository.dart';

/// "Item name" field with debounced, backend-searched autocomplete.
class ItemNameSearchField extends StatefulWidget {
  const ItemNameSearchField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<ItemNameSearchField> createState() => _ItemNameSearchFieldState();
}

class _ItemNameSearchFieldState extends State<ItemNameSearchField> {
  final _repository = sl<ItemSearchRepository>();
  final _layerLink = LayerLink();
  final _focusNode = FocusNode();
  Timer? _debounce;
  OverlayEntry? _overlayEntry;
  List<String> _results = [];
  int _searchToken = 0;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) _removeOverlay();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.removeListener(_handleFocusChange);
    _removeOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(query));
  }

  Future<void> _search(String query) async {
    final token = ++_searchToken;
    if (query.trim().isEmpty) {
      _removeOverlay();
      return;
    }
    final result = await _repository.searchItems(query);
    if (!mounted || token != _searchToken) return;
    result.match((_) => _removeOverlay(), _showResults);
  }

  void _showResults(List<String> items) {
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

  void _selectItem(String item) {
    widget.controller.text = item;
    widget.controller.selection = TextSelection.collapsed(offset: item.length);
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
                thumbVisibility: true,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final item = _results[index];
                    return InkWell(
                      onTap: () => _selectItem(item),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: w(12),
                          vertical: h(12),
                        ),
                        child: Text(
                          item,
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
