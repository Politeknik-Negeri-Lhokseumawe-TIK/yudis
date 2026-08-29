import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

/// Cyber Button dengan gradient purple, icon, and loading spinner
class CyberButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? color;
  final Color? textColor;
  final double height;
  final bool isFullWidth;

  const CyberButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.color,
    this.textColor,
    this.height = 48.0,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    final effectiveColor = color ?? AppTokens.primaryPurple;

    Widget buttonContent = SizedBox(
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? Colors.white.withValues(alpha: 0.1)
              : effectiveColor,
          foregroundColor: textColor ?? Colors.white,
          disabledForegroundColor: Colors.white38,
          elevation: isDisabled ? 0 : 4,
          shadowColor: effectiveColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onPressed: isDisabled ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: buttonContent,
      );
    }
    return buttonContent;
  }
}
