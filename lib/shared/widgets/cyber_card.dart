import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

/// Cyber Glass Card dengan glow effect dan rounded cyber corners
class CyberCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final Color? borderColor;
  final Color? fillColor;
  final VoidCallback? onTap;

  const CyberCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderColor,
    this.fillColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(AppTokens.radiusMD);
    final effectiveBorder = borderColor ?? AppTokens.glassBorderColor;
    final effectiveFill = fillColor ?? AppTokens.bgDarkCard.withValues(alpha: 0.85);

    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveFill,
        borderRadius: effectiveBorderRadius,
        border: Border.all(color: effectiveBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius as BorderRadius?,
        child: content,
      );
    }
    return content;
  }
}
