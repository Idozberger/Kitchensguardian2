import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

class ContinueButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final bool isUpdating;

  const ContinueButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.isUpdating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: h(48),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(t(12)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(t(12)),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: h(24),
                    height: w(24),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    isUpdating ? "Update" : 'Continue',
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      fontSize: t(14),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
