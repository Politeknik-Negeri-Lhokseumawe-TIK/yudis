import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../../domain/user_model.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_button.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/responsive/breakpoints.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nimController = TextEditingController();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  ProgramStudi _selectedProdi = ProgramStudi.trkj;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nimController.dispose();
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref.read(authProvider.notifier).register(
          nim: _nimController.text,
          nama: _namaController.text,
          email: _emailController.text,
          password: _passwordController.text,
          programStudi: _selectedProdi,
          noHp: _noHpController.text,
        );

    if (!mounted) return;
    if (success) {
      context.go('/mahasiswa/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

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
                    maxWidth: context.isDesktop ? 560 : double.infinity,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.isDesktop ? 0 : AppTokens.spaceMD,
                      vertical: AppTokens.spaceMD,
                    ),
                    child: Column(
                      children: [
                        // Header
                        _buildHeader(context),
                        const SizedBox(height: AppTokens.spaceLG),

                        // Form
                        _buildForm(context, authState),

                        const SizedBox(height: AppTokens.spaceMD),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sudah punya akun? ',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white60,
                                  ),
                            ),
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Text(
                                'Masuk',
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

                        const SizedBox(height: AppTokens.spaceLG),

                        // Watermark / Credit
                        _buildWatermark(context),

                        const SizedBox(height: AppTokens.spaceMD),
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
    ).animate().fadeIn(delay: 700.ms);
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            padding: const EdgeInsets.all(AppTokens.spaceXS),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTokens.radiusSM),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 16),
          ),
        ),
        const SizedBox(width: AppTokens.spaceMD),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buat Akun',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              'Registrasi Akun SIM-LAB TIK PNL',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildForm(BuildContext context, AuthState authState) {
    return GlassCard(
      padding: const EdgeInsets.all(AppTokens.spaceLG),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // NIM
            _buildField(
              controller: _nimController,
              label: 'NIM',
              icon: Icons.badge_outlined,
              hint: 'Contoh: 2022903430028',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Masukkan NIM';
                if (v.trim().length < 8) return 'NIM minimal 8 digit';
                return null;
              },
            ),
            const SizedBox(height: AppTokens.spaceMD),

            // Nama Lengkap
            _buildField(
              controller: _namaController,
              label: 'Nama Lengkap',
              icon: Icons.person_outline_rounded,
              hint: 'Sesuai KTP/ijazah',
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Masukkan nama lengkap';
                if (v.trim().length < 3) return 'Nama terlalu pendek';
                return null;
              },
            ),
            const SizedBox(height: AppTokens.spaceMD),

            // Email
            _buildField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              hint: 'nama.kamu@gmail.com',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Masukkan email';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTokens.spaceMD),

            // No HP
            _buildField(
              controller: _noHpController,
              label: 'No. HP / WhatsApp',
              icon: Icons.phone_outlined,
              hint: '08xxxxxxxxxx',
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Masukkan no. HP';
                if (v.trim().length < 10) return 'No. HP tidak valid';
                return null;
              },
            ),
            const SizedBox(height: AppTokens.spaceMD),

            // Program Studi Dropdown
            DropdownButtonFormField<ProgramStudi>(
              initialValue: _selectedProdi,
              decoration: const InputDecoration(
                labelText: 'Program Studi',
                prefixIcon: Icon(Icons.school_outlined, color: Colors.white54),
              ),
              dropdownColor: AppTokens.bgDarkCard,
              style: const TextStyle(color: Colors.white),
              iconEnabledColor: Colors.white54,
              items: ProgramStudi.values.map((prodi) {
                return DropdownMenuItem(
                  value: prodi,
                  child: Text(prodi.label, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedProdi = v);
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
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
            const SizedBox(height: AppTokens.spaceMD),

            // Konfirmasi Password
            TextFormField(
              controller: _confirmController,
              style: const TextStyle(color: Colors.white),
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.white54),
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  child: Icon(
                    _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.white54,
                  ),
                ),
              ),
              validator: (v) {
                if (v != _passwordController.text) return 'Password tidak cocok';
                return null;
              },
            ),

            // Error
            if (authState.error != null) ...[
              const SizedBox(height: AppTokens.spaceMD),
              Container(
                padding: const EdgeInsets.all(AppTokens.spaceSM),
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
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppTokens.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppTokens.spaceLG),

            GlassButton(
              label: 'Daftar Sekarang',
              icon: Icons.how_to_reg_rounded,
              isLoading: authState.isLoading,
              onPressed: authState.isLoading ? null : _register,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.white54),
      ),
      validator: validator,
    );
  }
}
