import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/admin_provider.dart';
import '../../domain/admin_models.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/domain/user_model.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/glass_button.dart';
import '../../../../shared/widgets/sidebar_aware_scaffold.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../pendaftaran_yudisium/presentation/widgets/prodi_badge_widget.dart';

class VerifikasiAkunScreen extends ConsumerStatefulWidget {
  const VerifikasiAkunScreen({super.key});

  @override
  ConsumerState<VerifikasiAkunScreen> createState() => _VerifikasiAkunScreenState();
}

class _VerifikasiAkunScreenState extends ConsumerState<VerifikasiAkunScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    final allMahasiswa = AuthService.getAllMahasiswaUsers();
    final filteredMahasiswa = allMahasiswa.where((u) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return u.nama.toLowerCase().contains(q) ||
          u.nim.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q);
    }).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SidebarAwareScaffold(
        location: '/admin/akun/pending',
        mobileAppBar: const GlassAppBar(title: 'Kelola Akun & Verifikasi'),
        body: AnimatedBackground(
          child: SafeArea(
            top: !context.isDesktop && !context.isTablet,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Padding(
                  padding: const EdgeInsets.all(AppTokens.spaceMD),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header title on desktop
                      if (context.isDesktop) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTokens.primaryPurple.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppTokens.radiusMD),
                                border: Border.all(
                                  color: AppTokens.primaryPurpleLight.withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.manage_accounts_rounded,
                                color: AppTokens.primaryPurpleLight,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kelola Akun & Verifikasi Mahasiswa',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                Text(
                                  'Persetujuan pendaftaran akun baru & manajemen password mahasiswa TIK',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.white54,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTokens.spaceLG),
                      ],

                      // Custom Liquid Glass Tabs
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(AppTokens.radiusMD),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTokens.primaryPurple, Color(0xFF6D28D9)],
                            ),
                            borderRadius: BorderRadius.circular(AppTokens.radiusMD),
                            boxShadow: [
                              BoxShadow(
                                color: AppTokens.primaryPurple.withValues(alpha: 0.4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white60,
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          tabs: [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.verified_user_outlined, size: 16),
                                  const SizedBox(width: 8),
                                  Text('Menunggu Verifikasi (${state.pendingAccounts.length})'),
                                ],
                              ),
                            ),
                            const Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.vpn_key_rounded, size: 16, color: AppTokens.accentGoldLight),
                                  SizedBox(width: 8),
                                  Text('Ubah Password Mahasiswa'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTokens.spaceMD),

                      // Tab Views
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // ── Tab 1: Menunggu Verifikasi ─────────────────────
                            state.pendingAccounts.isEmpty
                                ? _buildEmpty(context)
                                : ListView.separated(
                                    physics: const ClampingScrollPhysics(),
                                    itemCount: state.pendingAccounts.length,
                                    separatorBuilder: (_, _) => const SizedBox(height: AppTokens.spaceMD),
                                    itemBuilder: (ctx, i) {
                                      final account = state.pendingAccounts[i];
                                      return _AccountCard(
                                        account: account,
                                        onApprove: () => ref
                                            .read(adminProvider.notifier)
                                            .verifikasiAkun(account.user.id, true),
                                        onReject: () => _showRejectDialog(context, ref, account),
                                        onChangePassword: () => _showAdminChangePasswordDialog(
                                          context,
                                          account.user,
                                        ),
                                      ).animate().fadeIn(delay: (i * 100).ms, duration: 400.ms).slideX(begin: 0.1, end: 0);
                                    },
                                  ),

                            // ── Tab 2: Kelola & Ubah Password Mahasiswa ────────
                            Column(
                              children: [
                                // Search Bar
                                TextField(
                                  controller: _searchController,
                                  onChanged: (v) => setState(() => _searchQuery = v),
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Cari nama, NIM, atau email mahasiswa...',
                                    hintStyle: const TextStyle(color: Colors.white38),
                                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear_rounded, color: Colors.white54),
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() => _searchQuery = '');
                                            },
                                          )
                                        : null,
                                    filled: true,
                                    fillColor: Colors.white.withValues(alpha: 0.04),
                                  ),
                                ),
                                const SizedBox(height: AppTokens.spaceMD),

                                Expanded(
                                  child: filteredMahasiswa.isEmpty
                                      ? Center(
                                          child: Text(
                                            'Tidak ada mahasiswa ditemukan untuk "$_searchQuery"',
                                            style: const TextStyle(color: Colors.white38),
                                          ),
                                        )
                                      : ListView.separated(
                                          physics: const ClampingScrollPhysics(),
                                          itemCount: filteredMahasiswa.length,
                                          separatorBuilder: (_, _) => const SizedBox(height: AppTokens.spaceSM),
                                          itemBuilder: (ctx, i) {
                                            final user = filteredMahasiswa[i];
                                            return _MahasiswaPasswordCard(
                                              user: user,
                                              onChangePassword: () => _showAdminChangePasswordDialog(
                                                context,
                                                user,
                                              ),
                                            ).animate().fadeIn(delay: (i * 60).ms, duration: 300.ms);
                                          },
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              color: AppTokens.accentGold.withValues(alpha: 0.6), size: 64),
          const SizedBox(height: AppTokens.spaceMD),
          Text(
            'Semua akun baru sudah diverifikasi!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pendaftar baru akan otomatis muncul di sini secara real-time.',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref, PendingAccount account) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF130826),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLG),
          side: const BorderSide(color: AppTokens.error, width: 1.5),
        ),
        title: const Text('Tolak Pendaftaran Akun', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alasan penolakan untuk ${account.user.nama} (${account.user.nim}):',
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: AppTokens.spaceMD),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tuliskan alasan penolakan (misal: Data NIM tidak sesuai)...',
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(adminProvider.notifier).verifikasiAkun(
                    account.user.id,
                    false,
                    alasan: controller.text,
                  );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTokens.error),
            child: const Text('Tolak Akun', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Modal Ubah Password Mahasiswa oleh Admin ───────────────────
  void _showAdminChangePasswordDialog(BuildContext context, User user) {
    final newPasswordController = TextEditingController();
    bool obscure = true;
    String? errorMessage;
    bool isLoading = false;

    // Helper generator password acak
    void generateRandomPassword(StateSetter setDialogState) {
      const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789!@#';
      final rand = DateTime.now().millisecondsSinceEpoch;
      final suffix = List.generate(4, (i) => chars[(rand + i * 7) % chars.length]).join();
      final result = 'Pnl#${user.nim.length > 4 ? user.nim.substring(user.nim.length - 4) : user.nim}!$suffix';
      setDialogState(() {
        newPasswordController.text = result;
        errorMessage = null;
      });
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              decoration: BoxDecoration(
                color: const Color(0xFF130826),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTokens.primaryPurpleLight.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTokens.primaryPurple.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppTokens.primaryPurpleLight.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTokens.primaryPurple.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.key_rounded, color: AppTokens.primaryPurpleLight, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ubah Password Mahasiswa',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                '${user.nama} • ${user.nim}',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(dialogCtx),
                          child: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User summary card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: Row(
                            children: [
                              ProdiBadgeWidget(programStudi: user.programStudi.value, size: ProdiBadgeSize.chip),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  user.email,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (errorMessage != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppTokens.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTokens.error.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: AppTokens.error, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(errorMessage!, style: const TextStyle(color: AppTokens.error, fontSize: 12))),
                              ],
                            ),
                          ),

                        const Text('Masukkan kata sandi baru:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 8),

                        TextField(
                          controller: newPasswordController,
                          obscureText: obscure,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password Baru',
                            hintText: 'Minimal 6 karakter',
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.white54),
                            suffixIcon: GestureDetector(
                              onTap: () => setDialogState(() => obscure = !obscure),
                              child: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white54),
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.04),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Generate random password helper
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () => generateRandomPassword(setDialogState),
                              icon: const Icon(Icons.auto_fix_high_rounded, size: 14, color: AppTokens.accentGoldLight),
                              label: const Text('Buat Password Otomatis', style: TextStyle(color: AppTokens.accentGoldLight, fontSize: 12)),
                            ),
                            if (newPasswordController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white70),
                                tooltip: 'Salin Password',
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: newPasswordController.text));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Password berhasil disalin ke clipboard!'), duration: Duration(seconds: 2)),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(dialogCtx),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white60,
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final newPass = newPasswordController.text;
                                    if (newPass.length < 6) {
                                      setDialogState(() => errorMessage = 'Password minimal 6 karakter.');
                                      return;
                                    }
                                    setDialogState(() => isLoading = true);
                                    await Future.delayed(const Duration(milliseconds: 400));

                                    AuthService.adminChangePassword(
                                      userId: user.id,
                                      newPassword: newPass,
                                    );

                                    if (!ctx.mounted) return;
                                    Navigator.pop(ctx);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: const Color(0xFF1B0E38),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          side: const BorderSide(color: AppTokens.primaryPurpleLight),
                                        ),
                                        content: Text(
                                          'Password untuk ${user.nama} (${user.nim}) berhasil diubah menjadi "$newPass"!',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTokens.primaryPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Simpan Password Baru', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACCOUNT CARD (VERIFIKASI AKUN PENDING)
// ─────────────────────────────────────────────────────────────────────────────
class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.onApprove,
    required this.onReject,
    required this.onChangePassword,
  });

  final PendingAccount account;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return GlassCard(
      padding: const EdgeInsets.all(AppTokens.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar circle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTokens.accentGold.withValues(alpha: 0.15),
                  border: Border.all(color: AppTokens.accentGold.withValues(alpha: 0.4)),
                ),
                alignment: Alignment.center,
                child: Text(
                  account.user.nama.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: AppTokens.accentGoldLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.spaceMD),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.user.nama,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NIM: ${account.user.nim}  •  ${account.user.email}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
                    ),
                  ],
                ),
              ),

              ProdiBadgeWidget(
                programStudi: account.user.programStudi.value,
                size: ProdiBadgeSize.chip,
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceSM),

          Row(
            children: [
              const Icon(Icons.schedule_rounded, color: Colors.white38, size: 14),
              const SizedBox(width: 4),
              Text(
                'Daftar: ${df.format(account.registeredAt)}',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const Spacer(),
              // Quick reset password button
              TextButton.icon(
                onPressed: onChangePassword,
                icon: const Icon(Icons.key_rounded, size: 14, color: AppTokens.accentGoldLight),
                label: const Text('Ubah Password', style: TextStyle(color: AppTokens.accentGoldLight, fontSize: 11)),
              ),
            ],
          ),
          const Divider(color: AppTokens.glassBorderColor, height: 16),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GlassButton(
                label: 'Tolak',
                icon: Icons.close_rounded,
                size: GlassButtonSize.small,
                color: AppTokens.error,
                variant: GlassButtonVariant.outlined,
                isFullWidth: false,
                onPressed: onReject,
              ),
              const SizedBox(width: AppTokens.spaceSM),
              GlassButton(
                label: 'Setujui Akun',
                icon: Icons.check_rounded,
                size: GlassButtonSize.small,
                color: AppTokens.success,
                isFullWidth: false,
                onPressed: onApprove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAHASISWA PASSWORD CARD (TAB KELOLA PASSWORD)
// ─────────────────────────────────────────────────────────────────────────────
class _MahasiswaPasswordCard extends StatelessWidget {
  const _MahasiswaPasswordCard({
    required this.user,
    required this.onChangePassword,
  });

  final User user;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) {
    final isPending = user.statusAkun == StatusAkun.pendingVerifikasi;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPending
                  ? AppTokens.accentGold.withValues(alpha: 0.15)
                  : AppTokens.primaryPurple.withValues(alpha: 0.2),
              border: Border.all(
                color: isPending
                    ? AppTokens.accentGold.withValues(alpha: 0.4)
                    : AppTokens.primaryPurpleLight.withValues(alpha: 0.4),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              user.nama.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: isPending ? AppTokens.accentGoldLight : AppTokens.primaryPurpleLight,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.nama,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPending
                            ? AppTokens.accentGold.withValues(alpha: 0.15)
                            : AppTokens.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isPending ? 'Pending' : 'Aktif',
                        style: TextStyle(
                          color: isPending ? AppTokens.accentGoldLight : AppTokens.success,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${user.nim}  •  ${user.email}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

          ProdiBadgeWidget(programStudi: user.programStudi.value, size: ProdiBadgeSize.chip),
          const SizedBox(width: 12),

          ElevatedButton.icon(
            onPressed: onChangePassword,
            icon: const Icon(Icons.key_rounded, size: 14),
            label: const Text('Ubah Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
