class RosterItemModel {
  final String id;
  final String studyProgram; // TRMM, TRKJ, TI
  final String className;    // TRMM 1A, TI 2B, dll
  final String day;          // Senin, Selasa, Rabu, Kamis, Jumat
  final int startSession;    // 1-11
  final int endSession;      // 1-11
  final String startTime;    // '07:30'
  final String endTime;      // '10:00'
  final String courseName;   // Nama Mata Kuliah
  final String lecturerName; // Dosen Pengampu
  final String roomCode;     // TIK.101, TIK.204, TDC-308, dll
  final bool isPracticum;    // True jika Praktik/Praktikum/Workshop

  const RosterItemModel({
    required this.id,
    required this.studyProgram,
    required this.className,
    required this.day,
    required this.startSession,
    required this.endSession,
    required this.startTime,
    required this.endTime,
    required this.courseName,
    required this.lecturerName,
    required this.roomCode,
    this.isPracticum = false,
  });

  String get sessionRangeLabel => 'Sesi $startSession - $endSession ($startTime - $endTime)';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'study_program': studyProgram,
      'class_name': className,
      'day': day,
      'start_session': startSession,
      'end_session': endSession,
      'start_time': startTime,
      'end_time': endTime,
      'course_name': courseName,
      'lecturer_name': lecturerName,
      'room_code': roomCode,
      'is_practicum': isPracticum,
    };
  }

  factory RosterItemModel.fromJson(Map<String, dynamic> json) {
    return RosterItemModel(
      id: json['id'] as String,
      studyProgram: json['study_program'] as String,
      className: json['class_name'] as String,
      day: json['day'] as String,
      startSession: json['start_session'] as int,
      endSession: json['end_session'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      courseName: json['course_name'] as String,
      lecturerName: json['lecturer_name'] as String,
      roomCode: json['room_code'] as String,
      isPracticum: json['is_practicum'] as bool? ?? false,
    );
  }
}
