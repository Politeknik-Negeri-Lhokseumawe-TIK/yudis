import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

/// Tombol bergaya glass dengan AnimatedScale micro-interaction
class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
    this.textColor,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = GlassButtonSize.medium,
    this.variant = GlassButtonVariant.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool isLoading;
  final bool isFullWidth;
  final GlassButtonSize size;
  final GlassButtonVariant variant;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

enum GlassButtonSize { small, medium, large }
enum GlassButtonVariant { filled, outlined, ghost }

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTokens.durationFast,
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.reverse();
  void _onTapUp(TapUpDetails _) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = widget.color ??
        (isDark ? AppTokens.primaryGreenLight : AppTokens.primaryGreen);

    // Size config
    final (double hPad, double vPad, double fontSize) = switch (widget.size) {
      GlassButtonSize.small  => (AppTokens.spaceMD,  AppTokens.spaceXS,  AppTokens.textSM),
      GlassButtonSize.medium => (AppTokens.spaceLG,  AppTokens.spaceSM,  AppTokens.textMD),
      GlassButtonSize.large  => (AppTokens.spaceXL,  AppTokens.spaceMD,  AppTokens.textLG),
    };

    // Color config per variant
    final (Color bgColor, Color fgColor, Border? border) = switch (widget.variant) {
      GlassButtonVariant.filled  => (
          accentColor,
          widget.textColor ?? Colors.white,
          null,
        ),
      GlassButtonVariant.outlined => (
          accentColor.withValues(alpha: 0.12),
          widget.textColor ?? accentColor,
          Border.all(color: accentColor, width: 1.5),
        ),
      GlassButtonVariant.ghost => (
          Colors.transparent,
          widget.textColor ?? accentColor,
          null,
        ),
    };

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: widget.onPressed != null ? _onTapDown : null,
        onTapUp: widget.onPressed != null ? _onTapUp : null,
        onTapCancel: widget.onPressed != null ? _onTapCancel : null,
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: AppTokens.durationFast,
          width: widget.isFullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          decoration: BoxDecoration(
            color: widget.onPressed == null
                ? (isDark ? const Color(0x30FFFFFF) : const Color(0x20000000))
                : bgColor,
            borderRadius: BorderRadius.circular(AppTokens.radiusMD),
            border: border,
            boxShadow: widget.variant == GlassButtonVariant.filled && widget.onPressed != null
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: fgColor,
                    ),
                  )
                : Row(
                    mainAxisSize: widget.isFullWidth
                        ? MainAxisSize.max
                        : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: fgColor, size: fontSize + 2),
                        const SizedBox(width: AppTokens.spaceXS),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: fgColor,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
