import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_tokens.dart';

/// App bar transparan dengan backdrop blur effect
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.bottom,
    this.blur = 12.0,
    this.showBackButton = true,
    this.centerTitle = false,
    this.isDark,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double blur;
  final bool showBackButton;
  final bool centerTitle;
  final bool? isDark;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveDark = isDark ?? theme.brightness == Brightness.dark;
    final foregroundColor = effectiveDark ? Colors.white : AppTokens.primaryGreenDark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: effectiveDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Container(
            height: preferredSize.height + MediaQuery.of(context).padding.top,
            decoration: BoxDecoration(
              color: effectiveDark
                  ? const Color(0x28061A0E)
                  : const Color(0xAAF0F7F3),
              border: Border(
                bottom: BorderSide(
                  color: effectiveDark
                      ? const Color(0x20FFFFFF)
                      : const Color(0x20000000),
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: kToolbarHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.spaceMD),
                      child: Row(
                        children: [
                          // Leading
                          if (leading != null)
                            leading!
                          else if (showBackButton && Navigator.of(context).canPop())
                            _BackButton(color: foregroundColor),

                          const SizedBox(width: AppTokens.spaceXS),

                          // Title
                          Expanded(
                            child: centerTitle
                                ? Center(
                                    child: _buildTitle(context, foregroundColor),
                                  )
                                : _buildTitle(context, foregroundColor),
                          ),

                          // Actions
                          ...?actions,
                        ],
                      ),
                    ),
                  ),
                  ?bottom,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, Color color) {
    if (titleWidget != null) return titleWidget!;
    if (title != null) {
      return Text(
        title!,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
        overflow: TextOverflow.ellipsis,
      );
    }
    return const SizedBox.shrink();
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.all(AppTokens.spaceXS),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTokens.radiusSM),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded, color: color, size: 16),
      ),
    );
  }
}
