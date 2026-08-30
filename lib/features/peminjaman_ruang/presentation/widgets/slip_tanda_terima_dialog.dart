import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/models/booking_model.dart';
import '../../domain/models/receptionist_officer_model.dart';

class SlipTandaTerimaDialog extends StatelessWidget {
  final BookingModel booking;
  final ReceptionistOfficerModel officer;

  const SlipTandaTerimaDialog({
    super.key,
    required this.booking,
    required this.officer,
  });

  static void show(
    BuildContext context, {
    required BookingModel booking,
    required ReceptionistOfficerModel officer,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => SlipTandaTerimaDialog(
        booking: booking,
        officer: officer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr = DateFormat('dd/MM/yyyy HH:mm:ss').format(now);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFBFD),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Slip Ala Bank ─────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.account_balance_rounded, color: AppTokens.accentGold, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'POLITEKNIK NEGERI LHOKSEUMAWE',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'JURUSAN TEKNOLOGI INFORMASI & KOMPUTER',
                          style: TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'FRONT DESK & LAYANAN RESEPSIONIS LABORATORIUM',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFCBD5E1), thickness: 1.5),
              const SizedBox(height: 8),

              // Title of Slip
              Center(
                child: Column(
                  children: [
                    const Text(
                      'SLIP TANDA TERIMA SERAH KUNCI LAB',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NO. TRANSAKSI: ${booking.bookingCode}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Officer On Duty Badge Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_pin_rounded, color: Color(0xFF0284C7), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PETUGAS RESEPSIONIS: ${officer.name.toUpperCase()}',
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            'NIP: ${officer.nip} • ${officer.counterName}',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Transaction Detail Rows
              _buildSlipRow('Waktu Peminjaman', timeStr),
              _buildSlipRow('Identitas Peminjam', '${booking.userName} (${booking.userNimNip})'),
              _buildSlipRow('Peran / Status', '${booking.userRole} • WA: ${booking.userPhone}'),
              _buildSlipRow('Ruang / Laboratorium', '${booking.roomCode} - ${booking.roomName}'),
              _buildSlipRow('Jadwal Peminjaman', '${booking.day}, ${DateFormat('dd/MM/yyyy').format(booking.bookingDate)}'),
              _buildSlipRow('Sesi Pemakaian', '${booking.sessionRangeLabel} (${booking.startTime} - ${booking.endTime})'),
              _buildSlipRow('Keperluan / Tujuan', booking.purpose),
              _buildSlipRow('Dosen Penanggung Jawab', booking.supervisorLecturer),
              if (booking.additionalFacilities.isNotEmpty)
                _buildSlipRow('Fasilitas Tambahan', booking.additionalFacilities.join(', ')),

              const SizedBox(height: 12),
              const Divider(color: Color(0xFFCBD5E1), thickness: 1),
              const SizedBox(height: 8),

              // SOP Checkbox Warning
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PERNYATAAN & KEWAJIBAN PEMINJAM:',
                      style: TextStyle(
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '1. Wajib mematikan AC & lampu sebelum meninggalkan ruangan.\n'
                      '2. Wajib shutdown seluruh komputer & merapikan meja kursi.\n'
                      '3. Wajib merekam video kondisi akhir lab dan mengunggahnya ke sistem.\n'
                      '4. Mengembalikan kunci fisik ke meja resepsionis tepat waktu.',
                      style: TextStyle(
                        color: Color(0xFF78350F),
                        fontSize: 9.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Signature Stamp Box & QR Code
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // QR Code Validasi
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      QrImageView(
                        data: 'PNL-TIK-KEY#${booking.bookingCode}#${officer.id}#$timeStr',
                        version: QrVersions.auto,
                        size: 72.0,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'E-Verification Valid',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  // Digital Stamp of Officer
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Petugas Meja Pelayanan,',
                        style: TextStyle(color: Color(0xFF475569), fontSize: 10),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF0284C7), width: 1.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '★ RESEPSIONIS TIK PNL ★\n[ SERAH TERIMA KUNCI SAH ]',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF0284C7),
                            fontWeight: FontWeight.w900,
                            fontSize: 8,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        officer.name,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      Text(
                        'NIP. ${officer.nip}',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 9),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Print / Close Action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFF94A3B8)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF475569)),
                      label: const Text('Tutup', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.print_rounded, size: 16, color: AppTokens.accentGold),
                      label: const Text('Cetak Slip Struk', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🖨️ Mengirim perintah cetak slip tanda terima ke printer...'),
                            backgroundColor: Color(0xFF0F172A),
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlipRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Text(' : ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
