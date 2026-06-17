import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

class PopupDropdownField extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> items;
  final String? hint;
  final ValueChanged<String?> onChanged;

  const PopupDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
  });

  @override
  State<PopupDropdownField> createState() => _PopupDropdownFieldState();
}

class _PopupDropdownFieldState extends State<PopupDropdownField> {
  final ScrollController _scrollController = ScrollController();

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggleDropdown() {
    FocusScope.of(context).unfocus();

    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
    setState(() => _isOpen = !_isOpen);
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _removeOverlay();
                setState(() => _isOpen = false);
              },
            ),
          ),

          Positioned(
            width: size.width,
            left: position.dx,
            top: position.dy + size.height + h(5),
            child: Scrollbar(
              thumbVisibility: true,
              controller: _scrollController,
              child: CompositedTransformFollower(
                link: _layerLink,
                offset: Offset(w(2), size.height + h(4)),
                showWhenUnlinked: false,
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
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.zero,
                      itemCount: widget.items.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final option = widget.items[index];
                        final isSelected = widget.value == option;

                        return InkWell(
                          onTap: () {
                            widget.onChanged(option);
                            _removeOverlay();
                            setState(() => _isOpen = false);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: w(12),
                              vertical: h(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    option,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: isSelected
                                              ? Colors.black
                                              : const Color(0xff787878),
                                        ),
                                  ),
                                ),
                              ],
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
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();

    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(color: Colors.black),
          ),
          SizedBox(height: h(8)),
          GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: w(12), vertical: h(14)),
              decoration: BoxDecoration(
                color: Color(0xffF9F9F9),
                borderRadius: BorderRadius.circular(h(8)),
                border: Border.all(
                  color: AppColors.appTextFieldBorderColor,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.value ?? widget.hint ?? "",
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: AppColors.apptextFieldStyleTextColor,
                            fontSize: t(14),
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SvgPicture.asset(
                    _isOpen ? AppAssets.downArrow : AppAssets.downArrow,
                    colorFilter: const ColorFilter.mode(
                      Color(0xff787878),
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
