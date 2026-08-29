enum RoomType {
  lab,
  theoryClass,
  studio,
}

enum RoomStatus {
  available,
  inUse,
  maintenance,
}

class RoomModel {
  final String id;
  final String name;
  final RoomType type;
  final int floor;
  final String building;
  final int capacity;
  final List<String> facilities;
  final RoomStatus status;
  final String picName;
  final String? description;

  const RoomModel({
    required this.id,
    required this.name,
    required this.type,
    required this.floor,
    required this.building,
    required this.capacity,
    required this.facilities,
    this.status = RoomStatus.available,
    required this.picName,
    this.description,
  });

  String get typeLabel {
    switch (type) {
      case RoomType.lab:
        return 'Laboratorium Komputer';
      case RoomType.theoryClass:
        return 'Ruang Kelas Teori';
      case RoomType.studio:
        return 'Studio Multimedia';
    }
  }

  String get statusLabel {
    switch (status) {
      case RoomStatus.available:
        return 'Tersedia';
      case RoomStatus.inUse:
        return 'Sedang Digunakan';
      case RoomStatus.maintenance:
        return 'Pemeliharaan (Maintenance)';
    }
  }

  bool get isLab => type == RoomType.lab || type == RoomType.studio;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'floor': floor,
      'building': building,
      'capacity': capacity,
      'facilities': facilities,
      'status': status.name,
      'pic_name': picName,
      'description': description,
    };
  }

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: RoomType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RoomType.lab,
      ),
      floor: json['floor'] as int? ?? 1,
      building: json['building'] as String? ?? 'Gedung TIK',
      capacity: json['capacity'] as int? ?? 30,
      facilities: (json['facilities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: RoomStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RoomStatus.available,
      ),
      picName: json['pic_name'] as String? ?? 'Laboran TIK',
      description: json['description'] as String?,
    );
  }

  RoomModel copyWith({
    String? id,
    String? name,
    RoomType? type,
    int? floor,
    String? building,
    int? capacity,
    List<String>? facilities,
    RoomStatus? status,
    String? picName,
    String? description,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      floor: floor ?? this.floor,
      building: building ?? this.building,
      capacity: capacity ?? this.capacity,
      facilities: facilities ?? this.facilities,
      status: status ?? this.status,
      picName: picName ?? this.picName,
      description: description ?? this.description,
    );
  }
}
