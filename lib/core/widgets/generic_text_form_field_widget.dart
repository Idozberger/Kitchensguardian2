import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:foodkitchen/core/extensions/theme_extension.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final bool isLabled;
  final TextStyle? lableStyle;
  final bool enabled;
  final String hintText;
  final TextEditingController controller;
  final void Function(String)? onFieldSubmitted;
  final String? errorText;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool isFilled;
  final Color? color;
  final Color? fillColor;
  final Widget? prefixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final bool textAlignCentered;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  /// When true (default), the field scrolls itself into view above the keyboard
  /// once it gains focus. Safe no-op when there is no scrollable ancestor.
  final bool scrollOnFocus;
  const AppTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.contentPadding,
    this.errorText,
    this.inputFormatters,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.lableStyle,
    this.isLabled = true,
    this.enabled = true,
    this.onFieldSubmitted,
    this.isFilled = false,
    this.textInputAction = TextInputAction.done,
    this.textAlignCentered = false,
    this.onChanged,
    this.fillColor,
    this.color,
    this.onTap,
    this.focusNode,
    this.scrollOnFocus = true,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  FocusNode? _internalNode;
  FocusNode get _node => widget.focusNode ?? (_internalNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    if (widget.scrollOnFocus) {
      _node.addListener(_handleFocusChange);
    }
  }

  void _handleFocusChange() {
    if (!_node.hasFocus) return;
    // Wait for the keyboard to start resizing the viewport, then center the
    // focused field within the visible area above it.
    Future.delayed(const Duration(milliseconds: 300), _revealField);
  }

  void _revealField() {
    if (!mounted || !_node.hasFocus) return;
    final position = Scrollable.maybeOf(context)?.position;
    final box = context.findRenderObject();
    if (position == null || box is! RenderBox) return;

    final viewport = RenderAbstractViewport.of(box);
    // Offset that centers the field within the (keyboard-shrunk) viewport.
    final target = viewport.getOffsetToReveal(box, 0.5).offset;

    final clamped = target.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if ((clamped - position.pixels).abs() < 1) return;
    position.animateTo(
      clamped,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    if (widget.scrollOnFocus) {
      _node.removeListener(_handleFocusChange);
    }
    _internalNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isLabled) ...[
          Text(
            widget.label,
            style:
                widget.lableStyle ?? Theme.of(context).textTheme.headlineLarge,
          ),

          SizedBox(height: h(10)),
        ],

        TextFormField(
          focusNode: _node,
          inputFormatters: widget.inputFormatters,
          onTap: widget.onTap,
          enabled: widget.enabled,
          obscuringCharacter: "*",
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          onFieldSubmitted: widget.onFieldSubmitted,
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
            color: AppColors.apptextFieldStyleTextColor,
          ),
          validator: widget.validator,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            filled: widget.isFilled,
            fillColor: widget.fillColor,
            contentPadding: gapAll(12),
            hintText: widget.hintText,

            hintStyle: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.greyColor),
            border: outlineInputBorder(context),
            errorBorder: outlineInputBorder(
              context,
            ).copyWith(borderSide: BorderSide(color: AppColors.errorColor)),
            focusedBorder: outlineInputBorder(context),
            disabledBorder: outlineInputBorder(context),
            enabledBorder: outlineInputBorder(context),
            suffixIcon: widget.suffixIcon,
            prefixIcon: widget.prefixIcon,
          ),
        ),

        if (widget.errorText != null && widget.errorText!.isNotEmpty) ...[
          SizedBox(height: h(10)),
          Text(
            widget.errorText!,
            textAlign: widget.textAlignCentered
                ? TextAlign.center
                : TextAlign.start,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.errorColor,
              fontSize: t(12),
            ),
          ),
        ],
      ],
    );
  }
}

OutlineInputBorder outlineInputBorder(BuildContext context) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(h(10)),
    borderSide: BorderSide(
      color: context.isDarkTheme
          ? Colors.white
          : AppColors.appTextFieldBorderColor,
      width: 1.2,
    ),
  );
}
