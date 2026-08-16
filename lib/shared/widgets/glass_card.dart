import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

/// Reusable Liquid Glass Card menggunakan BackdropFilter + blur
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = AppTokens.glassBlur,
    this.fillColor,
    this.borderColor,
    this.borderWidth = AppTokens.glassBorderWidth,
    this.shadows,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final double blur;
  final Color? fillColor;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(AppTokens.radiusLG);
    final effectiveFill =
        fillColor ?? (isDark ? AppTokens.glassFillDark : AppTokens.glassFillLight);
    final effectiveBorder =
        borderColor ?? AppTokens.glassBorderColor;

    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        boxShadow: shadows ?? AppTokens.shadowCard,
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppTokens.spaceMD),
            decoration: BoxDecoration(
              color: effectiveFill,
              borderRadius: effectiveBorderRadius,
              border: Border.all(
                color: effectiveBorder,
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

/// Variasi GlassCard untuk stat/metric cards
class GlassStatCard extends StatelessWidget {
  const GlassStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = color ?? AppTokens.primaryGreenLight;
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTokens.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTokens.spaceXS),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTokens.radiusSM),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(height: AppTokens.spaceMD),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.spaceXXS),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    );
  }
}
