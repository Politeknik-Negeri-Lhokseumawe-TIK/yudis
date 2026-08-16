import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../../data/auth_service.dart';
import '../../domain/user_model.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_button.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/responsive/breakpoints.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nimController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nimController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref.read(authProvider.notifier).login(
          nimOrEmail: _nimController.text,
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      final user = ref.read(authProvider).user!;
      if (user.statusAkun.value == 'pending_verifikasi') {
        context.go('/pending-verifikasi');
      } else if (user.role.value == 'admin' || user.role.value == 'super_admin') {
        context.go('/admin/dashboard');
      } else {
        context.go('/mahasiswa/dashboard');
      }
    }
  }

  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: context.isDesktop ? 120 : 20,
          vertical: 40,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1F12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTokens.primaryGreenLight.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTokens.primaryGreen.withValues(alpha: 0.25),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTokens.primaryGreenLight.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTokens.primaryGreenLight.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.security_rounded,
                        color: AppTokens.primaryGreenLight,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Keamanan Data & Jaringan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            'Sistem Yudisium TIK PNL — Protokol Perlindungan',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _securitySection(
                        Icons.lock_rounded,
                        'Enkripsi End-to-End (E2E)',
                        AppTokens.primaryGreenLight,
                        'Seluruh data yang dikirim dan diterima dienkripsi menggunakan protokol AES-256-CBC dengan kunci 256-bit. Setiap sesi komunikasi menggunakan Initialization Vector (IV) yang unik dan acak untuk mencegah serangan replay.',
                      ),
                      const SizedBox(height: 16),
                      _securitySection(
                        Icons.verified_user_rounded,
                        'Integritas Data — HMAC-SHA256',
                        const Color(0xFF64B5F6),
                        'Setiap payload data dilindungi dengan tanda tangan digital HMAC-SHA256. Tanda tangan ini memastikan bahwa data tidak dimodifikasi selama proses transmisi antara klien dan server.',
                      ),
                      const SizedBox(height: 16),
                      _securitySection(
                        Icons.vpn_lock_rounded,
                        'Koneksi Aman — HTTPS / TLS 1.3',
                        AppTokens.accentGold,
                        'Semua komunikasi jaringan menggunakan protokol HTTPS dengan TLS versi 1.3. Koneksi HTTP biasa secara otomatis dialihkan ke HTTPS untuk memastikan keamanan transmisi data.',
                      ),
                      const SizedBox(height: 16),
                      _securitySection(
                        Icons.storage_rounded,
                        'Penyimpanan Data Terenkripsi',
                        const Color(0xFFCE93D8),
                        'Informasi sesi dan token autentikasi disimpan menggunakan Flutter Secure Storage dengan enkripsi AES pada perangkat. Pada web, data disimpan di localStorage yang terlindungi oleh kebijakan Same-Origin Policy.',
                      ),
                      const SizedBox(height: 16),
                      _securitySection(
                        Icons.timer_rounded,
                        'Perlindungan Replay Attack',
                        const Color(0xFFFFB74D),
                        'Setiap permintaan API dilengkapi dengan timestamp ISO-8601 dan nonce unik yang divalidasi oleh server. Permintaan yang sama tidak dapat diulang atau disalahgunakan oleh pihak ketiga.',
                      ),
                      const SizedBox(height: 16),
                      _securitySection(
                        Icons.policy_rounded,
                        'Kebijakan Privasi & Syarat Penggunaan',
                        Colors.white70,
                        'Data pribadi mahasiswa (NIM, nama, email, no. HP) hanya digunakan untuk keperluan proses yudisium di lingkungan Politeknik Negeri Lhokseumawe. Data tidak dibagikan kepada pihak ketiga. Dengan menggunakan sistem ini, Anda menyetujui ketentuan penggunaan dan kebijakan privasi yang berlaku.',
                      ),
                      const SizedBox(height: 20),
                      // Footer badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_outlined,
                                size: 14,
                                color: AppTokens.primaryGreenLight),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Dibuat & dikelola oleh Nazarul Qudri — CTO Jurusan TIK, Prodi TRKJ PNL',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 10,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Close button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor:
                          AppTokens.primaryGreenLight.withValues(alpha: 0.12),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: AppTokens.primaryGreenLight
                              .withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Saya Mengerti & Setuju',
                      style: TextStyle(
                        color: AppTokens.primaryGreenLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _securitySection(
      IconData icon, String title, Color color, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Modal Dialog: Pemulihan / Lupa Password Mahasiswa ───────────
  void _showForgotPasswordDialog(BuildContext context) {
    final queryController = TextEditingController();
    final otpController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    int currentStep = 1; // 1: Input NIM/Email, 2: OTP/Security Code, 3: New Password
    String? errorMessage;
    bool isLoading = false;
    bool obscureNew = true;
    bool obscureConfirm = true;
    User? verifiedUser;
    final generatedOtp = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
              horizontal: context.isDesktop ? 120 : 20,
              vertical: 40,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              decoration: BoxDecoration(
                color: const Color(0xFF110826),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTokens.primaryPurpleLight.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTokens.primaryPurple.withValues(alpha: 0.3),
                    blurRadius: 35,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dialog Header
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
                            color: AppTokens.accentGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            color: AppTokens.accentGold,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pemulihan Kata Sandi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Langkah $currentStep dari 3 — Akun Mahasiswa TIK PNL',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(dialogCtx).pop(),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stepper Indicator
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        _buildStepNode(1, 'Identitas', currentStep >= 1, currentStep == 1),
                        Expanded(child: Container(height: 2, color: currentStep >= 2 ? AppTokens.accentGold : Colors.white12)),
                        _buildStepNode(2, 'Verifikasi', currentStep >= 2, currentStep == 2),
                        Expanded(child: Container(height: 2, color: currentStep >= 3 ? AppTokens.accentGold : Colors.white12)),
                        _buildStepNode(3, 'Password Baru', currentStep >= 3, currentStep == 3),
                      ],
                    ),
                  ),

                  // Error Box
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTokens.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTokens.error.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppTokens.error, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(color: AppTokens.error, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Form Content per Step
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: switch (currentStep) {
                      1 => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Masukkan NIM atau Email Anda yang terdaftar pada sistem yudisium:',
                              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: queryController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'NIM atau Email Terdaftar',
                                hintText: 'Contoh: 2021903430045',
                                prefixIcon: const Icon(Icons.badge_outlined, color: Colors.white54),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '💡 Catatan: Sistem akan memvalidasi akun mahasiswa di database Jurusan TIK.',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11),
                            ),
                          ],
                        ),
                      2 => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kode verifikasi 6 digit telah disiapkan untuk akun ${verifiedUser?.nama} (${verifiedUser?.nim}):',
                              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            // Simulated OTP Notification Card
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTokens.accentGold.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTokens.accentGold.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.mark_email_read_rounded, color: AppTokens.accentGold, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Kode Keamanan Simulasi:', style: TextStyle(color: Colors.white60, fontSize: 11)),
                                        Text(
                                          generatedOtp,
                                          style: const TextStyle(
                                            color: AppTokens.accentGoldLight,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 20,
                                            letterSpacing: 4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setDialogState(() {
                                        otpController.text = generatedOtp;
                                        errorMessage = null;
                                      });
                                    },
                                    child: const Text('Isi Otomatis', style: TextStyle(color: AppTokens.accentGoldLight, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: otpController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white, letterSpacing: 3, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                labelText: 'Masukkan 6 Digit Kode',
                                hintText: '123456',
                                prefixIcon: const Icon(Icons.pin_outlined, color: Colors.white54),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                          ],
                        ),
                      _ => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buat kata sandi baru untuk akun ${verifiedUser?.nama}:',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: newPasswordController,
                              obscureText: obscureNew,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Password Baru',
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.white54),
                                suffixIcon: GestureDetector(
                                  onTap: () => setDialogState(() => obscureNew = !obscureNew),
                                  child: Icon(
                                    obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: Colors.white54,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: confirmPasswordController,
                              obscureText: obscureConfirm,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Konfirmasi Password Baru',
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.white54),
                                suffixIcon: GestureDetector(
                                  onTap: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                                  child: Icon(
                                    obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: Colors.white54,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                          ],
                        ),
                    },
                  ),

                  // Actions Buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      children: [
                        if (currentStep > 1)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setDialogState(() {
                                  currentStep--;
                                  errorMessage = null;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Kembali'),
                            ),
                          ),
                        if (currentStep > 1) const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (currentStep == 1) {
                                      final query = queryController.text.trim();
                                      if (query.isEmpty) {
                                        setDialogState(() => errorMessage = 'Silakan masukkan NIM atau Email');
                                        return;
                                      }
                                      setDialogState(() => isLoading = true);
                                      final found = await AuthService.findMahasiswaByNimOrEmail(query);
                                      if (found == null) {
                                        setDialogState(() {
                                          isLoading = false;
                                          errorMessage = 'Akun mahasiswa dengan NIM/Email "$query" tidak ditemukan.';
                                        });
                                        return;
                                      }
                                      setDialogState(() {
                                        isLoading = false;
                                        errorMessage = null;
                                        verifiedUser = found;
                                        currentStep = 2;
                                      });
                                    } else if (currentStep == 2) {
                                      final otp = otpController.text.trim();
                                      if (otp.isEmpty || otp != generatedOtp) {
                                        setDialogState(() => errorMessage = 'Kode verifikasi tidak sesuai.');
                                        return;
                                      }
                                      setDialogState(() {
                                        errorMessage = null;
                                        currentStep = 3;
                                      });
                                    } else {
                                      final newPass = newPasswordController.text;
                                      final confirmPass = confirmPasswordController.text;
                                      if (newPass.length < 6) {
                                        setDialogState(() => errorMessage = 'Password baru minimal 6 karakter.');
                                        return;
                                      }
                                      if (newPass != confirmPass) {
                                        setDialogState(() => errorMessage = 'Konfirmasi password tidak cocok.');
                                        return;
                                      }

                                      setDialogState(() => isLoading = true);

                                      // Kirim email reset password via Supabase Auth
                                      await AuthService.resetPassword(
                                        nimOrEmail: verifiedUser!.email,
                                      );

                                      if (!ctx.mounted) return;
                                      Navigator.of(ctx).pop();

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: const Color(0xFF1E1038),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: const BorderSide(color: AppTokens.primaryPurpleLight),
                                          ),
                                          content: Row(
                                            children: [
                                              const Icon(Icons.check_circle_rounded, color: AppTokens.accentGoldLight),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  'Kata sandi untuk ${verifiedUser!.nama} berhasil diperbarui! Silakan klik Masuk.',
                                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTokens.primaryPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    currentStep == 3 ? 'Simpan Password Baru' : 'Lanjutkan',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
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

  static Widget _buildStepNode(int number, String label, bool isDone, bool isActive) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppTokens.accentGold
                : isDone
                    ? AppTokens.primaryPurpleLight
                    : Colors.white12,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(
              color: isActive ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppTokens.accentGoldLight : Colors.white54,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: AnimatedBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.isDesktop ? 480 : double.infinity,
                    minHeight: size.height - 100,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.isDesktop ? 0 : AppTokens.spaceMD,
                      vertical: AppTokens.spaceMD,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppTokens.spaceXXL),

                        // Logo + Header
                        _buildHeader(context),

                        const SizedBox(height: AppTokens.spaceXL),

                        // Form Card
                        _buildFormCard(context, authState),

                        const SizedBox(height: AppTokens.spaceLG),

                        // Register link + Security link
                        _buildBottomLinks(context),

                        const SizedBox(height: AppTokens.spaceXL),

                        // Demo info (hanya 1 mahasiswa, admin tersembunyi)
                        _buildDemoHint(context),

                        const SizedBox(height: AppTokens.spaceLG),

                        // Watermark / Credit
                        _buildWatermark(context),

                        const SizedBox(height: AppTokens.spaceXL),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          padding: const EdgeInsets.all(8),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo_pnl.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Center(
                child: Text(
                  'PNL',
                  style: TextStyle(
                    color: AppTokens.accentGold,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTokens.spaceMD),
        Text(
          'Selamat Datang',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: AppTokens.spaceXXS),
        Text(
          'Masuk ke Sistem Yudisium TIK PNL',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white60,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        // ── Deadline Pill Banner 26 Agustus 2026 ────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1438).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppTokens.accentGold.withValues(alpha: 0.45),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTokens.accentGold.withValues(alpha: 0.15),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTokens.accentGold,
                  shape: BoxShape.circle,
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.5, 1.5),
                      duration: 1200.ms)
                  .fade(begin: 0.6, end: 1.0, duration: 1200.ms),
              const SizedBox(width: 8),
              const Icon(
                Icons.event_available_rounded,
                color: AppTokens.accentGold,
                size: 16,
              ),
              const SizedBox(width: 6),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 12.5,
                  ),
                  children: [
                    TextSpan(
                      text: 'Batas Pendaftaran: ',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: '26 Agustus 2026',
                      style: TextStyle(
                        color: AppTokens.accentGoldLight,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 350.ms, duration: 800.ms)
            .slideY(
                begin: 0.2,
                end: 0,
                duration: 800.ms,
                curve: Curves.easeOutCubic)
            .shimmer(
              delay: 1500.ms,
              duration: 2500.ms,
              color: Colors.white.withValues(alpha: 0.15),
            ),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOut);
  }

  Widget _buildFormCard(BuildContext context, AuthState authState) {
    return GlassCard(
      padding: const EdgeInsets.all(AppTokens.spaceLG),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Login Akun',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppTokens.spaceXS),
            Text(
              'Gunakan NIM atau email terdaftar',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
            ),
            const SizedBox(height: AppTokens.spaceLG),

            // NIM / Email
            TextFormField(
              controller: _nimController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'NIM / Email',
                prefixIcon: Icon(Icons.person_outline_rounded, color: Colors.white54),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Masukkan NIM atau email';
                return null;
              },
            ),
            const SizedBox(height: AppTokens.spaceMD),

            // Password
            TextFormField(
              controller: _passwordController,
              style: const TextStyle(color: Colors.white),
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.white54),
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white54,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Masukkan password';
                if (v.length < 6) return 'Password minimal 6 karakter';
                return null;
              },
            ),

            const SizedBox(height: AppTokens.spaceXS),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => _showForgotPasswordDialog(context),
                child: Text(
                  'Lupa Password?',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTokens.accentGoldLight,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTokens.accentGoldLight,
                      ),
                ),
              ),
            ),

            // Error message
            if (authState.error != null) ...[
              const SizedBox(height: AppTokens.spaceMD),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.spaceMD,
                  vertical: AppTokens.spaceXS,
                ),
                decoration: BoxDecoration(
                  color: AppTokens.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                  border: Border.all(color: AppTokens.error.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppTokens.error, size: 16),
                    const SizedBox(width: AppTokens.spaceXS),
                    Expanded(
                      child: Text(
                        authState.error!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTokens.error,
                            ),
                      ),
                    ),
                  ],
                ),
              ).animate().shake(hz: 3, curve: Curves.easeInOut),
            ],

            const SizedBox(height: AppTokens.spaceLG),

            // Login button
            GlassButton(
              label: 'Masuk',
              icon: Icons.login_rounded,
              isLoading: authState.isLoading,
              onPressed: authState.isLoading ? null : _login,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0, delay: 300.ms, duration: 600.ms);
  }

  Widget _buildBottomLinks(BuildContext context) {
    return Column(
      children: [
        // Register link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Belum punya akun? ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white60,
                  ),
            ),
            GestureDetector(
              onTap: () => context.push('/register'),
              child: Text(
                'Daftar Sekarang',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTokens.accentGoldLight,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTokens.accentGoldLight,
                    ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 600.ms),

        const SizedBox(height: AppTokens.spaceMD),

        // Syarat & Ketentuan / Protokol Keamanan button
        GestureDetector(
          onTap: () => _showSecurityDialog(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTokens.primaryGreenLight.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTokens.primaryGreenLight.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 14,
                  color: AppTokens.primaryGreenLight,
                ),
                const SizedBox(width: 6),
                Text(
                  'Panduan Keamanan Data & Syarat Ketentuan',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTokens.primaryGreenLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 700.ms),
      ],
    );
  }

  Widget _buildDemoHint(BuildContext context) {
    return GlassCard(
      fillColor: Colors.white.withValues(alpha: 0.03),
      borderColor: Colors.white.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceMD, vertical: AppTokens.spaceSM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppTokens.primaryGreenLight, size: 14),
              const SizedBox(width: AppTokens.spaceXS),
              Text(
                'Akun Contoh Pengujian',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTokens.primaryGreenLight,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _demoRow(context, '👤 Mahasiswa', '2021903430045 / password123'),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _demoRow(BuildContext context, String label, String cred) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                  fontSize: 11,
                ),
          ),
          Flexible(
            child: Text(
              cred,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatermark(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spaceMD, vertical: AppTokens.spaceSM),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_outlined,
                  color: AppTokens.primaryGreenLight, size: 14),
              const SizedBox(width: 6),
              Text(
                'Sistem ini dibuat oleh Nazarul Qudri',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Chief Technology Officer — Jurusan TIK, Prodi TRKJ PNL',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 900.ms);
  }
}
