import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

class SocialAuthButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  final String text;
  final String iconPath;

  const SocialAuthButton({
    super.key,
    required this.onTap,
    required this.isLoading,
    required this.text,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapSymmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(h(10)),
        onTap: isLoading ? null : onTap,
        child: Ink(
          height: h(48),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[300]!, width: 1),
            borderRadius: BorderRadius.circular(h(10)),
          ),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: w(24),
                    height: h(24),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryColor,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(iconPath, height: h(20), width: w(20)),
                    SizedBox(width: w(10)),
                    Text(
                      text,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: t(14),
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
