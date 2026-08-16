/// Model User — siap wire ke API nyata
class User {
  const User({
    required this.id,
    required this.nim,
    required this.nama,
    required this.email,
    required this.role,
    required this.statusAkun,
    required this.programStudi,
    this.noHp,
    this.avatarUrl,
    this.createdAt,
  });

  final String id;
  final String nim;
  final String nama;
  final String email;
  final UserRole role;
  final StatusAkun statusAkun;
  final ProgramStudi programStudi;
  final String? noHp;
  final String? avatarUrl;
  final DateTime? createdAt;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        nim: json['nim'] as String,
        nama: json['nama'] as String,
        email: json['email'] as String,
        role: UserRole.values.firstWhere(
          (e) => e.value == json['role'],
          orElse: () => UserRole.mahasiswa,
        ),
        statusAkun: StatusAkun.values.firstWhere(
          (e) => e.value == json['status_akun'],
          orElse: () => StatusAkun.pendingVerifikasi,
        ),
        programStudi: ProgramStudi.values.firstWhere(
          (e) => e.value == json['program_studi'],
          orElse: () => ProgramStudi.ti,
        ),
        noHp: json['no_hp'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nim': nim,
        'nama': nama,
        'email': email,
        'role': role.value,
        'status_akun': statusAkun.value,
        'program_studi': programStudi.value,
        'no_hp': noHp,
        'avatar_url': avatarUrl,
        'created_at': createdAt?.toIso8601String(),
      };

  User copyWith({
    String? id,
    String? nim,
    String? nama,
    String? email,
    UserRole? role,
    StatusAkun? statusAkun,
    ProgramStudi? programStudi,
    String? noHp,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      nim: nim ?? this.nim,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      role: role ?? this.role,
      statusAkun: statusAkun ?? this.statusAkun,
      programStudi: programStudi ?? this.programStudi,
      noHp: noHp ?? this.noHp,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'User(id: $id, nim: $nim, nama: $nama, role: $role)';
}

enum UserRole {
  mahasiswa('mahasiswa'),
  admin('admin'),
  superAdmin('super_admin');

  const UserRole(this.value);
  final String value;
}

enum StatusAkun {
  pendingVerifikasi('pending_verifikasi'),
  aktif('aktif'),
  ditolak('ditolak'),
  nonaktif('nonaktif');

  const StatusAkun(this.value);
  final String value;

  String get label => switch (this) {
        StatusAkun.pendingVerifikasi => 'Menunggu Verifikasi',
        StatusAkun.aktif => 'Aktif',
        StatusAkun.ditolak => 'Ditolak',
        StatusAkun.nonaktif => 'Nonaktif',
      };
}

enum ProgramStudi {
  trkj('TRKJ'),
  trmm('TRMM'),
  ti('TI');

  const ProgramStudi(this.value);
  final String value;

  String get label => switch (this) {
        ProgramStudi.trkj => 'Teknologi Rekayasa Komputer Jaringan',
        ProgramStudi.trmm => 'Teknologi Rekayasa Multimedia',
        ProgramStudi.ti => 'Teknik Informatika',
      };

  String get shortLabel => switch (this) {
        ProgramStudi.trkj => 'D4-TRKJ',
        ProgramStudi.trmm => 'D4-TRMM',
        ProgramStudi.ti => 'D4-TI',
      };
}

