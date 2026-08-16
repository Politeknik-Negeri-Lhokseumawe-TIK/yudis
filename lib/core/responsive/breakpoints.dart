import 'package:flutter/material.dart';

/// Responsive breakpoints untuk web layout
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;

  /// Ambang batas desktop yang memperhitungkan lebar sidebar (240px)
  /// Digunakan untuk memutuskan kapan mengaktifkan 2-column content layout.
  static const double sidebarAwareDesktop = 1264; // 1024 + 240

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobile && w < tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  /// Desktop dengan memperhitungkan lebar sidebar (lebih ketat)
  static bool isDesktopWithSidebar(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= sidebarAwareDesktop;

  static bool isWideDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  /// Max content width untuk desktop layout
  static const double maxContentWidth = 1200.0;

  /// Sidebar width
  static const double sidebarWidth = 240.0;
  static const double sidebarCollapsedWidth = 72.0;
}

/// Extension untuk responsive values
extension ResponsiveContext on BuildContext {
  bool get isMobile => Breakpoints.isMobile(this);
  bool get isTablet => Breakpoints.isTablet(this);
  bool get isDesktop => Breakpoints.isDesktop(this);

  /// Desktop mode yang memperhitungkan lebar sidebar — gunakan ini
  /// untuk keputusan 2-column layout di dalam halaman yang punya sidebar.
  bool get isDesktopWithSidebar => Breakpoints.isDesktopWithSidebar(this);

  /// Responsive value berdasarkan lebar layar
  T responsive<T>({required T mobile, T? tablet, required T desktop}) {
    if (Breakpoints.isMobile(this)) return mobile;
    if (Breakpoints.isTablet(this)) return tablet ?? desktop;
    return desktop;
  }

  double get horizontalPadding => responsive(
        mobile: 16.0,
        tablet: 32.0,
        desktop: 48.0,
      );

  double get verticalPadding => responsive(
        mobile: 16.0,
        tablet: 24.0,
        desktop: 32.0,
      );

  int get gridColumns => responsive(
        mobile: 2,
        tablet: 3,
        desktop: 4,
      );
}
