import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

/// Root widget aplikasi Sistem Peminjaman Lab & Ruang Kelas TIK PNL
class SimLabApp extends ConsumerWidget {
  const SimLabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SIM-LAB & RUANG PBM TIK PNL',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark, // default dark (liquid glass look)

      // Router
      routerConfig: router,
    );
  }
}
