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
