import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class LiveCarCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final Color? backgroundColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? borderLeftColor;

  const LiveCarCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.backgroundColor,
    this.borderRadius = 16,
    this.onTap,
    this.borderLeftColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: borderLeftColor != null
              ? Border(
                  right: BorderSide(color: borderLeftColor!, width: 4),
                  top: BorderSide(color: borderColor ?? AppColors.grayLight),
                  bottom: BorderSide(color: borderColor ?? AppColors.grayLight),
                  left: BorderSide(color: borderColor ?? AppColors.grayLight),
                )
              : Border.all(color: borderColor ?? AppColors.grayLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
