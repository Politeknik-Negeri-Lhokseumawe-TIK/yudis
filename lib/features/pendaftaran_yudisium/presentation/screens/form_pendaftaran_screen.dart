import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../domain/pendaftaran_model.dart';
import '../../presentation/providers/pendaftaran_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/user_model.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/glass_button.dart';
import '../../../../shared/widgets/sidebar_aware_scaffold.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_tokens.dart';
import '../widgets/upload_dokumen_tile.dart';

class FormPendaftaranScreen extends ConsumerStatefulWidget {
  const FormPendaftaranScreen({super.key});

  @override
  ConsumerState<FormPendaftaranScreen> createState() =>
      _FormPendaftaranScreenState();
}

class _FormPendaftaranScreenState extends ConsumerState<FormPendaftaranScreen> {
  // Step 1 data
  final _step1Key = GlobalKey<FormState>();
  final _ipkController = TextEditingController(text: '3.50');
  final _sksController = TextEditingController(text: '144');
  final _semesterController = TextEditingController(text: '8');
  Jenjang _jenjang = Jenjang.d4;
  bool _tinggalDiAsrama = false;

  // Step 4 data (biodata)
  final _step4Key = GlobalKey<FormState>();
  final _tempatLahirCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _namaAyahCtrl = TextEditingController();
  final _namaIbuCtrl = TextEditingController();
  final _judulTgaCtrl = TextEditingController();
  final _pembimbing1Ctrl = TextEditingController();
  final _pembimbing2Ctrl = TextEditingController();
  DateTime? _tanggalLahir;
  String _jenisKelamin = 'Laki-laki';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = ref.read(pendaftaranProvider).pendaftaran;
      if (p != null) {
        _ipkController.text = p.ipk > 0 ? p.ipk.toStringAsFixed(2) : '3.50';
        _sksController.text = p.totalSks > 0 ? p.totalSks.toString() : '144';
        _semesterController.text = p.semester > 0 ? p.semester.toString() : '8';
        setState(() {
          _jenjang = p.jenjang;
          _tinggalDiAsrama = p.tinggalDiAsrama;
        });
      }
    });
  }

  @override
  void dispose() {
    _ipkController.dispose();
    _sksController.dispose();
    _semesterController.dispose();
    _tempatLahirCtrl.dispose();
    _alamatCtrl.dispose();
    _namaAyahCtrl.dispose();
    _namaIbuCtrl.dispose();
    _judulTgaCtrl.dispose();
    _pembimbing1Ctrl.dispose();
    _pembimbing2Ctrl.dispose();
    super.dispose();
  }

  int get _currentStep => ref.read(pendaftaranProvider).currentStep;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pendaftaranProvider);
    final user = ref.watch(currentUserProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SidebarAwareScaffold(
        location: '/mahasiswa/daftar',
        mobileAppBar: const GlassAppBar(title: 'Pendaftaran Yudisium'),
        body: AnimatedBackground(
          child: SafeArea(
            top: !context.isDesktop && !context.isTablet,
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                children: [
                  // Step indicator
                  _buildStepIndicator(state.currentStep),

                  // Body — Expanded works karena constraints bounded dari LayoutBuilder
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: AppTokens.durationNormal,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: _buildStep(state, user, key: ValueKey(state.currentStep)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    final steps = ['Data\nAkademik', 'Dokumen\n1-6', 'Dokumen\n7-12', 'Biodata', 'Review'];
    final hasDraft = ref.watch(pendaftaranProvider).pendaftaran != null;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spaceMD, vertical: AppTokens.spaceXS),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(
              child: Container(
                height: 2,
                color: i ~/ 2 < currentStep ? AppTokens.primaryGreenLight : Colors.white12,
              ),
            );
          }
          final idx = i ~/ 2;
          final isCompleted = idx < currentStep;
          final isCurrent = idx == currentStep;
          final canTap = hasDraft || idx <= currentStep;

          return InkWell(
            onTap: canTap
                ? () => ref.read(pendaftaranProvider.notifier).setStep(idx)
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppTokens.primaryGreenLight
                          : isCurrent
                              ? AppTokens.primaryGreenLight.withValues(alpha: 0.2)
                              : Colors.white10,
                      border: Border.all(
                        color: isCompleted || isCurrent
                            ? AppTokens.primaryGreenLight
                            : Colors.white24,
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                        : Center(
                            child: Text(
                              '${idx + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isCurrent
                                    ? AppTokens.primaryGreenLight
                                    : Colors.white24,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    steps[idx],
                    style: TextStyle(
                      fontSize: 9,
                      color: isCompleted || isCurrent ? Colors.white60 : Colors.white24,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep(PendaftaranState state, User? user, {required Key key}) {
    return switch (state.currentStep) {
      0 => _buildStep0DataAkademik(user, key: key),
      1 => _buildStep1Dokumen(state, startIndex: 0, endIndex: 6, key: key),
      2 => _buildStep1Dokumen(state, startIndex: 6, endIndex: 12, key: key),
      3 => _buildStep3Biodata(key: key),
      4 => _buildStep4Review(state, key: key),
      _ => const SizedBox.shrink(),
    };
  }

  // ── Step 0: Data Akademik ─────────────────────────────────────
  Widget _buildStep0DataAkademik(User? user, {required Key key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(AppTokens.spaceMD),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Data Akademik', Icons.school_outlined),
            const SizedBox(height: AppTokens.spaceMD),
            GlassCard(
              padding: const EdgeInsets.all(AppTokens.spaceLG),
              child: Column(
                children: [
                  // Jenjang
                  Row(
                    children: Jenjang.values.map((j) {
                      final selected = _jenjang == j;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _jenjang = j),
                          child: AnimatedContainer(
                            duration: AppTokens.durationFast,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppTokens.primaryGreenLight.withValues(alpha: 0.2)
                                  : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                              border: Border.all(
                                color: selected
                                    ? AppTokens.primaryGreenLight
                                    : Colors.white24,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  j.value,
                                  style: TextStyle(
                                    color: selected
                                        ? AppTokens.primaryGreenLight
                                        : Colors.white54,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  j.label,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white70
                                        : Colors.white38,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppTokens.spaceMD),
                  _numField(label: 'IPK (0.00 – 4.00)', controller: _ipkController,
                      hint: '3.50', isMandatory: true, isDecimal: true,
                      validator: (v) {
                        final ipk = double.tryParse(v ?? '');
                        if (ipk == null) return 'Masukkan IPK valid';
                        if (ipk < 0 || ipk > 4) return 'IPK antara 0 - 4.00';
                        return null;
                      }),
                  const SizedBox(height: AppTokens.spaceMD),
                  _numField(label: 'Total SKS Lulus', controller: _sksController,
                      hint: '144', isMandatory: true,
                      validator: (v) {
                        final sks = int.tryParse(v ?? '');
                        if (sks == null) return 'Masukkan SKS valid';
                        if (sks < 100) return 'SKS minimal 100';
                        return null;
                      }),
                  const SizedBox(height: AppTokens.spaceMD),
                  _numField(label: 'Semester', controller: _semesterController,
                      hint: '8', isMandatory: true,
                      validator: (v) {
                        final s = int.tryParse(v ?? '');
                        if (s == null) return 'Masukkan semester valid';
                        if (s < 6 || s > 16) return 'Semester antara 6 - 16';
                        return null;
                      }),
                  const SizedBox(height: AppTokens.spaceMD),
                  // Asrama toggle
                  GlassCard(
                    fillColor: _tinggalDiAsrama
                        ? AppTokens.info.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.03),
                    borderColor: _tinggalDiAsrama
                        ? AppTokens.info.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.spaceMD, vertical: AppTokens.spaceXS),
                    child: Row(
                      children: [
                        const Icon(Icons.home_outlined, color: Colors.white54, size: 20),
                        const SizedBox(width: AppTokens.spaceSM),
                        Expanded(
                          child: Text(
                            'Tinggal di Asrama PNL',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ),
                        Switch(
                          value: _tinggalDiAsrama,
                          onChanged: (v) => setState(() => _tinggalDiAsrama = v),
                          activeThumbColor: AppTokens.info,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.spaceLG),
            GlassButton(
              label: 'Selanjutnya',
              icon: Icons.arrow_forward_rounded,
              isLoading: ref.watch(pendaftaranProvider).isLoading,
              onPressed: ref.watch(pendaftaranProvider).isLoading
                  ? null
                  : _onStep0Next,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Future<void> _onStep0Next() async {
    if (!_step1Key.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await ref.read(pendaftaranProvider.notifier).mulaiPendaftaran(
          userId: user.id,
          programStudi: user.programStudi,
          jenjang: _jenjang,
          ipk: double.parse(_ipkController.text),
          totalSks: int.parse(_sksController.text),
          semester: int.parse(_semesterController.text),
          tinggalDiAsrama: _tinggalDiAsrama,
        );

    final state = ref.read(pendaftaranProvider);
    if (state.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF2E1020),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppTokens.error, width: 1.5),
          ),
          content: Text(
            state.error!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  // ── Step 1 & 2: Dokumen ───────────────────────────────────────
  Widget _buildStep1Dokumen(PendaftaranState state,
      {required int startIndex, required int endIndex, required Key key}) {
    final p = state.pendaftaran;
    if (p == null) {
      return Center(
        child: Text(
          'Silakan isi data akademik terlebih dahulu',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54),
        ),
      );
    }

    final applicable = p.dokumenApplicable;
    final docs = applicable
        .skip(startIndex)
        .take(endIndex - startIndex)
        .toList();

    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(AppTokens.spaceMD),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Upload Dokumen (${startIndex + 1} – $endIndex)',
              Icons.upload_file_rounded),
          const SizedBox(height: AppTokens.spaceXS),
          Text(
            'Format: PDF / JPG / PNG. Ukuran max 5MB per file.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white38),
          ),
          const SizedBox(height: AppTokens.spaceMD),
          ...docs.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.spaceMD),
                child: UploadDokumenTile(dokumen: e.value),
              )),
          const SizedBox(height: AppTokens.spaceMD),
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  label: 'Kembali',
                  icon: Icons.arrow_back_rounded,
                  variant: GlassButtonVariant.outlined,
                  onPressed: () => ref
                      .read(pendaftaranProvider.notifier)
                      .setStep(state.currentStep - 1),
                ),
              ),
              const SizedBox(width: AppTokens.spaceMD),
              Expanded(
                child: GlassButton(
                  label: 'Selanjutnya',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => ref
                      .read(pendaftaranProvider.notifier)
                      .setStep(state.currentStep + 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceXL),
        ],
      ),
    );
  }

  // ── Step 3: Biodata ───────────────────────────────────────────
  Widget _buildStep3Biodata({required Key key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(AppTokens.spaceMD),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _step4Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Biodata Calon Yudisium', Icons.person_outline_rounded),
            const SizedBox(height: AppTokens.spaceMD),
            GlassCard(
              padding: const EdgeInsets.all(AppTokens.spaceLG),
              child: Column(
                children: [
                  _textField(label: 'Tempat Lahir', controller: _tempatLahirCtrl,
                      icon: Icons.location_on_outlined),
                  const SizedBox(height: AppTokens.spaceMD),
                  // Tanggal lahir
                  GestureDetector(
                    onTap: _pickTanggalLahir,
                    child: AbsorbPointer(
                      child: TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Tanggal Lahir',
                          prefixIcon: const Icon(Icons.calendar_today_outlined,
                              color: Colors.white54),
                          hintText: _tanggalLahir != null
                              ? DateFormat('d MMMM yyyy').format(_tanggalLahir!)
                              : 'Pilih tanggal',
                        ),
                        controller: TextEditingController(
                          text: _tanggalLahir != null
                              ? DateFormat('d MMMM yyyy').format(_tanggalLahir!)
                              : '',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTokens.spaceMD),
                  // Jenis kelamin
                  DropdownButtonFormField<String>(
                    initialValue: _jenisKelamin,
                    dropdownColor: AppTokens.bgDarkCard,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Jenis Kelamin',
                      prefixIcon: Icon(Icons.wc_outlined, color: Colors.white54),
                    ),
                    items: ['Laki-laki', 'Perempuan']
                        .map((g) => DropdownMenuItem(
                              value: g,
                              child: Text(g, style: const TextStyle(color: Colors.white)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _jenisKelamin = v!),
                  ),
                  const SizedBox(height: AppTokens.spaceMD),
                  _textField(label: 'Alamat Lengkap', controller: _alamatCtrl,
                      icon: Icons.home_outlined, maxLines: 2),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.spaceMD),
            _sectionTitle('Data Orang Tua', Icons.family_restroom_rounded),
            const SizedBox(height: AppTokens.spaceMD),
            GlassCard(
              padding: const EdgeInsets.all(AppTokens.spaceLG),
              child: Column(
                children: [
                  _textField(label: 'Nama Ayah', controller: _namaAyahCtrl,
                      icon: Icons.person_outline_rounded),
                  const SizedBox(height: AppTokens.spaceMD),
                  _textField(label: 'Nama Ibu', controller: _namaIbuCtrl,
                      icon: Icons.person_outline_rounded),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.spaceMD),
            _sectionTitle('Data Tugas Akhir', Icons.article_outlined),
            const SizedBox(height: AppTokens.spaceMD),
            GlassCard(
              padding: const EdgeInsets.all(AppTokens.spaceLG),
              child: Column(
                children: [
                  _textField(label: 'Judul TGA / Skripsi', controller: _judulTgaCtrl,
                      icon: Icons.title_rounded, maxLines: 2, isRequired: true),
                  const SizedBox(height: AppTokens.spaceMD),
                  _textField(label: 'Nama Pembimbing 1', controller: _pembimbing1Ctrl,
                      icon: Icons.person_pin_outlined, isRequired: true),
                  const SizedBox(height: AppTokens.spaceMD),
                  _textField(label: 'Nama Pembimbing 2 (jika ada)',
                      controller: _pembimbing2Ctrl,
                      icon: Icons.person_pin_outlined),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.spaceLG),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    label: 'Kembali',
                    icon: Icons.arrow_back_rounded,
                    variant: GlassButtonVariant.outlined,
                    onPressed: () => ref
                        .read(pendaftaranProvider.notifier)
                        .setStep(_currentStep - 1),
                  ),
                ),
                const SizedBox(width: AppTokens.spaceMD),
                Expanded(
                  child: GlassButton(
                    label: 'Selanjutnya',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _onStep3Next,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spaceXL),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  void _onStep3Next() {
    if (!_step4Key.currentState!.validate()) return;
    final biodata = BiodataCalon(
      tempatLahir: _tempatLahirCtrl.text,
      tanggalLahir: _tanggalLahir,
      jenisKelamin: _jenisKelamin,
      alamat: _alamatCtrl.text,
      namaAyah: _namaAyahCtrl.text,
      namaIbu: _namaIbuCtrl.text,
      judulTga: _judulTgaCtrl.text,
      pembimbing1: _pembimbing1Ctrl.text,
      pembimbing2: _pembimbing2Ctrl.text.isEmpty ? null : _pembimbing2Ctrl.text,
    );
    ref.read(pendaftaranProvider.notifier).updateBiodata(biodata);
    ref.read(pendaftaranProvider.notifier).setStep(4);
  }

  Future<void> _pickTanggalLahir() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1970),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 17)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTokens.primaryGreenLight,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tanggalLahir = picked);
  }

  // ── Step 4: Review ────────────────────────────────────────────
  Widget _buildStep4Review(PendaftaranState state, {required Key key}) {
    final p = state.pendaftaran;
    if (p == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(AppTokens.spaceMD),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Review & Konfirmasi', Icons.preview_rounded),
          const SizedBox(height: AppTokens.spaceMD),

          // Ringkasan data
          GlassCard(
            padding: const EdgeInsets.all(AppTokens.spaceLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _reviewRow('Jenjang', p.jenjang.label),
                _reviewRow('IPK', p.ipk.toStringAsFixed(2)),
                _reviewRow('Total SKS', '${p.totalSks} SKS'),
                _reviewRow('Semester', 'Semester ${p.semester}'),
                _reviewRow('Asrama', p.tinggalDiAsrama ? 'Ya' : 'Tidak'),
                if (p.biodata.judulTga != null && p.biodata.judulTga!.isNotEmpty)
                  _reviewRow('Judul TGA', p.biodata.judulTga!),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.spaceMD),

          // Dokumen summary
          GlassCard(
            padding: const EdgeInsets.all(AppTokens.spaceMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dokumen: ${p.dokumenTerUpload}/${p.totalDokumenWajib} diupload',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: AppTokens.spaceXS),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTokens.radiusCircle),
                  child: LinearProgressIndicator(
                    value: p.uploadProgress,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTokens.primaryGreenLight),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.spaceLG),

          // Submit
          if (state.submitSuccess)
            GlassCard(
              fillColor: AppTokens.success.withValues(alpha: 0.1),
              borderColor: AppTokens.success.withValues(alpha: 0.4),
              padding: const EdgeInsets.all(AppTokens.spaceLG),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppTokens.success, size: 48),
                  const SizedBox(height: AppTokens.spaceMD),
                  Text(
                    'Pendaftaran Berhasil!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTokens.success,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AppTokens.spaceXS),
                  Text(
                    'Pendaftaranmu telah diajukan. Pantau status di dashboard.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white60),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTokens.spaceLG),
                  GlassButton(
                    label: 'Kembali ke Dashboard',
                    icon: Icons.home_rounded,
                    onPressed: () => context.go('/mahasiswa/dashboard'),
                  ),
                ],
              ),
            ).animate().fadeIn().scale()
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        label: 'Kembali',
                        icon: Icons.arrow_back_rounded,
                        variant: GlassButtonVariant.outlined,
                        onPressed: () => ref
                            .read(pendaftaranProvider.notifier)
                            .setStep(3),
                      ),
                    ),
                    const SizedBox(width: AppTokens.spaceMD),
                    Expanded(
                      child: GlassButton(
                        label: 'Ajukan',
                        icon: Icons.send_rounded,
                        color: AppTokens.success,
                        isLoading: state.isSubmitting,
                        onPressed: state.isSubmitting ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: AppTokens.spaceXL),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Future<void> _submit() async {
    await ref.read(pendaftaranProvider.notifier).submit();
  }

  // ── Helpers ───────────────────────────────────────────────────
  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTokens.accentGold, size: 20),
        const SizedBox(width: AppTokens.spaceXS),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }

  Widget _numField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool isMandatory = false,
    bool isDecimal = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType:
          isDecimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
      inputFormatters: isDecimal
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
          : [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: validator,
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white54),
      ),
      validator: isRequired
          ? (v) => (v == null || v.trim().isEmpty) ? 'Field ini wajib diisi' : null
          : null,
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.spaceXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white38),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
