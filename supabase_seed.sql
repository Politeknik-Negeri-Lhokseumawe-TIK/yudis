-- ==============================================================================
-- SKRIP SEED MASTER RUANGAN & JADWAL ROSTER PBM SEMESTER GASAL 2026/2027
-- JURUSAN TEKNOLOGI INFORMASI DAN KOMPUTER - POLITEKNIK NEGERI LHOKSEUMAWE
-- ==============================================================================

-- 1. SEED MASTER 16 LABORATORIUM/STUDIO & 27 KELAS TEORI
INSERT INTO public.rooms (id, name, type, floor, building, capacity, facilities, pic_name) VALUES
('TIK.101', 'Lab Jaringan Komputer & Infrastruktur Cloud', 'lab', 1, 'Gedung TIK', 40, ARRAY['PC 40 Unit', 'Switch Cisco', 'Router Mikrotik', 'Server Rack', 'AC 2 PK'], 'Riza Maulana, S.T.'),
('TIK.102', 'Lab Pemrograman & Rekayasa Perangkat Lunak', 'lab', 1, 'Gedung TIK', 40, ARRAY['PC Core i7 40 Unit', 'Papan Tulis Digital', 'AC 2 PK'], 'Safriadi ST, M.Kom.'),
('TIK.103', 'Lab Basis Data & Data Warehouse', 'lab', 1, 'Gedung TIK', 35, ARRAY['PC Core i7 35 Unit', 'Server Oracle/PostgreSQL', 'AC 2 PK'], 'Rasyidah, S.Kom., M.Kom.'),
('TIK.104', 'Lab Sistem Keamanan Siber & Kriptografi', 'lab', 1, 'Gedung TIK', 35, ARRAY['PC 35 Unit High Spec', 'Firewall Hardware', 'Sandbox Lab', 'AC 2 PK'], 'Munawir, S.Kom.'),
('TIK.105', 'Lab Kecerdasan Buatan & Data Science', 'lab', 1, 'Gedung TIK', 35, ARRAY['GPU Workstation RTX 4090 35 Unit', 'Dual Monitor', 'AC 2 PK'], 'Zulfan, S.T., M.T.'),
('TIK.106', 'Lab Algoritma & Pemrograman Mobile', 'lab', 1, 'Gedung TIK', 30, ARRAY['PC 30 Unit', 'Android & iOS Test Devices', 'AC 2 PK'], 'Munawir, S.Kom.'),
('TIK.107', 'Lab Web Development & Cloud Computing', 'lab', 1, 'Gedung TIK', 35, ARRAY['PC Core i7 35 Unit', 'Proyektor Ultra HD', 'AC 2 PK'], 'Safriadi ST, M.Kom.'),
('TIK.108', 'Lab Sistem Tertanam & Mikroprosesor', 'lab', 1, 'Gedung TIK', 30, ARRAY['Oscilloscope', 'Arduino & STM32 Kit', 'Soldering Station', 'AC 2 PK'], 'Mursyidah, S.T., M.T.'),
('TIK.109', 'Lab Jaringan Nirkabel & Telekomunikasi', 'lab', 1, 'Gedung TIK', 30, ARRAY['Spectrum Analyzer', 'Access Point Enterprise', 'Optical Fusion Splicer', 'AC 2 PK'], 'Riza Maulana, S.T.'),
('TIK.110', 'Lab Komputasi Paralel & Sistem Terdistribusi', 'lab', 1, 'Gedung TIK', 30, ARRAY['Mini Cluster Server', 'PC 30 Unit', 'AC 2 PK'], 'Fajri, S.T., M.T.'),
('TIK.111', 'Lab Robotika, Otomasi & Internet of Things (IoT)', 'lab', 1, 'Gedung TIK', 30, ARRAY['Robot Arm Kit', '3D Printer', 'Sensor Lab', 'AC 2 PK'], 'M. Iqbal, S.T., M.T.'),
('TIK.112', 'Lab Perakitan Hardware & Pemeliharaan Komputer', 'lab', 1, 'Gedung TIK', 30, ARRAY['Bench Table', 'Diagnostic Kit', 'Toolkit Hardware', 'AC 2 PK'], 'Teuku Faisal, S.T.'),
('TDC-202', 'Studio Produksi Podcast, Audio & Video Editing', 'studio', 2, 'Gedung TDC', 25, ARRAY['Soundproof Room', 'Rodecaster Pro', 'Blackmagic Studio Camera', 'iMac 27"', 'AC 2 PK'], 'Razali, S.T., M.T.'),
('TDC-203', 'Studio Animasi 2D/3D & Pemodelan Visual', 'studio', 2, 'Gedung TDC', 25, ARRAY['Wacom Cintiq Pro 24', 'PC Workstation RTX 4080 25 Unit', 'AC 2 PK'], 'M. Arhami, S.Si., M.Kom.'),
('TDC-306', 'Studio Fotografi & Videografi Digital', 'studio', 3, 'Gedung TDC', 30, ARRAY['Green Screen Wall', 'Lighting Godox Studio', 'Sony A7IV Kit', 'Gimbal Stabilizer', 'AC 2 PK'], 'Razali, S.T., M.T.'),
('TDC-308', 'Studio UI/UX & Desain Game Interaktif', 'studio', 3, 'Gedung TDC', 30, ARRAY['VR Headset Oculus Quest 3', 'Dual 4K Display PC 30 Unit', 'AC 2 PK'], 'Rasyidah, S.Kom., M.Kom.'),
('TIK.201', 'Ruang Kelas Teori TIK.201', 'theoryClass', 2, 'Gedung TIK', 40, ARRAY['Proyektor Laser HD', 'Whiteboard', 'Sound System', 'AC 2 PK'], 'Staff Pengajaran TIK'),
('TIK.202', 'Ruang Kelas Teori TIK.202', 'theoryClass', 2, 'Gedung TIK', 40, ARRAY['Proyektor Laser HD', 'Whiteboard', 'Sound System', 'AC 2 PK'], 'Staff Pengajaran TIK'),
('TIK.203', 'Ruang Kelas Teori TIK.203', 'theoryClass', 2, 'Gedung TIK', 40, ARRAY['Proyektor Laser HD', 'Whiteboard', 'Sound System', 'AC 2 PK'], 'Staff Pengajaran TIK'),
('TIK.204', 'Ruang Kelas Teori TIK.204', 'theoryClass', 2, 'Gedung TIK', 40, ARRAY['Proyektor Laser HD', 'Whiteboard', 'Sound System', 'AC 2 PK'], 'Staff Pengajaran TIK'),
('TIK.205', 'Ruang Kelas Teori TIK.205', 'theoryClass', 2, 'Gedung TIK', 40, ARRAY['Proyektor Laser HD', 'Whiteboard', 'Sound System', 'AC 2 PK'], 'Staff Pengajaran TIK'),
('TIK.206', 'Ruang Kelas Teori TIK.206', 'theoryClass', 2, 'Gedung TIK', 40, ARRAY['Proyektor Laser HD', 'Whiteboard', 'Sound System', 'AC 2 PK'], 'Staff Pengajaran TIK'),
('TIK.301', 'Ruang Kelas Teori TIK.301', 'theoryClass', 3, 'Gedung TIK', 40, ARRAY['Proyektor Laser HD', 'Whiteboard', 'Sound System', 'AC 2 PK'], 'Staff Pengajaran TIK'),
('TIK.302', 'Ruang Kelas Teori TIK.302', 'theoryClass', 3, 'Gedung TIK', 40, ARRAY['Proyektor Laser HD', 'Whiteboard', 'Sound System', 'AC 2 PK'], 'Staff Pengajaran TIK'),
('TIK.303', 'Ruang Kelas Teori TIK.303', 'theoryClass', 3, 'Gedung TIK', 40, ARRAY['Proyektor Laser HD', 'Whiteboard', 'Sound System', 'AC 2 PK'], 'Staff Pengajaran TIK')
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    facilities = EXCLUDED.facilities,
    pic_name = EXCLUDED.pic_name;

-- 2. CONTOH SEED JADWAL ROSTER PBM SEMESTER GASAL 2026/2027
INSERT INTO public.roster_items (id, study_program, class_name, day, start_session, end_session, start_time, end_time, course_name, lecturer_name, room_code, is_practicum, semester) VALUES
('TRMM1A-SEN-1-3', 'TRMM', 'TRMM 1A', 'Senin', 1, 3, '07:30', '10:00', 'Desain Grafis Bitmap & Vektor', 'Razali, S.T., M.T.', 'TDC-202', true, 'Gasal 2026/2027'),
('TRMM1A-SEN-4-6', 'TRMM', 'TRMM 1A', 'Senin', 4, 6, '10:15', '12:45', 'Fotografi & Komposisi Visual', 'M. Arhami, S.Si., M.Kom.', 'TDC-306', true, 'Gasal 2026/2027'),
('TRKJ1A-SEN-1-3', 'TRKJ', 'TRKJ 1A', 'Senin', 1, 3, '07:30', '10:00', 'Konsep Jaringan Komputer', 'Riza Maulana, S.T.', 'TIK.101', true, 'Gasal 2026/2027'),
('TRKJ1A-SEN-4-6', 'TRKJ', 'TRKJ 1A', 'Senin', 4, 6, '10:15', '12:45', 'Dasar Sistem Operasi Linux', 'Munawir, S.Kom.', 'TIK.104', true, 'Gasal 2026/2027'),
('TI1A-SEN-1-3', 'TI', 'TI 1A', 'Senin', 1, 3, '07:30', '10:00', 'Algoritma & Dasar Pemrograman C++', 'Safriadi ST, M.Kom.', 'TIK.102', true, 'Gasal 2026/2027'),
('TI1A-SEN-4-6', 'TI', 'TI 1A', 'Senin', 4, 6, '10:15', '12:45', 'Logika Informatika & Struktur Diskrit', 'Zulfan, S.T., M.T.', 'TIK.201', false, 'Gasal 2026/2027'),
('TRMM2A-SEL-1-4', 'TRMM', 'TRMM 2A', 'Selasa', 1, 4, '07:30', '10:50', 'Animasi 2D & Motion Graphics', 'Razali, S.T., M.T.', 'TDC-203', true, 'Gasal 2026/2027'),
('TRKJ2A-SEL-1-4', 'TRKJ', 'TRKJ 2A', 'Selasa', 1, 4, '07:30', '10:50', 'Routing & Switching Enterprise', 'Riza Maulana, S.T.', 'TIK.101', true, 'Gasal 2026/2027'),
('TI2A-SEL-1-4', 'TI', 'TI 2A', 'Selasa', 1, 4, '07:30', '10:50', 'Pemrograman Berorientasi Objek', 'Safriadi ST, M.Kom.', 'TIK.102', true, 'Gasal 2026/2027'),
('TRMM3A-RAB-1-4', 'TRMM', 'TRMM 3A', 'Rabu', 1, 4, '07:30', '10:50', 'Produksi Konten Audio & Podcast', 'Razali, S.T., M.T.', 'TDC-202', true, 'Gasal 2026/2027'),
('TRKJ3A-RAB-1-4', 'TRKJ', 'TRKJ 3A', 'Rabu', 1, 4, '07:30', '10:50', 'Keamanan Jaringan & Cyber Defense', 'Munawir, S.Kom.', 'TIK.104', true, 'Gasal 2026/2027'),
('TI3A-RAB-1-4', 'TI', 'TI 3A', 'Rabu', 1, 4, '07:30', '10:50', 'Pengembangan Aplikasi Mobile Flutter', 'Munawir, S.Kom.', 'TIK.106', true, 'Gasal 2026/2027'),
('TRMM4A-KAM-1-4', 'TRMM', 'TRMM 4A', 'Kamis', 1, 4, '07:30', '10:50', 'UI/UX Interactive Design', 'Rasyidah, S.Kom., M.Kom.', 'TDC-308', true, 'Gasal 2026/2027'),
('TRKJ4A-KAM-1-4', 'TRKJ', 'TRKJ 4A', 'Kamis', 1, 4, '07:30', '10:50', 'Cloud Infrastructure & DevOps', 'Fajri, S.T., M.T.', 'TIK.110', true, 'Gasal 2026/2027'),
('TI4A-KAM-1-4', 'TI', 'TI 4A', 'Kamis', 1, 4, '07:30', '10:50', 'Deep Learning & Artificial Intelligence', 'Zulfan, S.T., M.T.', 'TIK.105', true, 'Gasal 2026/2027')
ON CONFLICT (id) DO UPDATE
SET course_name = EXCLUDED.course_name,
    lecturer_name = EXCLUDED.lecturer_name,
    room_code = EXCLUDED.room_code;
