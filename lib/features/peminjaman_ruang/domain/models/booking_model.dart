enum BookingStatus {
  pending,    // Menunggu Persetujuan Laboran / Admin
  approved,   // Disetujui (Belum Dimulai)
  active,     // Sedang Digunakan (Kunci Diambil)
  completed,  // Selesai & Video Kebersihan Terverifikasi
  rejected,   // Ditolak
  cancelled,  // Dibatalkan oleh Peminjam
}

class BookingModel {
  final String id;
  final String bookingCode;
  final String userId;
  final String userName;
  final String userNimNip;
  final String userPhone;
  final String userRole; // Mahasiswa, Dosen, Ormawa
  final String roomCode;
  final String roomName;
  final DateTime bookingDate;
  final String day;
  final int startSession;
  final int endSession;
  final String startTime;
  final String endTime;
  final String purpose;
  final String description;
  final String supervisorLecturer;
  final List<String> additionalFacilities;
  final BookingStatus status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  // ── Checkout & Cleanliness Verification ───────────────────────
  final bool checkoutCleanlinessStatus;
  final bool checkoutAcOffStatus;
  final bool checkoutLightsOffStatus;
  final bool checkoutPcOffStatus;
  final bool checkoutDoorsLockedStatus;
  final String? checkoutVideoUrl;
  final String? checkoutVideoName;
  final DateTime? checkoutSubmittedAt;
  final String? checkoutNotes;
  final String? laboranReviewNotes;

  const BookingModel({
    required this.id,
    required this.bookingCode,
    required this.userId,
    required this.userName,
    required this.userNimNip,
    required this.userPhone,
    required this.userRole,
    required this.roomCode,
    required this.roomName,
    required this.bookingDate,
    required this.day,
    required this.startSession,
    required this.endSession,
    required this.startTime,
    required this.endTime,
    required this.purpose,
    required this.description,
    required this.supervisorLecturer,
    this.additionalFacilities = const [],
    this.status = BookingStatus.pending,
    this.rejectionReason,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
    this.checkoutCleanlinessStatus = false,
    this.checkoutAcOffStatus = false,
    this.checkoutLightsOffStatus = false,
    this.checkoutPcOffStatus = false,
    this.checkoutDoorsLockedStatus = false,
    this.checkoutVideoUrl,
    this.checkoutVideoName,
    this.checkoutSubmittedAt,
    this.checkoutNotes,
    this.laboranReviewNotes,
  });

  String get statusLabel {
    switch (status) {
      case BookingStatus.pending:
        return 'Menunggu Persetujuan';
      case BookingStatus.approved:
        return 'Disetujui (Siap Pakai)';
      case BookingStatus.active:
        return 'Sedang Berlangsung';
      case BookingStatus.completed:
        return 'Selesai & Terverifikasi';
      case BookingStatus.rejected:
        return 'Ditolak';
      case BookingStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  bool get isCheckoutDone =>
      checkoutSubmittedAt != null && (checkoutVideoUrl != null || checkoutVideoName != null);

  String get sessionRangeLabel => 'Sesi $startSession - $endSession ($startTime - $endTime)';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_code': bookingCode,
      'user_id': userId,
      'user_name': userName,
      'user_nim_nip': userNimNip,
      'user_phone': userPhone,
      'user_role': userRole,
      'room_code': roomCode,
      'room_name': roomName,
      'booking_date': bookingDate.toIso8601String(),
      'day': day,
      'start_session': startSession,
      'end_session': endSession,
      'start_time': startTime,
      'end_time': endTime,
      'purpose': purpose,
      'description': description,
      'supervisor_lecturer': supervisorLecturer,
      'additional_facilities': additionalFacilities,
      'status': status.name,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'approved_by': approvedBy,
      'checkout_cleanliness_status': checkoutCleanlinessStatus,
      'checkout_ac_off_status': checkoutAcOffStatus,
      'checkout_lights_off_status': checkoutLightsOffStatus,
      'checkout_pc_off_status': checkoutPcOffStatus,
      'checkout_doors_locked_status': checkoutDoorsLockedStatus,
      'checkout_video_url': checkoutVideoUrl,
      'checkout_video_name': checkoutVideoName,
      'checkout_submitted_at': checkoutSubmittedAt?.toIso8601String(),
      'checkout_notes': checkoutNotes,
      'laboran_review_notes': laboranReviewNotes,
    };
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String? ?? 'BKG-${DateTime.now().millisecondsSinceEpoch}',
      bookingCode: json['booking_code'] as String? ?? 'PBM-${DateTime.now().millisecondsSinceEpoch}',
      userId: json['user_id'] as String? ?? 'kiosk-student',
      userName: json['user_name'] as String? ?? 'Mahasiswa',
      userNimNip: json['user_nim_nip'] as String? ?? '-',
      userPhone: json['user_phone'] as String? ?? '-',
      userRole: json['user_role'] as String? ?? 'Mahasiswa',
      roomCode: json['room_code'] as String? ?? '-',
      roomName: json['room_name'] as String? ?? '-',
      bookingDate: json['booking_date'] != null
          ? (DateTime.tryParse(json['booking_date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      day: json['day'] as String? ?? 'Senin',
      startSession: (json['start_session'] as num?)?.toInt() ?? 1,
      endSession: (json['end_session'] as num?)?.toInt() ?? 1,
      startTime: json['start_time'] as String? ?? '07:30',
      endTime: json['end_time'] as String? ?? '08:20',
      purpose: json['purpose'] as String? ?? '-',
      description: json['description'] as String? ?? '',
      supervisorLecturer: json['supervisor_lecturer'] as String? ?? '-',
      additionalFacilities: (json['additional_facilities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      approvedBy: json['approved_by'] as String?,
      checkoutCleanlinessStatus:
          json['checkout_cleanliness_status'] as bool? ?? false,
      checkoutAcOffStatus: json['checkout_ac_off_status'] as bool? ?? false,
      checkoutLightsOffStatus:
          json['checkout_lights_off_status'] as bool? ?? false,
      checkoutPcOffStatus: json['checkout_pc_off_status'] as bool? ?? false,
      checkoutDoorsLockedStatus:
          json['checkout_doors_locked_status'] as bool? ?? false,
      checkoutVideoUrl: json['checkout_video_url'] as String?,
      checkoutVideoName: json['checkout_video_name'] as String?,
      checkoutSubmittedAt: json['checkout_submitted_at'] != null
          ? DateTime.parse(json['checkout_submitted_at'] as String)
          : null,
      checkoutNotes: json['checkout_notes'] as String?,
      laboranReviewNotes: json['laboran_review_notes'] as String?,
    );
  }

  BookingModel copyWith({
    String? id,
    String? bookingCode,
    String? userId,
    String? userName,
    String? userNimNip,
    String? userPhone,
    String? userRole,
    String? roomCode,
    String? roomName,
    DateTime? bookingDate,
    String? day,
    int? startSession,
    int? endSession,
    String? startTime,
    String? endTime,
    String? purpose,
    String? description,
    String? supervisorLecturer,
    List<String>? additionalFacilities,
    BookingStatus? status,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? approvedAt,
    String? approvedBy,
    bool? checkoutCleanlinessStatus,
    bool? checkoutAcOffStatus,
    bool? checkoutLightsOffStatus,
    bool? checkoutPcOffStatus,
    bool? checkoutDoorsLockedStatus,
    String? checkoutVideoUrl,
    String? checkoutVideoName,
    DateTime? checkoutSubmittedAt,
    String? checkoutNotes,
    String? laboranReviewNotes,
  }) {
    return BookingModel(
      id: id ?? this.id,
      bookingCode: bookingCode ?? this.bookingCode,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userNimNip: userNimNip ?? this.userNimNip,
      userPhone: userPhone ?? this.userPhone,
      userRole: userRole ?? this.userRole,
      roomCode: roomCode ?? this.roomCode,
      roomName: roomName ?? this.roomName,
      bookingDate: bookingDate ?? this.bookingDate,
      day: day ?? this.day,
      startSession: startSession ?? this.startSession,
      endSession: endSession ?? this.endSession,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      purpose: purpose ?? this.purpose,
      description: description ?? this.description,
      supervisorLecturer: supervisorLecturer ?? this.supervisorLecturer,
      additionalFacilities: additionalFacilities ?? this.additionalFacilities,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      checkoutCleanlinessStatus:
          checkoutCleanlinessStatus ?? this.checkoutCleanlinessStatus,
      checkoutAcOffStatus: checkoutAcOffStatus ?? this.checkoutAcOffStatus,
      checkoutLightsOffStatus:
          checkoutLightsOffStatus ?? this.checkoutLightsOffStatus,
      checkoutPcOffStatus: checkoutPcOffStatus ?? this.checkoutPcOffStatus,
      checkoutDoorsLockedStatus:
          checkoutDoorsLockedStatus ?? this.checkoutDoorsLockedStatus,
      checkoutVideoUrl: checkoutVideoUrl ?? this.checkoutVideoUrl,
      checkoutVideoName: checkoutVideoName ?? this.checkoutVideoName,
      checkoutSubmittedAt: checkoutSubmittedAt ?? this.checkoutSubmittedAt,
      checkoutNotes: checkoutNotes ?? this.checkoutNotes,
      laboranReviewNotes: laboranReviewNotes ?? this.laboranReviewNotes,
    );
  }
}
