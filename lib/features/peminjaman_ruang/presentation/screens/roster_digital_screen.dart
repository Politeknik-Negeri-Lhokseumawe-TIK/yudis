import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/cyber_card.dart';
import '../../../../shared/widgets/cyber_button.dart';
import '../../domain/models/roster_item_model.dart';
import '../providers/roster_provider.dart';

class RosterDigitalScreen extends ConsumerStatefulWidget {
  const RosterDigitalScreen({super.key});

  @override
  ConsumerState<RosterDigitalScreen> createState() => _RosterDigitalScreenState();
}

class _RosterDigitalScreenState extends ConsumerState<RosterDigitalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final days = ['Semua Hari', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
        ref.read(rosterFilterProvider.notifier).setDay(days[_tabController.index]);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSchedules = ref.watch(filteredRosterProvider);
    final filter = ref.watch(rosterFilterProvider);
    final allRooms = ref.watch(roomsProvider);

    return Scaffold(
      backgroundColor: AppTokens.bgDark,
      body: CustomScrollView(
        slivers: [
          // ── App Bar Header ─────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTokens.bgDarkSurface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                tooltip: 'Reset Filter',
                icon: const Icon(Icons.refresh_rounded, color: AppTokens.primaryPurpleGlow),
                onPressed: () {
                  _searchCtrl.clear();
                  ref.read(rosterFilterProvider.notifier).reset();
                  _tabController.animateTo(0);
                },
              ),
              IconButton(
                tooltip: 'Cek Ketersediaan Ruangan',
                icon: const Icon(Icons.meeting_room_rounded, color: AppTokens.accentGold),
                onPressed: () => context.push('/ketersediaan-ruangan'),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTokens.primaryPurpleDark.withValues(alpha: 0.8),
                      AppTokens.bgDarkSurface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTokens.primaryPurple.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTokens.primaryPurpleGlow.withValues(alpha: 0.5),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, size: 14, color: AppTokens.primaryPurpleGlow),
                              SizedBox(width: 5),
                              Text(
                                'ROSTER DIGITAL RESMI GASAL 2026/2027',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTokens.primaryPurpleGlow,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${filteredSchedules.length} Jadwal',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Jadwal Perkuliahan & Lab TIK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Akses jadwal PBM tanpa file PDF, terintegrasi real-time dengan status lab.',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Search & Filter Controls ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    onChanged: (val) =>
                        ref.read(rosterFilterProvider.notifier).setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Cari Mata Kuliah, Dosen, Ruangan (cth: TIK.106)...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTokens.primaryPurpleGlow),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                ref.read(rosterFilterProvider.notifier).setSearchQuery('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppTokens.bgDarkCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTokens.glassBorderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTokens.glassBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTokens.primaryPurpleGlow),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Row (Prodi & Kelas & Ruang)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Dropdown Prodi
                        _buildFilterDropdown(
                          label: 'Prodi: ${filter.selectedProdi}',
                          icon: Icons.school_rounded,
                          color: AppTokens.primaryPurple,
                          onTap: () => _showProdiPicker(context),
                        ),
                        const SizedBox(width: 8),

                        // Dropdown Kelas
                        _buildFilterDropdown(
                          label: 'Kelas: ${filter.selectedClass}',
                          icon: Icons.groups_rounded,
                          color: AppTokens.accentGold,
                          onTap: () => _showClassPicker(context),
                        ),
                        const SizedBox(width: 8),

                        // Dropdown Ruang
                        _buildFilterDropdown(
                          label: 'Ruang: ${filter.selectedRoom}',
                          icon: Icons.room_rounded,
                          color: AppTokens.info,
                          onTap: () => _showRoomPicker(context, allRooms),
                        ),
                        const SizedBox(width: 8),

                        // Practicum Chip Toggle
                        FilterChip(
                          label: const Text('Praktik/Lab Saja'),
                          selected: filter.onlyPracticum,
                          onSelected: (val) =>
                              ref.read(rosterFilterProvider.notifier).toggleOnlyPracticum(val),
                          backgroundColor: AppTokens.bgDarkCard,
                          selectedColor: AppTokens.primaryPurple.withValues(alpha: 0.4),
                          checkmarkColor: AppTokens.primaryPurpleGlow,
                          labelStyle: TextStyle(
                            color: filter.onlyPracticum
                                ? AppTokens.primaryPurpleGlow
                                : Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: filter.onlyPracticum
                                  ? AppTokens.primaryPurpleGlow
                                  : AppTokens.glassBorderColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Day Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: AppTokens.bgDarkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTokens.glassBorderColor),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: AppTokens.primaryPurpleGlow,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white54,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      tabs: const [
                        Tab(text: 'Semua'),
                        Tab(text: 'Senin'),
                        Tab(text: 'Selasa'),
                        Tab(text: 'Rabu'),
                        Tab(text: 'Kamis'),
                        Tab(text: 'Jumat'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Schedule List ───────────────────────────────────────────
          if (filteredSchedules.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy_rounded, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                    const SizedBox(height: 12),
                    const Text(
                      'Tidak ada jadwal yang sesuai filter',
                      style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Coba atur ulang pencarian atau pilih kelas/ruang lain.',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    CyberButton(
                      text: 'Reset Semua Filter',
                      icon: Icons.refresh_rounded,
                      onPressed: () {
                        _searchCtrl.clear();
                        ref.read(rosterFilterProvider.notifier).reset();
                        _tabController.animateTo(0);
                      },
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filteredSchedules[index];
                    return _buildScheduleCard(context, item, index);
                  },
                  childCount: filteredSchedules.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTokens.primaryPurple,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Ajukan Peminjaman Ruang',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => context.push('/form-peminjaman'),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTokens.bgDarkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, RosterItemModel item, int index) {
    final isLab = item.roomCode.startsWith('TIK.1') || item.roomCode.startsWith('TDC');
    Color prodiColor = AppTokens.primaryPurple;
    if (item.studyProgram == 'TRMM') prodiColor = AppTokens.prodiTRMM;
    if (item.studyProgram == 'TI') prodiColor = AppTokens.prodiTI;

    return CyberCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Class + Day & Sesi Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: prodiColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: prodiColor.withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    item.className,
                    style: TextStyle(
                      color: prodiColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (item.isPracticum)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTokens.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTokens.success.withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.computer_rounded, size: 12, color: AppTokens.success),
                        SizedBox(width: 4),
                        Text(
                          'Praktikum',
                          style: TextStyle(color: AppTokens.success, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.day,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Course Name
            Text(
              item.courseName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Lecturer Name
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 16, color: Colors.white54),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.lecturerName,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 10),

            // Bottom Info: Session Time & Room Badge
            Row(
              children: [
                // Time & Session
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 15, color: AppTokens.accentGold),
                      const SizedBox(width: 6),
                      Text(
                        item.sessionRangeLabel,
                        style: const TextStyle(
                          color: AppTokens.accentGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Room Code Badge with clickable action
                InkWell(
                  onTap: () {
                    // Navigate to room availability for this room
                    context.push('/ketersediaan-ruangan?roomCode=${item.roomCode}');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isLab
                          ? AppTokens.primaryPurple.withValues(alpha: 0.3)
                          : Colors.blueGrey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isLab ? AppTokens.primaryPurpleGlow : Colors.blueGrey,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLab ? Icons.laptop_chromebook_rounded : Icons.meeting_room_rounded,
                          size: 14,
                          color: isLab ? AppTokens.primaryPurpleGlow : Colors.white70,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          item.roomCode,
                          style: TextStyle(
                            color: isLab ? AppTokens.primaryPurpleGlow : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms, delay: (index * 30).ms).slideY(begin: 0.05, end: 0);
  }

  // ── Picker Dialogs ────────────────────────────────────────────────
  void _showProdiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTokens.bgDarkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Program Studi',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...AppConstants.studyPrograms.map((p) {
                return ListTile(
                  title: Text(p, style: const TextStyle(color: Colors.white)),
                  trailing: ref.watch(rosterFilterProvider).selectedProdi == p
                      ? const Icon(Icons.check_circle_rounded, color: AppTokens.primaryPurpleGlow)
                      : null,
                  onTap: () {
                    ref.read(rosterFilterProvider.notifier).setProdi(p);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showClassPicker(BuildContext context) {
    final prodi = ref.watch(rosterFilterProvider).selectedProdi;
    final availableClasses = ['Semua Kelas', ...AppConstants.rosterClasses.where((c) {
      if (prodi == 'Semua Prodi') return true;
      return c.startsWith(prodi);
    })];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTokens.bgDarkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Kelas Roster',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: availableClasses.length,
                  itemBuilder: (context, i) {
                    final c = availableClasses[i];
                    final isSelected = ref.watch(rosterFilterProvider).selectedClass == c;
                    return ListTile(
                      title: Text(c, style: const TextStyle(color: Colors.white)),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppTokens.accentGold)
                          : null,
                      onTap: () {
                        ref.read(rosterFilterProvider.notifier).setClass(c);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRoomPicker(BuildContext context, List rooms) {
    final roomOptions = ['Semua Ruangan', ...rooms.map((r) => r.id)];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTokens.bgDarkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Ruangan / Laboratorium',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: roomOptions.length,
                  itemBuilder: (context, i) {
                    final r = roomOptions[i];
                    final isSelected = ref.watch(rosterFilterProvider).selectedRoom == r;
                    return ListTile(
                      title: Text(r, style: const TextStyle(color: Colors.white)),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppTokens.info)
                          : null,
                      onTap: () {
                        ref.read(rosterFilterProvider.notifier).setRoom(r);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
