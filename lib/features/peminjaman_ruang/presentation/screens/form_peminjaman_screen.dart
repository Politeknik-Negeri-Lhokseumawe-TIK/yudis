import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/cyber_button.dart';
import '../../../../shared/widgets/cyber_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';
import '../providers/booking_provider.dart';
import '../providers/roster_provider.dart';

class FormPeminjamanScreen extends ConsumerStatefulWidget {
  final String? prefillRoom;
  final String? prefillDay;
  final int? prefillSession;

  const FormPeminjamanScreen({
    super.key,
    this.prefillRoom,
    this.prefillDay,
    this.prefillSession,
  });

  @override
  ConsumerState<FormPeminjamanScreen> createState() =>
      _FormPeminjamanScreenState();
}

class _FormPeminjamanScreenState extends ConsumerState<FormPeminjamanScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedRoomCode;
  late DateTime _selectedDate;
  late int _startSession;
  late int _endSession;
  String _selectedPurpose = AppConstants.bookingPurposes.first;
  String _userRole = 'Mahasiswa';

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _nimNipCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _supervisorCtrl = TextEditingController();

  final List<String> _selectedFacilities = [];
  ConflictCheckResult? _conflictResult;
  bool _isLoading = false;
  int _currentStep = 1; // 1: Ruangan & Waktu, 2: Identitas Pemohon, 3: Fasilitas & Konfirmasi

  @override
  void initState() {
    super.initState();
    _selectedRoomCode = widget.prefillRoom ?? 'TIK.101';
    _selectedDate = DateTime.now();
    _startSession = widget.prefillSession ?? 1;
    _endSession = widget.prefillSession != null ? (widget.prefillSession! + 1).clamp(1, 11) : 3;

    // Prefill from current auth user if available
    final authState = ref.read(authProvider);
    _nameCtrl.text = authState.user?.nama ?? '';
    _nimNipCtrl.text = authState.user?.nim ?? '';
    _phoneCtrl.text = authState.user?.noHp ?? '';
    _supervisorCtrl.text = '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runConflictCheck();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nimNipCtrl.dispose();
    _phoneCtrl.dispose();
    _descCtrl.dispose();
    _supervisorCtrl.dispose();
    super.dispose();
  }

  String _getDayName(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return 'Senin';
    }
  }

  void _runConflictCheck() {
    final day = _getDayName(_selectedDate);
    final result = ref.read(bookingListProvider.notifier).checkConflict(
          roomCode: _selectedRoomCode,
          day: day,
          startSession: _startSession,
          endSession: _endSession,
          date: _selectedDate,
        );
    setState(() {
      _conflictResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allRooms = ref.watch(roomsProvider);
    final selectedRoom = allRooms.firstWhere(
      (r) => r.id == _selectedRoomCode,
      orElse: () => allRooms.first,
    );

    final startSlot = AppConstants.timeSlots.firstWhere(
      (s) => s['session'] == _startSession,
      orElse: () => AppConstants.timeSlots.first,
    );
    final endSlot = AppConstants.timeSlots.firstWhere(
      (s) => s['session'] == _endSession,
      orElse: () => AppConstants.timeSlots.last,
    );

    final hasConflict = _conflictResult?.hasConflict ?? false;

    return Scaffold(
      backgroundColor: AppTokens.bgDark,
      appBar: AppBar(
        backgroundColor: AppTokens.bgDarkSurface,
        title: const Text(
          'Formulir Peminjaman Ruang',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Step Progress Indicator ──────────────────────────────
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTokens.bgDarkSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTokens.glassBorderColor),
              ),
              child: Row(
                children: [
                  _buildWizardStepNode(1, 'Ruang & Waktu', _currentStep >= 1, _currentStep == 1),
                  Expanded(child: Container(height: 2, color: _currentStep >= 2 ? AppTokens.primaryPurpleGlow : Colors.white12)),
                  _buildWizardStepNode(2, 'Pemohon', _currentStep >= 2, _currentStep == 2),
                  Expanded(child: Container(height: 2, color: _currentStep >= 3 ? AppTokens.primaryPurpleGlow : Colors.white12)),
                  _buildWizardStepNode(3, 'Review & Kirim', _currentStep >= 3, _currentStep == 3),
                ],
              ),
            ),

            // ── Conflict Check Banner ─────────────────────────────────
            if (_conflictResult != null && _currentStep == 1)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: hasConflict
                      ? AppTokens.error.withValues(alpha: 0.15)
                      : AppTokens.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasConflict ? AppTokens.error : AppTokens.success,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      hasConflict
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_rounded,
                      color: hasConflict ? AppTokens.error : AppTokens.success,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasConflict
                                ? 'Jadwal Bentrok Terdeteksi!'
                                : 'Slot Waktu Ruangan Tersedia (Valid)',
                            style: TextStyle(
                              color: hasConflict ? AppTokens.error : AppTokens.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasConflict
                                ? _conflictResult!.message
                                : 'Tidak ada perkuliahan reguler atau peminjaman lain pada ${_getDayName(_selectedDate)}, Sesi $_startSession-$_endSession (${startSlot['start']} - ${endSlot['end']}).',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 200.ms),

            if (_currentStep == 1) ...[
              // ── Section 1: Pemilihan Ruangan & Waktu ──────────────────
            CyberCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.meeting_room_rounded, color: AppTokens.primaryPurpleGlow, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Pilih Ruangan / Laboratorium',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Room Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRoomCode,
                      dropdownColor: AppTokens.bgDarkCard,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Ruangan / Lab',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: AppTokens.bgDarkSurface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: Icon(
                          selectedRoom.isLab
                              ? Icons.laptop_chromebook_rounded
                              : Icons.meeting_room_rounded,
                          color: AppTokens.primaryPurpleGlow,
                        ),
                      ),
                      items: allRooms.map((r) {
                        return DropdownMenuItem(
                          value: r.id,
                          child: Text('${r.id} - ${r.name} (Lt.${r.floor})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedRoomCode = val);
                          _runConflictCheck();
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Date Picker
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppTokens.primaryPurple,
                                  onPrimary: Colors.white,
                                  surface: AppTokens.bgDarkCard,
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                          _runConflictCheck();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTokens.bgDarkSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTokens.glassBorderColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 18, color: AppTokens.accentGold),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tanggal Peminjaman', style: TextStyle(color: Colors.white54, fontSize: 10)),
                                Text(
                                  '${_getDayName(_selectedDate)}, ${DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.edit_calendar_rounded, size: 18, color: Colors.white54),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Sesi Jam (Start & End)
                    Row(
                      children: [
                        // Sesi Mulai
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: _startSession,
                            dropdownColor: AppTokens.bgDarkCard,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            decoration: InputDecoration(
                              labelText: 'Sesi Mulai',
                              labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                              filled: true,
                              fillColor: AppTokens.bgDarkSurface,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            items: List.generate(11, (i) => i + 1).map((s) {
                              final slot = AppConstants.timeSlots.firstWhere((ts) => ts['session'] == s);
                              return DropdownMenuItem(
                                value: s,
                                child: Text('Sesi $s (${slot['start']})'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _startSession = val;
                                  if (_endSession < _startSession) _endSession = _startSession;
                                });
                                _runConflictCheck();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Sesi Selesai
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: _endSession,
                            dropdownColor: AppTokens.bgDarkCard,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            decoration: InputDecoration(
                              labelText: 'Sesi Selesai',
                              labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                              filled: true,
                              fillColor: AppTokens.bgDarkSurface,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            items: List.generate(11, (i) => i + 1)
                                .where((s) => s >= _startSession)
                                .map((s) {
                              final slot = AppConstants.timeSlots.firstWhere((ts) => ts['session'] == s);
                              return DropdownMenuItem(
                                value: s,
                                child: Text('Sesi $s (${slot['end']})'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _endSession = val);
                                _runConflictCheck();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (_currentStep == 2) ...[
            // ── Section 2: Data Pemohon & Keperluan ───────────────────
            CyberCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person_rounded, color: AppTokens.primaryPurpleGlow, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Identitas Pemohon & Keperluan',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Role Chip Selector
                    Row(
                      children: ['Mahasiswa', 'Dosen', 'Ormawa/Himpunan'].map((role) {
                        final isSelected = _userRole == role;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(role),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setState(() => _userRole = role);
                            },
                            selectedColor: AppTokens.primaryPurple,
                            backgroundColor: AppTokens.bgDarkSurface,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Nama & NIM/NIP
                    TextFormField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap Pemohon',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: AppTokens.bgDarkSurface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.badge_rounded, color: Colors.white54),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nimNipCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: _userRole == 'Dosen' ? 'NIP' : 'NIM',
                              labelStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: AppTokens.bgDarkSurface,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: 'No. WhatsApp',
                              labelStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: AppTokens.bgDarkSurface,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'No WA wajib' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Keperluan Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPurpose,
                      dropdownColor: AppTokens.bgDarkCard,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Kategori Keperluan',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: AppTokens.bgDarkSurface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: AppConstants.bookingPurposes.map((p) {
                        return DropdownMenuItem(value: p, child: Text(p));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPurpose = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Dosen Pembimbing / Penanggung Jawab
                    TextFormField(
                      controller: _supervisorCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Dosen Pembimbing / Penanggung Jawab',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: AppTokens.bgDarkSurface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.school_rounded, color: Colors.white54),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Wajib mengisi dosen PJ' : null,
                    ),
                    const SizedBox(height: 12),

                    // Keterangan Rinci
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Rincian Kegiatan / Judul Tugas / Praktikum',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: AppTokens.bgDarkSurface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Wajib menuliskan deskripsi' : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (_currentStep == 3) ...[
            // ── Section 3: Fasilitas Tambahan yang Dipinjam ────────────
            CyberCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.devices_other_rounded, color: AppTokens.accentGold, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Peminjaman Fasilitas Alat Tambahan (Opsional)',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...AppConstants.additionalFacilities.map((fac) {
                      final isChecked = _selectedFacilities.contains(fac);
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(fac, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        value: isChecked,
                        activeColor: AppTokens.primaryPurple,
                        checkColor: Colors.white,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedFacilities.add(fac);
                            } else {
                              _selectedFacilities.remove(fac);
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Review summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTokens.bgDarkSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTokens.primaryPurpleGlow.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ringkasan Permohonan:', style: TextStyle(color: AppTokens.accentGold, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text('• Ruangan: ${selectedRoom.id} - ${selectedRoom.name}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('• Waktu: ${_getDayName(_selectedDate)}, ${DateFormat('dd MMM yyyy').format(_selectedDate)} (Sesi $_startSession-$_endSession)', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('• Pemohon: ${_nameCtrl.text.isNotEmpty ? _nameCtrl.text : "(Isi pada langkah 2)"} (${_nimNipCtrl.text})', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('• Keperluan: $_selectedPurpose', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // ── Step Navigation Buttons ───────────────────────────────
          Row(
            children: [
              if (_currentStep > 1)
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Sebelumnya'),
                    onPressed: () => setState(() => _currentStep--),
                  ),
                ),
              if (_currentStep > 1) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: CyberButton(
                  text: _currentStep < 3
                      ? 'Lanjutkan Langkah ${_currentStep + 1}'
                      : (hasConflict ? 'Jadwal Bentrok (Tidak Dapat Diajukan)' : 'Ajukan Permohonan Peminjaman'),
                  icon: _currentStep < 3 ? Icons.arrow_forward_rounded : Icons.send_rounded,
                  isLoading: _isLoading,
                  onPressed: (_currentStep == 1 && hasConflict)
                      ? null
                      : () {
                          if (_currentStep < 3) {
                            if (_currentStep == 2 && !_formKey.currentState!.validate()) return;
                            setState(() => _currentStep++);
                          } else {
                            if (!hasConflict) _submitBooking();
                          }
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    ),
  );
}

  Widget _buildWizardStepNode(int step, String label, bool isCompleted, bool isCurrent) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrent
                ? AppTokens.primaryPurple
                : (isCompleted ? AppTokens.success : Colors.white12),
            border: Border.all(
              color: isCurrent ? AppTokens.primaryPurpleGlow : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isCompleted && !isCurrent
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : Text(
                    '$step',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: isCurrent ? Colors.white : (isCompleted ? Colors.white70 : Colors.white38),
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    final allRooms = ref.read(roomsProvider);
    final room = allRooms.firstWhere((r) => r.id == _selectedRoomCode);
    final startSlot = AppConstants.timeSlots.firstWhere((s) => s['session'] == _startSession);
    final endSlot = AppConstants.timeSlots.firstWhere((s) => s['session'] == _endSession);

    setState(() => _isLoading = true);

    final bookingCode =
        'BOOK-${DateFormat('yyyyMMdd').format(_selectedDate)}-${100 + DateTime.now().millisecond}';

    final newBooking = BookingModel(
      id: 'BKG-${DateTime.now().millisecondsSinceEpoch}',
      bookingCode: bookingCode,
      userId: 'usr-current',
      userName: _nameCtrl.text.trim(),
      userNimNip: _nimNipCtrl.text.trim(),
      userPhone: _phoneCtrl.text.trim(),
      userRole: _userRole,
      roomCode: _selectedRoomCode,
      roomName: room.name,
      bookingDate: _selectedDate,
      day: _getDayName(_selectedDate),
      startSession: _startSession,
      endSession: _endSession,
      startTime: startSlot['start'] as String,
      endTime: endSlot['end'] as String,
      purpose: _selectedPurpose,
      description: _descCtrl.text.trim(),
      supervisorLecturer: _supervisorCtrl.text.trim(),
      additionalFacilities: _selectedFacilities,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
    );

    await ref.read(bookingListProvider.notifier).createBooking(newBooking);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permohonan peminjaman $bookingCode berhasil dikirim! Menunggu verifikasi laboran.'),
          backgroundColor: AppTokens.success,
        ),
      );
      context.pushReplacement('/mahasiswa/dashboard');
    }
  }
}
