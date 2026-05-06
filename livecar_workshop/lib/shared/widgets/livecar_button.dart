import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum LiveCarButtonVariant { primary, secondary, outline }

class LiveCarButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final LiveCarButtonVariant variant;
  final IconData? icon;
  final double? width;

  const LiveCarButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = LiveCarButtonVariant.primary,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final Widget child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == LiveCarButtonVariant.primary ? Colors.white : AppColors.bluePrimary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          );

    switch (variant) {
      case LiveCarButtonVariant.primary:
        return SizedBox(
          width: width ?? double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bluePrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: child,
          ),
        );
      case LiveCarButtonVariant.secondary:
        return SizedBox(
          width: width ?? double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueLight,
              foregroundColor: AppColors.bluePrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: child,
          ),
        );
      case LiveCarButtonVariant.outline:
        return SizedBox(
          width: width ?? double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.bluePrimary,
              side: const BorderSide(color: AppColors.bluePrimary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: child,
          ),
        );
    }
  }
}
