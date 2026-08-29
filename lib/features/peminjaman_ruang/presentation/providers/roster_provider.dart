import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/room_model.dart';
import '../../domain/models/roster_item_model.dart';
import '../../data/datasources/room_data_source.dart';
import '../../data/datasources/roster_data_source.dart';
import '../../data/repositories/supabase_room_repository.dart';
import '../../data/repositories/supabase_roster_repository.dart';

/// Repository Providers
final supabaseRoomRepoProvider = Provider<SupabaseRoomRepository>((ref) {
  return SupabaseRoomRepository();
});

final supabaseRosterRepoProvider = Provider<SupabaseRosterRepository>((ref) {
  return SupabaseRosterRepository();
});

/// Provider data master ruangan & laboratorium (Sync Instant + Cloud Fallback)
final roomsProvider = Provider<List<RoomModel>>((ref) {
  return RoomDataSource.getAllRooms();
});

/// FutureProvider data ruangan langsung dari Supabase
final asyncRoomsProvider = FutureProvider<List<RoomModel>>((ref) async {
  final repo = ref.watch(supabaseRoomRepoProvider);
  return await repo.getRooms();
});

/// Provider data seluruh jadwal PBM Roster (Sync Instant + Cloud Fallback)
final allRosterSchedulesProvider = Provider<List<RosterItemModel>>((ref) {
  return RosterDataSource.getAllSchedules();
});

/// FutureProvider data jadwal roster langsung dari Supabase
final asyncRosterSchedulesProvider = FutureProvider<List<RosterItemModel>>((ref) async {
  final repo = ref.watch(supabaseRosterRepoProvider);
  return await repo.getRosterItems();
});

/// Filter state untuk Roster Digital
class RosterFilterState {
  final String selectedProdi;
  final String selectedClass;
  final String selectedDay;
  final String selectedRoom;
  final String searchQuery;
  final bool onlyPracticum;

  const RosterFilterState({
    this.selectedProdi = 'Semua Prodi',
    this.selectedClass = 'Semua Kelas',
    this.selectedDay = 'Semua Hari',
    this.selectedRoom = 'Semua Ruangan',
    this.searchQuery = '',
    this.onlyPracticum = false,
  });

  RosterFilterState copyWith({
    String? selectedProdi,
    String? selectedClass,
    String? selectedDay,
    String? selectedRoom,
    String? searchQuery,
    bool? onlyPracticum,
  }) {
    return RosterFilterState(
      selectedProdi: selectedProdi ?? this.selectedProdi,
      selectedClass: selectedClass ?? this.selectedClass,
      selectedDay: selectedDay ?? this.selectedDay,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      searchQuery: searchQuery ?? this.searchQuery,
      onlyPracticum: onlyPracticum ?? this.onlyPracticum,
    );
  }
}

class RosterFilterNotifier extends StateNotifier<RosterFilterState> {
  RosterFilterNotifier() : super(const RosterFilterState());

  void setProdi(String prodi) {
    state = state.copyWith(selectedProdi: prodi, selectedClass: 'Semua Kelas');
  }

  void setClass(String className) {
    state = state.copyWith(selectedClass: className);
  }

  void setDay(String day) {
    state = state.copyWith(selectedDay: day);
  }

  void setRoom(String room) {
    state = state.copyWith(selectedRoom: room);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleOnlyPracticum(bool value) {
    state = state.copyWith(onlyPracticum: value);
  }

  void resetFilter() {
    state = const RosterFilterState();
  }

  void reset() => resetFilter();
}

final rosterFilterProvider =
    StateNotifierProvider<RosterFilterNotifier, RosterFilterState>((ref) {
  return RosterFilterNotifier();
});

/// Filtered schedules provider
final filteredRosterSchedulesProvider = Provider<List<RosterItemModel>>((ref) {
  final allSchedules = ref.watch(allRosterSchedulesProvider);
  final filter = ref.watch(rosterFilterProvider);

  return allSchedules.where((item) {
    if (filter.selectedProdi != 'Semua Prodi' &&
        item.studyProgram != filter.selectedProdi) {
      return false;
    }
    if (filter.selectedClass != 'Semua Kelas' &&
        item.className != filter.selectedClass) {
      return false;
    }
    if (filter.selectedDay != 'Semua Hari' && item.day != filter.selectedDay) {
      return false;
    }
    if (filter.selectedRoom != 'Semua Ruangan' &&
        item.roomCode != filter.selectedRoom) {
      return false;
    }
    if (filter.onlyPracticum && !item.isPracticum) {
      return false;
    }
    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      final matchCourse = item.courseName.toLowerCase().contains(q);
      final matchLecturer = item.lecturerName.toLowerCase().contains(q);
      final matchRoom = item.roomCode.toLowerCase().contains(q);
      final matchClass = item.className.toLowerCase().contains(q);
      if (!matchCourse && !matchLecturer && !matchRoom && !matchClass) {
        return false;
      }
    }
    return true;
  }).toList();
});

/// Alias untuk kemudahan akses di UI
final filteredRosterProvider = filteredRosterSchedulesProvider;
