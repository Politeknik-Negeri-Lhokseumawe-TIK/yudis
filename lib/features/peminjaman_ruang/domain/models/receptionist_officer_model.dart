class ReceptionistOfficerModel {
  final String id;
  final String name;
  final String nip;
  final String roleTitle;
  final String shiftName;
  final String shiftHours;
  final String counterName;
  final String avatarInitials;
  final String department;
  final bool isOnDuty;
  final String contactPhone;

  const ReceptionistOfficerModel({
    required this.id,
    required this.name,
    required this.nip,
    required this.roleTitle,
    required this.shiftName,
    required this.shiftHours,
    required this.counterName,
    required this.avatarInitials,
    required this.department,
    this.isOnDuty = true,
    required this.contactPhone,
  });

  ReceptionistOfficerModel copyWith({
    String? id,
    String? name,
    String? nip,
    String? roleTitle,
    String? shiftName,
    String? shiftHours,
    String? counterName,
    String? avatarInitials,
    String? department,
    bool? isOnDuty,
    String? contactPhone,
  }) {
    return ReceptionistOfficerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nip: nip ?? this.nip,
      roleTitle: roleTitle ?? this.roleTitle,
      shiftName: shiftName ?? this.shiftName,
      shiftHours: shiftHours ?? this.shiftHours,
      counterName: counterName ?? this.counterName,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      department: department ?? this.department,
      isOnDuty: isOnDuty ?? this.isOnDuty,
      contactPhone: contactPhone ?? this.contactPhone,
    );
  }

  factory ReceptionistOfficerModel.fromRow(Map<String, dynamic> row) {
    final name = (row['name'] ?? 'Petugas Resepsionis').toString();
    final initials = name.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join();

    return ReceptionistOfficerModel(
      id: (row['id'] ?? 'OFFICER-${DateTime.now().millisecondsSinceEpoch}').toString(),
      name: name,
      nip: (row['nip'] ?? '-').toString(),
      roleTitle: (row['role'] ?? row['role_title'] ?? 'Front Desk Officer').toString(),
      shiftName: (row['shift_name'] ?? 'Shift Pagi').toString(),
      shiftHours: (row['shift_hours'] ?? '07:30 - 13:00 WIB').toString(),
      counterName: (row['counter_name'] ?? 'MEJA PELAYANAN 1 (LOKET UTAMA)').toString(),
      avatarInitials: initials.isNotEmpty ? initials : 'MW',
      department: (row['department'] ?? 'Jurusan Teknologi Informasi & Komputer').toString(),
      isOnDuty: row['is_active'] == true,
      contactPhone: (row['contact_phone'] ?? '0812-6901-4455').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'nip': nip,
        'role': roleTitle,
        'shift_name': shiftName,
        'shift_hours': shiftHours,
        'is_active': isOnDuty,
      };

  static const List<ReceptionistOfficerModel> defaultOfficers = [
    ReceptionistOfficerModel(
      id: 'OFFICER-01',
      name: 'Munawir, S.Kom.',
      nip: '19880412 201903 1 008',
      roleTitle: 'Front Desk Officer & Koordinator Pelayanan Lab',
      shiftName: 'Shift Pagi',
      shiftHours: '07:30 - 13:00 WIB',
      counterName: 'MEJA PELAYANAN 1 (LOKET UTAMA)',
      avatarInitials: 'MW',
      department: 'Jurusan Teknologi Informasi & Komputer',
      isOnDuty: true,
      contactPhone: '0812-6901-4455',
    ),
    ReceptionistOfficerModel(
      id: 'OFFICER-02',
      name: 'Riza Maulana, S.T.',
      nip: '19910725 202203 1 005',
      roleTitle: 'Customer Service Specialist & Teknisi Jaringan Cloud',
      shiftName: 'Shift Siang',
      shiftHours: '13:00 - 18:00 WIB',
      counterName: 'MEJA PELAYANAN 1 (LOKET UTAMA)',
      avatarInitials: 'RM',
      department: 'Jurusan Teknologi Informasi & Komputer',
      isOnDuty: false,
      contactPhone: '0852-7788-9900',
    ),
    ReceptionistOfficerModel(
      id: 'OFFICER-03',
      name: 'Safriadi, S.T., M.Kom.',
      nip: '19850214 201404 1 002',
      roleTitle: 'Duty Manager & Supervisor Operasional PBM',
      shiftName: 'Supervisi Harian',
      shiftHours: '07:30 - 18:00 WIB',
      counterName: 'MEJA SUPERVISOR PELAYANAN',
      avatarInitials: 'SF',
      department: 'Jurusan Teknologi Informasi & Komputer',
      isOnDuty: false,
      contactPhone: '0811-6700-1122',
    ),
  ];
}
