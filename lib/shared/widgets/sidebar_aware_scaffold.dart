import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_tokens.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Scaffold responsif yang mengintegrasikan sidebar di desktop/tablet
/// dan AppBar biasa di mobile. Tidak ada nested Scaffold — sidebar adalah
/// bagian dari body Row.
class SidebarAwareScaffold extends ConsumerWidget {
  const SidebarAwareScaffold({
    super.key,
    required this.location,
    required this.body,
    this.mobileAppBar,
    this.extendBodyBehindAppBar = true,
    this.resizeToAvoidBottomInset,
  });

  final String location;
  final Widget body;
  final PreferredSizeWidget? mobileAppBar;
  final bool extendBodyBehindAppBar;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.isAdmin;

    if (context.isDesktop) {
      return Scaffold(
        backgroundColor: AppTokens.bgDark,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: Row(
          children: [
            SidebarWidget(isAdmin: isAdmin, location: location),
            Expanded(child: body),
          ],
        ),
      );
    }

    if (context.isTablet) {
      return Scaffold(
        backgroundColor: AppTokens.bgDark,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: Row(
          children: [
            SidebarWidget(
                isAdmin: isAdmin, location: location, collapsed: true),
            Expanded(child: body),
          ],
        ),
      );
    }

    // Mobile — Scaffold normal dengan AppBar
    return Scaffold(
      backgroundColor: AppTokens.bgDark,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: mobileAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: body,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SIDEBAR WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class SidebarWidget extends ConsumerWidget {
  const SidebarWidget({
    super.key,
    required this.isAdmin,
    required this.location,
    this.collapsed = false,
  });

  final bool isAdmin;
  final String location;
  final bool collapsed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = collapsed
        ? Breakpoints.sidebarCollapsedWidth
        : Breakpoints.sidebarWidth;

    final navItems = isAdmin ? _adminNavItems : _mahasiswaNavItems;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: w,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppTokens.bgDarkCard.withValues(alpha: 0.95),
            border: const Border(
              right: BorderSide(color: AppTokens.glassBorderColor),
            ),
          ),
          child: Column(
            children: [
              _SidebarHeader(collapsed: collapsed),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: navItems.map((item) {
                    final active = location.startsWith(item.path);
                    final isLocked = !isAdmin &&
                        ref.watch(authProvider).isPendingVerifikasi &&
                        item.path == '/mahasiswa/daftar';

                    return _SidebarItem(
                      item: item,
                      isActive: active,
                      collapsed: collapsed,
                      isLocked: isLocked,
                      onTap: () {
                        if (isLocked) {
                          _showLockedDialog(context);
                        } else {
                          context.go(item.path);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              const Divider(color: AppTokens.glassBorderColor),
              _SidebarLogoutButton(
                collapsed: collapsed,
                onLogout: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
              ),
              const SizedBox(height: 6),
              // Watermark / Credit
              _SidebarWatermark(collapsed: collapsed),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  static void _showLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D2818),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMD),
          side: const BorderSide(color: AppTokens.accentGold, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_clock_rounded, color: AppTokens.accentGold, size: 24),
            SizedBox(width: 10),
            Text(
              'Menunggu Verifikasi',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Akun Anda saat ini sedang dalam proses verifikasi oleh Admin/Laboran Jurusan TIK PNL.\n\nLayanan pengajuan peminjaman laboratorium dan ruang kelas akan terbuka secara otomatis segera setelah akun Anda disetujui.',
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Mengerti', style: TextStyle(color: AppTokens.accentGoldLight, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SidebarWatermark extends StatelessWidget {
  const _SidebarWatermark({required this.collapsed});
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return const Tooltip(
        message: 'Dibuat oleh Nazarul Qudri\nCTO TIK — TRKJ PNL',
        preferBelow: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Icon(Icons.code_rounded, size: 16, color: Colors.white24),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(AppTokens.radiusSM),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_outlined,
                  size: 11, color: AppTokens.primaryGreenLight),
              const SizedBox(width: 5),
              const Flexible(
                child: Text(
                  'Nazarul Qudri',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Chief Technology Officer\nJurusan TIK — Prodi TRKJ PNL',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 9,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarHeader extends ConsumerWidget {
  const _SidebarHeader({required this.collapsed});
  final bool collapsed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    // Avatar initials: ambil dua kata pertama nama
    String getInitials(String nama) {
      final parts = nama.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      return nama.isNotEmpty ? nama[0].toUpperCase() : '?';
    }

    // Warna prodi
    Color getProdiColor(dynamic prodi) {
      final v = prodi?.value ?? '';
      if (v == 'TRKJ') return AppTokens.prodiTRKJ;
      if (v == 'TRMM') return AppTokens.prodiTRMM;
      return AppTokens.prodiTI;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── App brand row ─────────────────────────────────────
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTokens.primaryPurple, AppTokens.primaryPurpleGlow],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                  boxShadow: [
                    BoxShadow(
                      color: AppTokens.primaryPurple.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 18),
              ),
              if (!collapsed) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SIM-LAB',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14)),
                      Text('TIK PNL',
                          style: TextStyle(
                              color: AppTokens.accentGold,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 1.5)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── User identity card ────────────────────────────────
        if (user != null)
          Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            padding: collapsed
                ? const EdgeInsets.symmetric(vertical: 10)
                : const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(AppTokens.radiusMD),
              border: Border.all(
                color: getProdiColor(user.programStudi).withValues(alpha: 0.25),
              ),
            ),
            child: collapsed
                ? Center(
                    child: _buildAvatar(user.nama, getInitials(user.nama),
                        getProdiColor(user.programStudi), 32),
                  )
                : Row(
                    children: [
                      _buildAvatar(user.nama, getInitials(user.nama),
                          getProdiColor(user.programStudi), 36),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.nama.split(' ').first,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.nim,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: getProdiColor(user.programStudi)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: getProdiColor(user.programStudi)
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    user.programStudi.value,
                                    style: TextStyle(
                                        color: getProdiColor(user.programStudi),
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                _PulseDot(
                                    color: user.statusAkun.name == 'aktif'
                                        ? AppTokens.success
                                        : AppTokens.accentGold),
                                const SizedBox(width: 4),
                                Text(
                                  user.statusAkun.name == 'aktif'
                                      ? 'Aktif'
                                      : 'Pending',
                                  style: TextStyle(
                                    color: user.statusAkun.name == 'aktif'
                                        ? AppTokens.success
                                        : AppTokens.accentGold,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),

        const Divider(height: 1, color: AppTokens.glassBorderColor),
      ],
    );
  }

  Widget _buildAvatar(
      String nama, String initials, Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 1),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.35,
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.item,
    required this.isActive,
    required this.collapsed,
    required this.onTap,
    this.isLocked = false,
  });

  final _NavItem item;
  final bool isActive;
  final bool collapsed;
  final VoidCallback onTap;
  final bool isLocked;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isLocked
        ? AppTokens.accentGold.withValues(alpha: 0.7)
        : widget.isActive
            ? AppTokens.primaryGreenLight
            : _hovered
                ? Colors.white70
                : Colors.white38;

    return Tooltip(
      message: widget.isLocked
          ? 'Fitur Terkunci (Menunggu Verifikasi)'
          : widget.collapsed
              ? widget.item.label
              : '',
      preferBelow: false,
      child: MouseRegion(
        onEnter: (_) {
          if (mounted) setState(() => _hovered = true);
        },
        onExit: (_) {
          if (mounted) setState(() => _hovered = false);
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: AppTokens.durationFast,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? AppTokens.primaryGreenLight.withValues(alpha: 0.12)
                  : _hovered
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTokens.radiusSM),
            ),
            child: Row(
              mainAxisAlignment: widget.collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                // Active bar indicator on the left
                if (!widget.collapsed)
                  AnimatedContainer(
                    duration: AppTokens.durationFast,
                    width: 3,
                    height: 22,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: widget.isActive
                          ? AppTokens.primaryGreenLight
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: widget.isActive
                          ? [
                              BoxShadow(
                                color: AppTokens.primaryGreenLight
                                    .withValues(alpha: 0.6),
                                blurRadius: 6,
                              ),
                            ]
                          : null,
                    ),
                  ),
                Icon(
                  widget.isLocked ? Icons.lock_outline_rounded : widget.item.icon,
                  color: color,
                  size: 20,
                ),
                if (!widget.collapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.item.label,
                      style: TextStyle(
                        color: color,
                        fontWeight: widget.isActive
                            ? FontWeight.w700
                            : FontWeight.w400,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  if (widget.isLocked)
                    const Icon(Icons.lock_rounded,
                        size: 14, color: AppTokens.accentGold),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget dot berdenyut halus untuk status aktif/pending
class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.color});
  final Color color;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: _animation.value),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _animation.value * 0.7),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SidebarLogoutButton extends StatefulWidget {
  const _SidebarLogoutButton({
    required this.collapsed,
    required this.onLogout,
  });

  final bool collapsed;
  final VoidCallback onLogout;

  @override
  State<_SidebarLogoutButton> createState() => _SidebarLogoutButtonState();
}

class _SidebarLogoutButtonState extends State<_SidebarLogoutButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.collapsed ? 'Keluar' : '',
      child: MouseRegion(
        onEnter: (_) {
          if (mounted) setState(() => _hovered = true);
        },
        onExit: (_) {
          if (mounted) setState(() => _hovered = false);
        },
        child: GestureDetector(
          onTap: widget.onLogout,
          child: AnimatedContainer(
            duration: AppTokens.durationFast,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _hovered
                  ? AppTokens.error.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTokens.radiusSM),
            ),
            child: Row(
              mainAxisAlignment: widget.collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: _hovered ? AppTokens.error : Colors.white38,
                  size: 20,
                ),
                if (!widget.collapsed) ...[
                  const SizedBox(width: 12),
                  Text(
                    'Keluar',
                    style: TextStyle(
                      color: _hovered ? AppTokens.error : Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NAV ITEMS
// ─────────────────────────────────────────────────────────────────────────────
class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
  });

  final IconData icon;
  final String label;
  final String path;
}

const _mahasiswaNavItems = [
  _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', path: '/mahasiswa/dashboard'),
  _NavItem(icon: Icons.calendar_month_rounded, label: 'Roster Digital', path: '/roster-digital'),
  _NavItem(icon: Icons.meeting_room_rounded, label: 'Ketersediaan Lab', path: '/ketersediaan-ruangan'),
  _NavItem(icon: Icons.add_circle_outline_rounded, label: 'Pinjam Ruangan', path: '/form-peminjaman'),
  _NavItem(icon: Icons.notifications_outlined, label: 'Notifikasi', path: '/notifikasi'),
];

const _adminNavItems = [
  _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard Approval', path: '/admin/dashboard'),
  _NavItem(icon: Icons.calendar_month_rounded, label: 'Roster Digital', path: '/roster-digital'),
  _NavItem(icon: Icons.meeting_room_rounded, label: 'Matriks Okupansi', path: '/ketersediaan-ruangan'),
  _NavItem(icon: Icons.notifications_outlined, label: 'Notifikasi', path: '/notifikasi'),
];
