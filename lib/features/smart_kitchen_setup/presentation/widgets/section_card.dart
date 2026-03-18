import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/kitchen_snippet.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/data/models/kitchen_section_model.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/widgets/collage_preview.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/widgets/section_card_action.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/widgets/section_card_hint.dart';
import 'package:go_router/go_router.dart';

class SectionCard extends StatefulWidget {
  final KitchenSection section;
  final bool isScanning;
  final VoidCallback onScan;
  final VoidCallback onClear;

  const SectionCard({
    super.key,
    required this.section,
    required this.isScanning,
    required this.onScan,
    required this.onClear,
  });

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.section.isComplete;
    final isSpices = widget.section.id == 'spices';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xffD4D2D2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: w(40),
                    height: h(40),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        widget.section.icon,
                        width: w(22),
                        height: h(22),
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: w(12)),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.section.title,
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(
                                    color: Colors.black,
                                    fontSize: t(15),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            if (isSpices) ...[
                              const SizedBox(width: 6),
                              const SpicesImportantInfo(),
                            ],
                          ],
                        ),
                        if (_isExpanded)
                          Text(
                            widget.section.subtitle,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  color: const Color(0xff787878),
                                  fontSize: t(12),
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                      ],
                    ),
                  ),

                  if (isDone) ...[
                    _PhotoBadge(section: widget.section),
                    SizedBox(width: w(8)),
                  ],

                  RotationTransition(
                    turns: _rotateAnimation,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.black,
                      size: t(22),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: h(4)),
                SectionCardHint(hint: widget.section.hint),
                if (isDone) ...[
                  SizedBox(height: h(12)),
                  CollagePreview(
                    paths: widget.section.imagePaths,
                    accent: widget.section.accent,
                    onAdd: widget.onScan,
                  ),
                ],
                SectionCardActions(
                  section: widget.section,
                  isDone: isDone,
                  isScanning: widget.isScanning,
                  onScan: widget.onScan,
                  onClear: widget.onClear,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoBadge extends StatelessWidget {
  final KitchenSection section;
  const _PhotoBadge({required this.section});

  @override
  Widget build(BuildContext context) {
    final count = section.imagePaths.length;
    return Container(
      padding: gapSymmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: section.accent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count photo${count != 1 ? 's' : ''}',
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: section.accent,
          fontSize: t(12),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class SpicesImportantInfo extends StatelessWidget {
  const SpicesImportantInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showSpicesInfoSheet(context),
      child: Icon(
        Icons.info_outline_rounded,
        size: t(16),
        color: AppColors.primaryColor,
      ),
    );
  }
}

void _showSpicesInfoSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: const [
                Icon(Icons.spa_outlined, color: Color(0xFFE67C4A)),
                SizedBox(width: 8),
                Text(
                  'Why spices matter',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            gapH(12),
            const Text(
              'Spices are a key part of accurate recipe suggestions and aren\'t bought often.\n\n'
              'Please make sure labels are visible so we can identify everything clearly and give you precise recipe recommendations.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            gapH(20),
            GenericButtonWidget(onPressed: () => context.pop(), text: "Got it"),
          ],
        ),
      );
    },
  );
}
