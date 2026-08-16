import '../../auth/domain/user_model.dart';
import '../../pendaftaran_yudisium/domain/pendaftaran_model.dart';

/// Model untuk admin: pending accounts, pendaftaran detail, audit
class PendingAccount {
  const PendingAccount({
    required this.user,
    required this.registeredAt,
  });
  final User user;
  final DateTime registeredAt;
}

class PendaftaranAdmin {
  const PendaftaranAdmin({
    required this.pendaftaran,
    required this.mahasiswa,
  });
  final PendaftaranYudisium pendaftaran;
  final User mahasiswa;
}

class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    required this.adminNama,
    required this.aksi,
    required this.target,
    required this.waktu,
    this.keterangan,
  });
  final String id;
  final String adminNama;
  final String aksi;
  final String target;
  final DateTime waktu;
  final String? keterangan;
}
