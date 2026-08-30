-- ==============================================================================
-- SKRIP LENGKAP BACKEND SUPABASE (ZERO-DEPENDENCY & 100% PRODUCTION READY)
-- SISTEM MANAJEMEN PEMINJAMAN LABORATORIUM & RUANG KELAS (SIM-LAB & RUANG PBM)
-- JURUSAN TEKNOLOGI INFORMASI DAN KOMPUTER - POLITEKNIK NEGERI LHOKSEUMAWE
-- JADWAL ROSTER PBM SEMESTER GASAL TA 2026/2027 (423 SESI)
-- ==============================================================================

-- 1. FUNGSI TRIGGER AUTO-UPDATE TIMESTAMP (PENGGANTI moddatetime)
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. TABEL MASTER RUANGAN & LABORATORIUM
CREATE TABLE IF NOT EXISTS public.rooms (
  id          TEXT PRIMARY KEY,             -- Contoh: 'TIK.101', 'TDC-202', 'TIK.309'
  name        TEXT NOT NULL,
  type        TEXT NOT NULL CHECK (type IN ('lab', 'theoryClass', 'studio')),
  floor       INTEGER NOT NULL DEFAULT 1,
  building    TEXT NOT NULL DEFAULT 'Gedung TIK Utama',
  capacity    INTEGER NOT NULL DEFAULT 30,
  facilities  TEXT[] DEFAULT '{}',
  status      TEXT NOT NULL DEFAULT 'available'
              CHECK (status IN ('available', 'inUse', 'maintenance')),
  pic_name    TEXT NOT NULL,
  description TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

DROP TRIGGER IF EXISTS trg_rooms_updated_at ON public.rooms;
CREATE TRIGGER trg_rooms_updated_at
  BEFORE UPDATE ON public.rooms
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

COMMENT ON TABLE public.rooms IS 'Master data laboratorium dan ruang kelas Jurusan TIK PNL';

-- 3. TABEL JADWAL ROSTER PBM SEMESTER
CREATE TABLE IF NOT EXISTS public.roster_items (
  id              TEXT PRIMARY KEY,        -- Contoh: 'TRMM1A-1', 'TRKJ1A-5'
  study_program   TEXT NOT NULL,           -- 'TRMM', 'TRKJ', 'TI', 'TRPL'
  class_name      TEXT NOT NULL,           -- 'TRMM 1A', 'TI 3C', 'TRPL 1A'
  day             TEXT NOT NULL,           -- 'Senin'...'Jumat'
  start_session   INTEGER NOT NULL CHECK (start_session BETWEEN 1 AND 11),
  end_session     INTEGER NOT NULL CHECK (end_session BETWEEN 1 AND 11),
  start_time      TEXT NOT NULL,           -- '07:30'
  end_time        TEXT NOT NULL,           -- '10:00'
  course_name     TEXT NOT NULL,
  lecturer_name   TEXT NOT NULL,
  room_code       TEXT NOT NULL REFERENCES public.rooms(id) ON UPDATE CASCADE ON DELETE CASCADE,
  is_practicum    BOOLEAN DEFAULT FALSE,
  semester        TEXT NOT NULL DEFAULT 'Gasal 2026/2027',
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_roster_day_room ON public.roster_items(day, room_code);
CREATE INDEX IF NOT EXISTS idx_roster_program ON public.roster_items(study_program, class_name);

COMMENT ON TABLE public.roster_items IS 'Jadwal PBM Semester Gasal TA 2026/2027 — Jurusan TIK PNL';

-- 4. TABEL PETUGAS PENJAGA RESEPSIONIS (NAMA & NIP)
CREATE TABLE IF NOT EXISTS public.receptionist_officers (
  id              TEXT PRIMARY KEY,
  name            TEXT NOT NULL,
  nip             TEXT NOT NULL,
  shift_name      TEXT NOT NULL,           -- 'Shift Pagi', 'Shift Siang'
  shift_hours     TEXT NOT NULL,           -- '07:30 - 13:00 WIB'
  role            TEXT NOT NULL DEFAULT 'Front Desk Officer',
  is_active       BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

DROP TRIGGER IF EXISTS trg_officers_updated_at ON public.receptionist_officers;
CREATE TRIGGER trg_officers_updated_at
  BEFORE UPDATE ON public.receptionist_officers
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

COMMENT ON TABLE public.receptionist_officers IS 'Master data Petugas Resepsionis / Front Desk TIK PNL';

-- 5. TABEL TRANSAKSI PEMINJAMAN RUANG (Mendukung Mahasiswa Tanpa Akun)
CREATE TABLE IF NOT EXISTS public.bookings (
  id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_code                TEXT UNIQUE NOT NULL,
  user_id                     UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  user_name                   TEXT NOT NULL,
  user_nim_nip                TEXT NOT NULL,
  user_phone                  TEXT NOT NULL,
  user_role                   TEXT NOT NULL DEFAULT 'Mahasiswa',
  room_code                   TEXT NOT NULL REFERENCES public.rooms(id) ON UPDATE CASCADE,
  room_name                   TEXT NOT NULL,
  booking_date                DATE NOT NULL,
  day                         TEXT NOT NULL,
  start_session               INTEGER NOT NULL CHECK (start_session BETWEEN 1 AND 11),
  end_session                 INTEGER NOT NULL CHECK (end_session BETWEEN 1 AND 11),
  start_time                  TEXT NOT NULL,
  end_time                    TEXT NOT NULL,
  purpose                     TEXT NOT NULL,
  description                 TEXT DEFAULT '',
  supervisor_lecturer         TEXT NOT NULL,
  additional_facilities       TEXT[] DEFAULT '{}',
  status                      TEXT NOT NULL DEFAULT 'pending'
                              CHECK (status IN ('pending','approved','active','completed','rejected','cancelled')),
  rejection_reason            TEXT,
  approved_by                 TEXT,
  approved_at                 TIMESTAMPTZ,
  -- ── Status Checklist Pengembalian & Video ──
  checkout_cleanliness_status BOOLEAN DEFAULT FALSE,
  checkout_ac_off_status      BOOLEAN DEFAULT FALSE,
  checkout_lights_off_status  BOOLEAN DEFAULT FALSE,
  checkout_pc_off_status      BOOLEAN DEFAULT FALSE,
  checkout_doors_locked_status BOOLEAN DEFAULT FALSE,
  checkout_video_url          TEXT,
  checkout_video_name         TEXT,
  checkout_submitted_at       TIMESTAMPTZ,
  checkout_notes              TEXT,
  laboran_review_notes        TEXT,
  -- ── Ledger Integrity Hashing ──
  booking_ledger_hash         TEXT,
  video_inspection_hash       TEXT,
  created_at                  TIMESTAMPTZ DEFAULT NOW(),
  updated_at                  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_bookings_room_date ON public.bookings(room_code, booking_date, status);
CREATE INDEX IF NOT EXISTS idx_bookings_user ON public.bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings(status);

DROP TRIGGER IF EXISTS trg_bookings_updated_at ON public.bookings;
CREATE TRIGGER trg_bookings_updated_at
  BEFORE UPDATE ON public.bookings
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

COMMENT ON TABLE public.bookings IS 'Transaksi peminjaman laboratorium dan ruang kelas TIK PNL';

-- 6. TABEL PROFIL PENGGUNA (EXTEND AUTH.USERS)
CREATE TABLE IF NOT EXISTS public.profiles (
  id         UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nama       TEXT NOT NULL,
  nim        TEXT,
  nip        TEXT,
  role       TEXT NOT NULL DEFAULT 'mahasiswa'
             CHECK (role IN ('mahasiswa', 'dosen', 'laboran', 'admin')),
  prodi      TEXT,
  no_hp      TEXT,
  is_active  BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

DROP TRIGGER IF EXISTS trg_profiles_updated_at ON public.profiles;
CREATE TRIGGER trg_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.profiles(id, nama, role, nim, no_hp)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'nama', NEW.email),
    COALESCE(NEW.raw_user_meta_data->>'role', 'mahasiswa'),
    NEW.raw_user_meta_data->>'nim',
    NEW.raw_user_meta_data->>'no_hp'
  )
  ON CONFLICT (id) DO UPDATE
  SET nama = EXCLUDED.nama,
      nim = EXCLUDED.nim,
      no_hp = EXCLUDED.no_hp;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 7. STORED PROCEDURE CEK BENTROK JADWAL
CREATE OR REPLACE FUNCTION public.check_booking_conflict(
  p_room_code    TEXT,
  p_day          TEXT,
  p_start_session INTEGER,
  p_end_session   INTEGER,
  p_booking_date  DATE,
  p_exclude_id    UUID DEFAULT NULL
)
RETURNS TABLE(has_conflict BOOLEAN, conflict_type TEXT, message TEXT) AS $$
DECLARE
  v_roster_course TEXT;
  v_roster_class TEXT;
  v_booking_user TEXT;
BEGIN
  -- Cek Bentrok Roster PBM Reguler
  SELECT course_name, class_name INTO v_roster_course, v_roster_class
  FROM public.roster_items
  WHERE room_code = p_room_code
    AND day = p_day
    AND start_session <= p_end_session
    AND end_session >= p_start_session
  LIMIT 1;

  IF v_roster_course IS NOT NULL THEN
    RETURN QUERY SELECT TRUE, 'ROSTER_PBM', 
      'Ruangan sedang digunakan perkuliahan reguler: ' || v_roster_course || ' (' || v_roster_class || ').';
    RETURN;
  END IF;

  -- Cek Bentrok Peminjaman Lain yang Aktif
  SELECT user_name INTO v_booking_user
  FROM public.bookings
  WHERE room_code = p_room_code
    AND booking_date = p_booking_date
    AND status IN ('pending', 'approved', 'active')
    AND start_session <= p_end_session
    AND end_session >= p_start_session
    AND (p_exclude_id IS NULL OR id != p_exclude_id)
  LIMIT 1;

  IF v_booking_user IS NOT NULL THEN
    RETURN QUERY SELECT TRUE, 'BOOKING_OVERLAP',
      'Sudah terdapat peminjaman oleh ' || v_booking_user || ' pada sesi tersebut.';
    RETURN;
  END IF;

  RETURN QUERY SELECT FALSE, 'NONE', 'Slot waktu ruangan tersedia.';
END;
$$ LANGUAGE plpgsql;

-- 8. ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roster_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.receptionist_officers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "rooms_read_all" ON public.rooms;
CREATE POLICY "rooms_read_all" ON public.rooms FOR SELECT USING (true);

DROP POLICY IF EXISTS "rooms_manage_admin" ON public.rooms;
CREATE POLICY "rooms_manage_admin" ON public.rooms FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'laboran')));

DROP POLICY IF EXISTS "roster_read_all" ON public.roster_items;
CREATE POLICY "roster_read_all" ON public.roster_items FOR SELECT USING (true);

DROP POLICY IF EXISTS "roster_manage_admin" ON public.roster_items;
CREATE POLICY "roster_manage_admin" ON public.roster_items FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'laboran')));

-- Policy Receptionist Officers (Publik/Kiosk/PC bisa baca & ubah dosen piket secara sinkron)
DROP POLICY IF EXISTS "officers_read_all" ON public.receptionist_officers;
DROP POLICY IF EXISTS "officers_manage_admin" ON public.receptionist_officers;
DROP POLICY IF EXISTS "officers_select_policy" ON public.receptionist_officers;
DROP POLICY IF EXISTS "officers_insert_policy" ON public.receptionist_officers;
DROP POLICY IF EXISTS "officers_update_policy" ON public.receptionist_officers;
CREATE POLICY "officers_select_policy" ON public.receptionist_officers FOR SELECT USING (true);
CREATE POLICY "officers_insert_policy" ON public.receptionist_officers FOR INSERT WITH CHECK (true);
CREATE POLICY "officers_update_policy" ON public.receptionist_officers FOR UPDATE USING (true);

DROP POLICY IF EXISTS "bookings_select_policy" ON public.bookings;
CREATE POLICY "bookings_select_policy" ON public.bookings FOR SELECT USING (true);

DROP POLICY IF EXISTS "bookings_insert_policy" ON public.bookings;
CREATE POLICY "bookings_insert_policy" ON public.bookings FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "bookings_update_policy" ON public.bookings;
CREATE POLICY "bookings_update_policy" ON public.bookings FOR UPDATE USING (true);

DROP POLICY IF EXISTS "profiles_select_policy" ON public.profiles;
CREATE POLICY "profiles_select_policy" ON public.profiles FOR SELECT TO authenticated
  USING (
    id = auth.uid() OR
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'laboran'))
  );

DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
CREATE POLICY "profiles_update_own" ON public.profiles FOR UPDATE TO authenticated
  USING (id = auth.uid());

-- 9. STORAGE BUCKET UNTUK VIDEO CHECKOUT KEBERSIHAN & AC
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'video-inspeksi',
  'video-inspeksi',
  TRUE,
  524288000,
  ARRAY['video/mp4', 'video/quicktime', 'video/webm', 'video/x-msvideo', 'video/3gpp']
)
ON CONFLICT (id) DO UPDATE
SET public = TRUE,
    file_size_limit = 524288000;

DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
CREATE POLICY "Allow authenticated uploads" ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'video-inspeksi');

DROP POLICY IF EXISTS "Allow public read video" ON storage.objects;
CREATE POLICY "Allow public read video" ON storage.objects FOR SELECT TO public
  USING (bucket_id = 'video-inspeksi');

DROP POLICY IF EXISTS "Allow authenticated update video" ON storage.objects;
CREATE POLICY "Allow authenticated update video" ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'video-inspeksi');

-- ==============================================================================
-- 10. SEED MASTER LENGKAP RUANGAN & LABORATORIUM (43 RUANGAN)
-- ==============================================================================
INSERT INTO public.rooms (id, name, type, floor, building, capacity, facilities, pic_name, description) VALUES
  ('TIK.101', 'Laboratorium Sistem Operasi & Basis Data', 'lab', 1, 'Gedung TIK Utama', 32, ARRAY['32 PC Intel Core i7-12700 / 16GB RAM', 'Dual Monitor Setup untuk Instruktur', 'Proyektor Epson Laser Full HD', '2 Unit AC Split 2 PK', 'Gigabit Local Area Network', 'Genset Backup & UPS Sentral'], 'Muhammad Firdaus, A.Md.T.', 'Digunakan untuk Praktikum Sistem Operasi, Administrasi Basis Data, dan Workshop Web Enterprise.'),
  ('TIK.102', 'Laboratorium Pengolahan Citra Digital & Workshop PL', 'lab', 1, 'Gedung TIK Utama', 30, ARRAY['30 PC Core i7 / NVIDIA RTX 3060 12GB', 'Proyektor BenQ 4000 Lumens', '2 Unit AC Split 2 PK', 'Drawing Tablet Wacom Intuos', 'Soundbar & Wireless Mic'], 'Rizal Fahmi, S.T.', 'Fasilitas untuk Praktikum Pengolahan Citra Digital, Workshop Rekayasa PL, dan Pemrograman Visual.'),
  ('TIK.103', 'Laboratorium Konsep Basis Data & Konten Digital', 'lab', 1, 'Gedung TIK Utama', 32, ARRAY['32 PC Intel Core i5-12400 / 16GB RAM / SSD NVMe', 'Proyektor High Brightness', '2 Unit AC Split 2 PK', 'Smart Whiteboard Interaktif'], 'Teuku Iskandar, S.Kom.', 'Digunakan untuk Praktikum Konsep Basis Data, PBO, Desain UI/UX, dan Pengembangan Konten Digital.'),
  ('TIK.104', 'Laboratorium Konsep Pemrograman & Game Cerdas', 'lab', 1, 'Gedung TIK Utama', 30, ARRAY['30 PC Core i7 / RTX 3050 8GB / 16GB RAM', 'Interactive Touch Projector', '2 Unit AC Split 2 PK', 'VR Headset Oculus Quest 2'], 'Zulkifli, S.ST.', 'Digunakan untuk Konsep Pemrograman, Praktikum Game Cerdas, Algoritma, dan Jaringan Dasar.'),
  ('TIK.105', 'Laboratorium Rekayasa Web Enterprise & RPL', 'lab', 1, 'Gedung TIK Utama', 32, ARRAY['32 PC Intel Core i7 / 16GB RAM', 'Server Rack Development Environment', 'Proyektor Laser HD', '2 Unit AC Split 2 PK'], 'Hendra Gunawan, A.Md.', 'Digunakan untuk Praktikum Web MVC Framework, Rekayasa Perangkat Lunak, dan Basis Data Terdistribusi.'),
  ('TIK.106', 'Laboratorium Algoritma & Pemrograman Mobile', 'lab', 1, 'Gedung TIK Utama', 32, ARRAY['32 PC Core i7 / 32GB RAM (Support Android Studio Emulators)', 'Test Devices Tablet & Smartphone Android', 'Proyektor Epson HD', '2 Unit AC Split 2 PK'], 'Munawir, S.Kom.', 'Digunakan untuk Praktikum Pemrograman Mobile (Flutter/Android), Algoritma Struktur Data, dan Cloud Computing.'),
  ('TIK.107', 'Laboratorium Jaringan Komputer & Manajemen Risiko', 'lab', 1, 'Gedung TIK Utama', 28, ARRAY['28 PC Core i5 / Dual Gigabit NIC', '4 Unit Cisco Router 2901 & Catalyst Switch 2960', 'Server Rack Cisco CCNA Lab', 'Fiber Optic Splicer & OTDR Kit', '2 Unit AC Split 2 PK'], 'Ir. Bukhari, S.ST., M.T.', 'Pusat Praktik Dasar Jaringan, Penskalaan Jaringan, dan Manajemen Risiko Keamanan Siber.'),
  ('TIK.108', 'Laboratorium Sistem Administrator & Infrastruktur IT', 'lab', 1, 'Gedung TIK Utama', 28, ARRAY['28 PC Workstation Linux Enterprise', 'Cluster Server Virtualisasi Proxmox/VMware', 'MikroTik Cloud Core Router Lab', 'Proyektor Laser Full HD', '2 Unit AC Split 2 PK'], 'Faisal Akbar, S.ST.', 'Digunakan untuk Praktik Sysadmin, Layanan Infrastruktur IT, Manajemen Jaringan, dan Proyek Industri.'),
  ('TIK.109', 'Laboratorium Keamanan Siber & Ethical Hacking', 'lab', 1, 'Gedung TIK Utama', 28, ARRAY['28 PC Kali Linux / High Core CPU & RAM', 'Hardware Security Module & WiFi Pentest Kit', 'Isolated Sandbox VLAN', '2 Unit AC Split 2 PK'], 'Muhammad Ilham, S.Kom., M.Cs.', 'Digunakan untuk Praktikum Keamanan Jaringan Komputer, Etika Peretasan, dan Praktik Sistem Operasi.'),
  ('TIK.110', 'Laboratorium Layanan Virtual & Audit Infrastruktur', 'lab', 1, 'Gedung TIK Utama', 28, ARRAY['28 PC Workstation', 'SAN Storage Lab Simulator', 'Cisco Switch Layer 3', '2 Unit AC Split 2 PK'], 'Rahmatillah, S.T.', 'Digunakan untuk Praktik Sistem Layanan Virtual, Audit Infrastruktur, dan Aplikasi Layanan Jaringan.'),
  ('TIK.111', 'Laboratorium Internet of Things (IoT) & Elektronika', 'lab', 1, 'Gedung TIK Utama', 26, ARRAY['26 Workbench Meja Kerja Praktikum IoT', 'Oscilloscope Digital & Soldering Station Hakko', 'Kit ESP32, Raspberry Pi 4, Arduino Mega & Sensor Kit', '3D Printer Prusa i3 MK3S+', '2 Unit AC Split 2 PK'], 'Syamsul Rizal, S.ST., M.T.', 'Digunakan untuk Dasar Elektronika IoT, Desain Sistem Tertanam, dan Proyek Terintegrasi.'),
  ('TIK.112', 'Laboratorium Robotika & Otomasi Cerdas', 'lab', 1, 'Gedung TIK Utama', 26, ARRAY['Arena Robotika & Tracking Line Floor', 'Robotic Arm Kit & Autonomous Mobile Robot Kit', '26 PC Lab dengan MATLAB/ROS Simulation', '2 Unit AC Split 2 PK'], 'Dr. Anwar Sanusi, S.T., M.Eng.', 'Digunakan untuk Robotika Jaringan Cerdas & Otomasi, Advanced IoT, dan Embedded System.'),
  ('TDC-202', 'Studio Produksi Podcast, Audio & Video Editing', 'studio', 2, 'Gedung TDC (Technology & Design Center)', 20, ARRAY['Studio Akustik Kedap Suara (Soundproof)', '4 Unit Shure SM7B Mic + RODE Caster Pro II', '3 Unit Blackmagic Pocket Cinema Camera 4K', 'Lighting Softbox Godox & Green Screen Studio', 'Apple Mac Studio M2 Max untuk Video Editing', '2 Unit AC Split 2 PK Low Noise'], 'Nanda Saputri, SST., M.T.', 'Digunakan untuk Praktik Produksi Podcast, Rekayasa Video & Audio, serta Editing Pasca Animasi.'),
  ('TDC-203', 'Studio Fotografi & Sinematografi', 'studio', 2, 'Gedung TDC', 24, ARRAY['Cyclorama Wall Studio Putih & Aneka Backdrop', 'Lampu Flash Studio Godox AD600 Pro + Trigger', 'Kamera Sony A7 IV + Lensa G-Master', 'Gimbal DJI Ronin RS3 Pro', '2 Unit AC Split 2 PK'], 'Fachri Yanuar Rudi F, S.ST., M.T.', 'Digunakan untuk Praktik Fotografi Digital, Sinematografi, dan Produksi Media Periklanan.'),
  ('TDC-306', 'Laboratorium Desain Komunikasi Visual (DKV)', 'studio', 3, 'Gedung TDC', 28, ARRAY['28 PC iMac 24" Retina 4.5K', 'Pen Display Huion Kamvas Pro 16', 'Printer Cetak Desain A3+ EPSON L1800', 'Proyektor Kalibrasi Warna Akurat', '2 Unit AC Split 2 PK'], 'Muhammad Hari Hasibuan, M.Kom.', 'Digunakan untuk Desain Komunikasi Visual, Tipografi, Branding, dan Desain Media Interaktif.'),
  ('TDC-308', 'Laboratorium Menggambar Digital & Pembuat Aset 2D/3D', 'studio', 3, 'Gedung TDC', 30, ARRAY['30 PC Core i7 / RTX 4060 / RAM 32GB', 'Pen Tablet Wacom Cintiq 16 Display', 'Software Lisensi Blender 3D, Maya, Adobe Creative Cloud', 'Proyektor High Dynamic Range', '2 Unit AC Split 2 PK'], 'Ahmad Afif, M.Kom.', 'Digunakan untuk Praktik Menggambar Digital, Pembuat Aset Game 2D & 3D, dan Desain Karakter Animasi.'),
  ('TIK.201', 'Ruang Kelas Teori TIK.201', 'theoryClass', 2, 'Gedung TIK Utama Lt. 2', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori, seminar, diskusi kelompok, dan presentasi proyek kelas.'),
  ('TIK.202', 'Ruang Kelas Teori TIK.202', 'theoryClass', 2, 'Gedung TIK Utama Lt. 2', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori, seminar, diskusi kelompok, dan presentasi proyek kelas.'),
  ('TIK.203', 'Ruang Kelas Teori TIK.203', 'theoryClass', 2, 'Gedung TIK Utama Lt. 2', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori, seminar, diskusi kelompok, dan presentasi proyek kelas.'),
  ('TIK.204', 'Ruang Kelas Teori TIK.204', 'theoryClass', 2, 'Gedung TIK Utama Lt. 2', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori, seminar, diskusi kelompok, dan presentasi proyek kelas.'),
  ('TIK.205', 'Ruang Kelas Teori TIK.205', 'theoryClass', 2, 'Gedung TIK Utama Lt. 2', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori, seminar, diskusi kelompok, dan presentasi proyek kelas.'),
  ('TIK.206', 'Ruang Kelas Teori TIK.206', 'theoryClass', 2, 'Gedung TIK Utama Lt. 2', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori, seminar, diskusi kelompok, dan presentasi proyek kelas.'),
  ('TIK.209', 'Ruang Kelas Teori TIK.209', 'theoryClass', 2, 'Gedung TIK Utama Lt. 2', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori, seminar, diskusi kelompok, dan presentasi proyek kelas.'),
  ('TIK.211', 'Ruang Kelas Teori TIK.211', 'theoryClass', 2, 'Gedung TIK Utama Lt. 2', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori, seminar, diskusi kelompok, dan presentasi proyek kelas.'),
  ('TIK.212', 'Ruang Kelas Teori TIK.212', 'theoryClass', 2, 'Gedung TIK Utama Lt. 2', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori, seminar, diskusi kelompok, dan presentasi proyek kelas.'),
  ('TIK.213', 'Ruang Kelas Teori TIK.213', 'theoryClass', 2, 'Gedung TIK Utama Lt. 2', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori, seminar, diskusi kelompok, dan presentasi proyek kelas.'),
  ('TIK.214', 'Ruang Kelas Teori TIK.214', 'theoryClass', 2, 'Gedung TIK Utama Lt. 2', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori, seminar, diskusi kelompok, dan presentasi proyek kelas.'),
  ('TIK.301', 'Ruang Kelas Teori TIK.301', 'theoryClass', 3, 'Gedung TIK Utama Lt. 3', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori lantai 3 untuk mata kuliah inti dan pembekalan materi.'),
  ('TIK.302', 'Ruang Kelas Teori TIK.302', 'theoryClass', 3, 'Gedung TIK Utama Lt. 3', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori lantai 3 untuk mata kuliah inti dan pembekalan materi.'),
  ('TIK.303', 'Ruang Kelas Teori TIK.303', 'theoryClass', 3, 'Gedung TIK Utama Lt. 3', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori lantai 3 untuk mata kuliah inti dan pembekalan materi.'),
  ('TIK.304', 'Ruang Kelas Teori TIK.304', 'theoryClass', 3, 'Gedung TIK Utama Lt. 3', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori lantai 3 untuk mata kuliah inti dan pembekalan materi.'),
  ('TIK.305', 'Ruang Kelas Teori TIK.305', 'theoryClass', 3, 'Gedung TIK Utama Lt. 3', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori lantai 3 untuk mata kuliah inti dan pembekalan materi.'),
  ('TIK.306', 'Ruang Kelas Teori TIK.306', 'theoryClass', 3, 'Gedung TIK Utama Lt. 3', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori lantai 3 untuk mata kuliah inti dan pembekalan materi.'),
  ('TIK.307', 'Ruang Kelas Teori TIK.307', 'theoryClass', 3, 'Gedung TIK Utama Lt. 3', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori lantai 3 untuk mata kuliah inti dan pembekalan materi.'),
  ('TIK.308', 'Ruang Kelas Teori TIK.308', 'theoryClass', 3, 'Gedung TIK Utama Lt. 3', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori lantai 3 untuk mata kuliah inti dan pembekalan materi.'),
  ('TIK.309', 'Ruang Kelas Teori TIK.309', 'theoryClass', 3, 'Gedung TIK Utama Lt. 3', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori lantai 3 untuk mata kuliah inti dan pembekalan materi.'),
  ('TIK.310', 'Ruang Kelas Teori TIK.310', 'theoryClass', 3, 'Gedung TIK Utama Lt. 3', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori lantai 3 untuk mata kuliah inti dan pembekalan materi.'),
  ('TIK.311', 'Ruang Kelas Teori TIK.311', 'theoryClass', 3, 'Gedung TIK Utama Lt. 3', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori lantai 3 untuk mata kuliah inti dan pembekalan materi.'),
  ('TIK.312', 'Ruang Kelas Teori TIK.312', 'theoryClass', 3, 'Gedung TIK Utama Lt. 3', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori lantai 3 untuk mata kuliah inti dan pembekalan materi.'),
  ('TIK.313', 'Ruang Kelas Teori TIK.313', 'theoryClass', 3, 'Gedung TIK Utama Lt. 3', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori lantai 3 untuk mata kuliah inti dan pembekalan materi.'),
  ('TIK.314', 'Ruang Kelas Teori TIK.314', 'theoryClass', 3, 'Gedung TIK Utama Lt. 3', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori lantai 3 untuk mata kuliah inti dan pembekalan materi.'),
  ('TIK.315', 'Ruang Kelas Teori TIK.315', 'theoryClass', 3, 'Gedung TIK Utama Lt. 3', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori lantai 3 untuk mata kuliah inti dan pembekalan materi.'),
  ('TIK.316', 'Ruang Kelas Teori TIK.316', 'theoryClass', 3, 'Gedung TIK Utama Lt. 3', 36, ARRAY['36 Kursi Kuliah Ergonomis', 'Proyektor Ceiling Mounted + Screen 84"', 'Whiteboard Magnetic 2.4m', '2 Unit AC Split 1.5 PK', 'Speaker Dinding & Wireless Microphone', 'WiFi Akses Point Kampus'], 'Staff Pengajaran TIK', 'Ruang perkuliahan teori lantai 3 untuk mata kuliah inti dan pembekalan materi.')
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    type = EXCLUDED.type,
    floor = EXCLUDED.floor,
    building = EXCLUDED.building,
    capacity = EXCLUDED.capacity,
    facilities = EXCLUDED.facilities,
    pic_name = EXCLUDED.pic_name,
    description = EXCLUDED.description;

-- ==============================================================================
-- 11. SEED PETUGAS JAGA RESEPSIONIS / FRONT DESK COUNTER (NAMA & NIP)
-- ==============================================================================
INSERT INTO public.receptionist_officers (id, name, nip, shift_name, shift_hours, role, is_active) VALUES
('officer-01', 'Munawir, S.Kom.', '19880412 201903 1 008', 'Shift Pagi', '07:30 - 13:00 WIB', 'Front Desk Officer & Koordinator Lab', true),
('officer-02', 'Riza Maulana, S.T.', '19910725 202203 1 005', 'Shift Siang', '13:00 - 18:00 WIB', 'Customer Service Specialist & Teknisi Cloud', true),
('officer-03', 'Safriadi, S.T., M.Kom.', '19850214 201404 1 002', 'Shift Penuh', '08:00 - 16:00 WIB', 'Supervisor Operasional PBM & Laboran Senior', true)
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    nip = EXCLUDED.nip,
    shift_name = EXCLUDED.shift_name,
    shift_hours = EXCLUDED.shift_hours,
    role = EXCLUDED.role,
    is_active = EXCLUDED.is_active;

-- ==============================================================================
-- 12. SEED LENGKAP 423 JADWAL ROSTER PBM SEMESTER GASAL 2026/2027
-- ==============================================================================
INSERT INTO public.roster_items (id, study_program, class_name, day, start_session, end_session, start_time, end_time, course_name, lecturer_name, room_code, is_practicum, semester) VALUES
  ('TRMM1A-1', 'TRMM', 'TRMM 1A', 'Senin', 1, 2, '07:30', '09:10', 'Pancasila', 'Hosea Sitepu, M.Pd', 'TIK.309', false, 'Gasal 2026/2027'),
  ('TRMM1A-2', 'TRMM', 'TRMM 1A', 'Senin', 7, 10, '13:30', '17:10', 'Pengembangan Cerita', 'Novira Dwina, SST., M.T.', 'TIK.202', false, 'Gasal 2026/2027'),
  ('TRMM1A-3', 'TRMM', 'TRMM 1A', 'Selasa', 1, 2, '07:30', '09:10', 'Matematika Terapan bidang TI', 'Muhammad Hari Hasibuan, M.Kom.', 'TIK.306', false, 'Gasal 2026/2027'),
  ('TRMM1A-4', 'TRMM', 'TRMM 1A', 'Selasa', 5, 8, '11:10', '15:10', 'Menyimak dan Berbicara Academik', 'Mahlil, S.Pd., M.A', 'TIK.212', false, 'Gasal 2026/2027'),
  ('TRMM1A-5', 'TRMM', 'TRMM 1A', 'Rabu', 1, 4, '07:30', '11:10', 'Algorithma dan Struktur Data', 'Safriadi ST, M.Kom.', 'TIK.204', false, 'Gasal 2026/2027'),
  ('TRMM1A-6', 'TRMM', 'TRMM 1A', 'Rabu', 5, 8, '11:10', '15:10', 'Pengantar Teknologi Multimedia', 'Nanda Saputri, SST., M.T.', 'TIK.205', false, 'Gasal 2026/2027'),
  ('TRMM1A-7', 'TRMM', 'TRMM 1A', 'Kamis', 1, 5, '07:30', '12:00', 'Praktik Menggambar Digital', 'Ahmad Afif, M. Kom.', 'TDC-308', true, 'Gasal 2026/2027'),
  ('TRMM1A-8', 'TRMM', 'TRMM 1A', 'Kamis', 7, 8, '13:30', '15:10', 'Pemikiran Kritis dan Kreatif', 'Dr. Hilmi, SE., MM., CBA., CTAM.', 'TIK.312', false, 'Gasal 2026/2027'),
  ('TRMM1A-9', 'TRMM', 'TRMM 1A', 'Jumat', 1, 5, '07:30', '12:00', 'Praktik Grafika dan Pengolahan Citra', 'Novira Dwina, SST., M.T.', 'TIK.204', true, 'Gasal 2026/2027'),
  ('TRMM1A-10', 'TRMM', 'TRMM 1A', 'Jumat', 7, 10, '13:30', '17:10', 'Ide Kreatif', 'Umri Erdiansyah, S.Kom., M.Kom.', 'TIK.203', false, 'Gasal 2026/2027'),
  ('TRMM1B-1', 'TRMM', 'TRMM 1B', 'Senin', 1, 4, '07:30', '11:10', 'Pengembangan Cerita', 'Novira Dwina, SST., M.T.', 'TIK.202', false, 'Gasal 2026/2027'),
  ('TRMM1B-2', 'TRMM', 'TRMM 1B', 'Senin', 5, 8, '11:10', '15:10', 'Menyimak dan Berbicara Academik', 'Mahlil, S.Pd., M.A', 'TIK.310', false, 'Gasal 2026/2027'),
  ('TRMM1B-3', 'TRMM', 'TRMM 1B', 'Selasa', 1, 4, '07:30', '11:10', 'Ide Kreatif', 'Umri Erdiansyah, S.Kom., M.Kom.', 'TIK.203', false, 'Gasal 2026/2027'),
  ('TRMM1B-4', 'TRMM', 'TRMM 1B', 'Selasa', 5, 6, '11:10', '12:50', 'Pemikiran Kritis dan Kreatif', 'Dr. Hilmi, SE., MM., CBA., CTAM.', 'TIK.309', false, 'Gasal 2026/2027'),
  ('TRMM1B-5', 'TRMM', 'TRMM 1B', 'Rabu', 1, 4, '07:30', '11:10', 'Pengantar Teknologi Multimedia', 'Nanda Saputri, SST., M.T.', 'TIK.205', false, 'Gasal 2026/2027'),
  ('TRMM1B-6', 'TRMM', 'TRMM 1B', 'Rabu', 5, 8, '11:10', '15:10', 'Algorithma dan Struktur Data', 'Safriadi ST, M.Kom.', 'TIK.204', false, 'Gasal 2026/2027'),
  ('TRMM1B-7', 'TRMM', 'TRMM 1B', 'Kamis', 1, 2, '07:30', '09:10', 'Matematika Terapan bidang TI', 'Muhammad Hari Hasibuan, M.Kom.', 'TIK.306', false, 'Gasal 2026/2027'),
  ('TRMM1B-8', 'TRMM', 'TRMM 1B', 'Kamis', 7, 8, '13:30', '15:10', 'Pancasila', 'Hosea Sitepu, M.Pd', 'TIK.306', false, 'Gasal 2026/2027'),
  ('TRMM1B-9', 'TRMM', 'TRMM 1B', 'Jumat', 1, 5, '07:30', '12:00', 'Praktik Menggambar Digital', 'Ahmad Afif, M. Kom.', 'TDC-308', true, 'Gasal 2026/2027'),
  ('TRMM1B-10', 'TRMM', 'TRMM 1B', 'Jumat', 7, 10, '13:30', '17:10', 'Praktik Grafika dan Pengolahan Citra', 'Novira Dwina, SST., M.T.', 'TIK.206', true, 'Gasal 2026/2027'),
  ('TRMM1C-1', 'TRMM', 'TRMM 1C', 'Senin', 1, 4, '07:30', '11:10', 'Menyimak dan Berbicara Academik', 'Mahlil, S.Pd., M.A', 'TIK.213', false, 'Gasal 2026/2027'),
  ('TRMM1C-2', 'TRMM', 'TRMM 1C', 'Senin', 5, 9, '11:10', '16:00', 'Praktik Grafika dan Pengolahan Citra', 'Ahmad Afif, M. Kom.', 'TIK.204', true, 'Gasal 2026/2027'),
  ('TRMM1C-3', 'TRMM', 'TRMM 1C', 'Selasa', 1, 4, '07:30', '11:10', 'Algorithma dan Struktur Data', 'Safriadi ST, M.Kom.', 'TIK.204', false, 'Gasal 2026/2027'),
  ('TRMM1C-4', 'TRMM', 'TRMM 1C', 'Selasa', 5, 6, '11:10', '12:50', 'Pancasila', 'Hosea Sitepu, M.Pd', 'TIK.313', false, 'Gasal 2026/2027'),
  ('TRMM1C-5', 'TRMM', 'TRMM 1C', 'Selasa', 7, 10, '13:30', '17:10', 'Pengembangan Cerita', 'Novira Dwina, SST., M.T.', 'TIK.203', false, 'Gasal 2026/2027'),
  ('TRMM1C-6', 'TRMM', 'TRMM 1C', 'Rabu', 1, 5, '07:30', '12:00', 'Praktik Menggambar Digital', 'Ahmad Afif, M. Kom.', 'TDC-308', true, 'Gasal 2026/2027'),
  ('TRMM1C-7', 'TRMM', 'TRMM 1C', 'Rabu', 6, 9, '12:00', '16:00', 'Ide Kreatif', 'Muhammad Hari Hasibuan, M.Kom.', 'TIK.203', false, 'Gasal 2026/2027'),
  ('TRMM1C-8', 'TRMM', 'TRMM 1C', 'Kamis', 5, 6, '11:10', '12:50', 'Pemikiran Kritis dan Kreatif', 'Zulkarnaini, SE.,M.Si.Ak.CA', 'TIK.301', false, 'Gasal 2026/2027'),
  ('TRMM1C-9', 'TRMM', 'TRMM 1C', 'Kamis', 7, 8, '13:30', '15:10', 'Matematika Terapan bidang TI', 'Ir. T. Dany Dhaifullah, S.T., M.T.', 'TIK.307', false, 'Gasal 2026/2027'),
  ('TRMM1C-10', 'TRMM', 'TRMM 1C', 'Jumat', 1, 4, '07:30', '11:10', 'Pengantar Teknologi Multimedia', 'Nanda Saputri, SST., M.T.', 'TIK.205', false, 'Gasal 2026/2027'),
  ('TRMM2A-1', 'TRMM', 'TRMM 2A', 'Senin', 1, 2, '07:30', '09:10', 'Aljabar Linear Dasar', 'Nazira Suha Al Bakri, S.T., M.T.', 'TIK.307', false, 'Gasal 2026/2027'),
  ('TRMM2A-2', 'TRMM', 'TRMM 2A', 'Senin', 5, 9, '11:10', '16:00', 'Pengantar Proyek', 'Muhammad Nasir, ST. MT.', 'TIK.314', false, 'Gasal 2026/2027'),
  ('TRMM2A-3', 'TRMM', 'TRMM 2A', 'Selasa', 1, 3, '07:30', '10:00', 'Praktik Photografi', 'Fachri Yanuar Rudi F, S.ST., M.T.', 'TDC-203', true, 'Gasal 2026/2027'),
  ('TRMM2A-4', 'TRMM', 'TRMM 2A', 'Selasa', 4, 6, '10:20', '12:50', 'Praktik Database dan Aplikasi', 'Muhammad Hari Hasibuan, M.Kom.', 'TIK.206', true, 'Gasal 2026/2027'),
  ('TRMM2A-5', 'TRMM', 'TRMM 2A', 'Selasa', 7, 10, '13:30', '17:10', 'Rekayasa Video dan Audio', 'Riwanul Nasron, S.T.,M.T.', 'TIK.202', false, 'Gasal 2026/2027'),
  ('TRMM2A-6', 'TRMM', 'TRMM 2A', 'Rabu', 1, 4, '07:30', '11:10', 'Desain Komunikasi Visual', 'Muhammad Hari Hasibuan, M.Kom.', 'TDC-306', false, 'Gasal 2026/2027'),
  ('TRMM2A-7', 'TRMM', 'TRMM 2A', 'Rabu', 7, 10, '13:30', '17:10', 'Desain Pengembangan Game', 'Fachri Yanuar Rudi F, S.ST., M.T.', 'TIK.206', false, 'Gasal 2026/2027'),
  ('TRMM2A-8', 'TRMM', 'TRMM 2A', 'Kamis', 1, 4, '07:30', '11:10', 'Bahasa Inggris untuk Karir Akademik', 'Mahlil, S.Pd., M.A', 'TIK.314', false, 'Gasal 2026/2027'),
  ('TRMM2A-9', 'TRMM', 'TRMM 2A', 'Kamis', 7, 10, '13:30', '17:10', 'Pembuat Aset 2D', 'Ilham Safar, SST., M.Kom', 'TDC-308', false, 'Gasal 2026/2027'),
  ('TRMM2A-10', 'TRMM', 'TRMM 2A', 'Jumat', 1, 2, '07:30', '09:10', 'Bahasa Indonesia', 'Dra. Jamilah, M.Pd', 'TIK.211', false, 'Gasal 2026/2027'),
  ('TRMM2A-11', 'TRMM', 'TRMM 2A', 'Jumat', 7, 10, '13:30', '17:10', 'Pembuat Aset 3D', 'Nanda Saputri, SST., M.T.', 'TDC-308', false, 'Gasal 2026/2027'),
  ('TRMM2B-1', 'TRMM', 'TRMM 2B', 'Senin', 1, 4, '07:30', '11:10', 'Desain Komunikasi Visual', 'Muhammad Hari Hasibuan, M.Kom.', 'TDC-306', false, 'Gasal 2026/2027'),
  ('TRMM2B-2', 'TRMM', 'TRMM 2B', 'Senin', 5, 6, '11:10', '12:50', 'Aljabar Linear Dasar', 'Nazira Suha Al Bakri, S.T., M.T.', 'TIK.309', false, 'Gasal 2026/2027'),
  ('TRMM2B-3', 'TRMM', 'TRMM 2B', 'Senin', 7, 10, '13:30', '17:10', 'Pembuat Aset 3D', 'Nanda Saputri, SST., M.T.', 'TDC-308', false, 'Gasal 2026/2027'),
  ('TRMM2B-4', 'TRMM', 'TRMM 2B', 'Selasa', 1, 5, '07:30', '12:00', 'Pengantar Proyek', 'Mursyidah, S.S.T., M.T.', 'TIK.304', false, 'Gasal 2026/2027'),
  ('TRMM2B-5', 'TRMM', 'TRMM 2B', 'Selasa', 6, 8, '12:00', '15:10', 'Praktik Photografi', 'Fachri Yanuar Rudi F, S.ST., M.T.', 'TDC-203', true, 'Gasal 2026/2027'),
  ('TRMM2B-6', 'TRMM', 'TRMM 2B', 'Rabu', 1, 4, '07:30', '11:10', 'Bahasa Inggris untuk Karir Akademik', 'Mahlil, S.Pd., M.A', 'TIK.316', false, 'Gasal 2026/2027'),
  ('TRMM2B-7', 'TRMM', 'TRMM 2B', 'Rabu', 5, 6, '11:10', '12:50', 'Bahasa Indonesia', 'Dra. Jamilah, M.Pd', 'TIK.209', false, 'Gasal 2026/2027'),
  ('TRMM2B-8', 'TRMM', 'TRMM 2B', 'Rabu', 7, 10, '13:30', '17:10', 'Pembuat Aset 2D', 'Ilham Safar, SST., M.Kom', 'TDC-308', false, 'Gasal 2026/2027'),
  ('TRMM2B-9', 'TRMM', 'TRMM 2B', 'Kamis', 1, 4, '07:30', '11:10', 'Rekayasa Video dan Audio', 'Riwanul Nasron, S.T.,M.T.', 'TIK.203', false, 'Gasal 2026/2027'),
  ('TRMM2B-10', 'TRMM', 'TRMM 2B', 'Kamis', 7, 10, '13:30', '17:10', 'Desain Pengembangan Game', 'Fachri Yanuar Rudi F, S.ST., M.T.', 'TIK.206', false, 'Gasal 2026/2027'),
  ('TRMM2B-11', 'TRMM', 'TRMM 2B', 'Jumat', 1, 3, '07:30', '10:00', 'Praktik Database dan Aplikasi', 'Muhammad Hari Hasibuan, M.Kom.', 'TIK.206', true, 'Gasal 2026/2027'),
  ('TRMM2C-1', 'TRMM', 'TRMM 2C', 'Senin', 1, 4, '07:30', '11:10', 'Pembuat Aset 2D', 'Ilham Safar, SST., M.Kom', 'TDC-308', false, 'Gasal 2026/2027'),
  ('TRMM2C-2', 'TRMM', 'TRMM 2C', 'Senin', 7, 10, '13:30', '17:10', 'Rekayasa Video dan Audio', 'Riwanul Nasron, S.T.,M.T.', 'TIK.205', false, 'Gasal 2026/2027'),
  ('TRMM2C-3', 'TRMM', 'TRMM 2C', 'Selasa', 1, 4, '07:30', '11:10', 'Pembuat Aset 3D', 'Nanda Saputri, SST., M.T.', 'TDC-308', false, 'Gasal 2026/2027'),
  ('TRMM2C-4', 'TRMM', 'TRMM 2C', 'Selasa', 7, 10, '13:30', '17:10', 'Desain Komunikasi Visual', 'Muhammad Hari Hasibuan, M.Kom.', 'TDC-306', false, 'Gasal 2026/2027'),
  ('TRMM2C-5', 'TRMM', 'TRMM 2C', 'Rabu', 1, 2, '07:30', '09:10', 'Bahasa Indonesia', 'Dra. Jamilah, M.Pd', 'TIK.213', false, 'Gasal 2026/2027'),
  ('TRMM2C-6', 'TRMM', 'TRMM 2C', 'Rabu', 5, 6, '11:10', '12:50', 'Aljabar Linear Dasar', 'Nazira Suha Al Bakri, S.T., M.T.', 'TIK.301', false, 'Gasal 2026/2027'),
  ('TRMM2C-7', 'TRMM', 'TRMM 2C', 'Rabu', 7, 10, '13:30', '17:10', 'Bahasa Inggris untuk Karir Akademik', 'Mahlil, S.Pd., M.A', 'TIK.305', false, 'Gasal 2026/2027'),
  ('TRMM2C-8', 'TRMM', 'TRMM 2C', 'Kamis', 1, 4, '07:30', '11:10', 'Desain Pengembangan Game', 'Fachri Yanuar Rudi F, S.ST., M.T.', 'TIK.206', false, 'Gasal 2026/2027'),
  ('TRMM2C-9', 'TRMM', 'TRMM 2C', 'Kamis', 7, 10, '13:30', '17:10', 'Praktik Database dan Aplikasi', 'Ahmad Afif, M. Kom.', 'TIK.204', true, 'Gasal 2026/2027'),
  ('TRMM2C-10', 'TRMM', 'TRMM 2C', 'Jumat', 1, 3, '07:30', '10:00', 'Praktik Photografi', 'Fachri Yanuar Rudi F, S.ST., M.T.', 'TDC-203', true, 'Gasal 2026/2027'),
  ('TRMM2C-11', 'TRMM', 'TRMM 2C', 'Jumat', 7, 11, '13:30', '18:00', 'Pengantar Proyek', 'Muhammad Hari Hasibuan, M.Kom.', 'TIK.312', false, 'Gasal 2026/2027'),
  ('TRMM3A-1', 'TRMM', 'TRMM 3A', 'Senin', 1, 4, '07:30', '11:10', 'Dasar-dasar Jaringan', 'Guntur Syahputra, S. Kom., M. Kom.', 'TIK.204', false, 'Gasal 2026/2027'),
  ('TRMM3A-2', 'TRMM', 'TRMM 3A', 'Senin', 7, 11, '13:30', '18:00', 'Praktik Produksi Pasca Animasi', 'FYR / AND', 'TIK.206', true, 'Gasal 2026/2027'),
  ('TRMM3A-3', 'TRMM', 'TRMM 3A', 'Selasa', 1, 5, '07:30', '12:00', 'Multimedia Digital dan Interaktif', 'Novira Dwina, SST., M.T.', 'TIK.202', false, 'Gasal 2026/2027'),
  ('TRMM3A-4', 'TRMM', 'TRMM 3A', 'Rabu', 1, 5, '07:30', '12:00', 'Proyek Inovasi Produk', 'FYR / NDW', 'TIK.203', false, 'Gasal 2026/2027'),
  ('TRMM3A-5', 'TRMM', 'TRMM 3A', 'Kamis', 1, 4, '07:30', '11:10', 'Paradigma Sistem di Bidang IT', 'Ilham Safar, SST., M.Kom', 'TIK.316', false, 'Gasal 2026/2027'),
  ('TRMM3A-6', 'TRMM', 'TRMM 3A', 'Kamis', 5, 8, '11:10', '15:10', 'Praktik Produksi Podcast', 'UME / FSB', 'TDC-202', true, 'Gasal 2026/2027'),
  ('TRMM3A-7', 'TRMM', 'TRMM 3A', 'Kamis', 8, 11, '14:20', '18:00', 'Pengembangan Multimedia Seluler', 'Safriadi ST, M.Kom.', 'TIK.211', false, 'Gasal 2026/2027'),
  ('TRMM3A-8', 'TRMM', 'TRMM 3A', 'Jumat', 1, 2, '07:30', '09:10', 'Tata Kelola IT', 'Riwanul Nasron, S.T.,M.T.', 'TIK.310', false, 'Gasal 2026/2027'),
  ('TRMM3A-9', 'TRMM', 'TRMM 3A', 'Jumat', 7, 10, '13:30', '17:10', 'Gamifikasi', 'Mursyidah, S.S.T., M.T.', 'TIK.205', false, 'Gasal 2026/2027'),
  ('TRMM3B-1', 'TRMM', 'TRMM 3B', 'Senin', 1, 5, '07:30', '12:00', 'Praktik Produksi Pasca Animasi', 'FYR / AND', 'TIK.206', true, 'Gasal 2026/2027'),
  ('TRMM3B-2', 'TRMM', 'TRMM 3B', 'Senin', 7, 10, '13:30', '17:10', 'Dasar-dasar Jaringan', 'Guntur Syahputra, S. Kom., M. Kom.', 'TIK.109', false, 'Gasal 2026/2027'),
  ('TRMM3B-3', 'TRMM', 'TRMM 3B', 'Selasa', 1, 2, '07:30', '09:10', 'Tata Kelola IT', 'Riwanul Nasron, S.T.,M.T.', 'TIK.213', false, 'Gasal 2026/2027'),
  ('TRMM3B-4', 'TRMM', 'TRMM 3B', 'Selasa', 7, 11, '13:30', '18:00', 'Gamifikasi', 'Mursyidah, S.S.T., M.T.', 'TIK.205', false, 'Gasal 2026/2027'),
  ('TRMM3B-5', 'TRMM', 'TRMM 3B', 'Rabu', 1, 4, '07:30', '11:10', 'Paradigma Sistem di Bidang IT', 'Ilham Safar, SST., M.Kom', 'TIK.314', false, 'Gasal 2026/2027'),
  ('TRMM3B-6', 'TRMM', 'TRMM 3B', 'Rabu', 7, 11, '13:30', '18:00', 'Multimedia Digital dan Interaktif', 'Novira Dwina, SST., M.T.', 'TIK.202', false, 'Gasal 2026/2027'),
  ('TRMM3B-7', 'TRMM', 'TRMM 3B', 'Kamis', 1, 5, '07:30', '12:00', 'Praktik Produksi Podcast', 'UME / FSB', 'TDC-202', true, 'Gasal 2026/2027'),
  ('TRMM3B-8', 'TRMM', 'TRMM 3B', 'Kamis', 7, 11, '13:30', '18:00', 'Proyek Inovasi Produk', 'MSD / NSP', 'TIK.203', false, 'Gasal 2026/2027'),
  ('TRMM3B-9', 'TRMM', 'TRMM 3B', 'Jumat', 1, 4, '07:30', '11:10', 'Pengembangan Multimedia Seluler', 'Safriadi ST, M.Kom.', 'TIK.212', false, 'Gasal 2026/2027'),
  ('TRMM3C-1', 'TRMM', 'TRMM 3C', 'Senin', 1, 4, '07:30', '11:10', 'Gamifikasi', 'Mursyidah, S.S.T., M.T.', 'TIK.205', false, 'Gasal 2026/2027'),
  ('TRMM3C-2', 'TRMM', 'TRMM 3C', 'Senin', 6, 7, '12:00', '14:20', 'Tata Kelola IT', 'Dr.Rahmad Hidayat, S.Kom., M.Cs', 'TIK.308', false, 'Gasal 2026/2027'),
  ('TRMM3C-3', 'TRMM', 'TRMM 3C', 'Selasa', 1, 4, '07:30', '11:10', 'Paradigma Sistem di Bidang IT', 'Ilham Safar, SST., M.Kom', 'TIK.314', false, 'Gasal 2026/2027'),
  ('TRMM3C-4', 'TRMM', 'TRMM 3C', 'Selasa', 5, 8, '11:10', '15:10', 'Pengembangan Multimedia Seluler', 'Safriadi ST, M.Kom.', 'TIK.305', false, 'Gasal 2026/2027'),
  ('TRMM3C-5', 'TRMM', 'TRMM 3C', 'Rabu', 1, 5, '07:30', '12:00', 'Praktik Produksi Pasca Animasi', 'UME / AND', 'TIK.206', true, 'Gasal 2026/2027'),
  ('TRMM3C-6', 'TRMM', 'TRMM 3C', 'Rabu', 8, 11, '14:20', '18:00', 'Praktik Produksi Podcast', 'UME / MUN', 'TDC-202', true, 'Gasal 2026/2027'),
  ('TRMM3C-7', 'TRMM', 'TRMM 3C', 'Kamis', 7, 11, '13:30', '18:00', 'Multimedia Digital dan Interaktif', 'Riwanul Nasron, S.T.,M.T.', 'TIK.209', false, 'Gasal 2026/2027'),
  ('TRMM3C-8', 'TRMM', 'TRMM 3C', 'Jumat', 1, 5, '07:30', '12:00', 'Proyek Inovasi Produk', 'UME / ASW', 'TIK.203', false, 'Gasal 2026/2027'),
  ('TRMM3C-9', 'TRMM', 'TRMM 3C', 'Jumat', 8, 11, '14:20', '18:00', 'Dasar-dasar Jaringan', 'Guntur Syahputra, S. Kom., M. Kom.', 'TIK.202', false, 'Gasal 2026/2027'),
  ('TRMM4A-1', 'TRMM', 'TRMM 4A', 'Senin', 1, 4, '07:30', '11:10', 'Edit Video dan Audio', 'Muhammad Nasir, ST. MT.', 'TIK.203', false, 'Gasal 2026/2027'),
  ('TRMM4A-2', 'TRMM', 'TRMM 4A', 'Senin', 7, 11, '13:30', '18:00', 'Periklanan', 'Umri Erdiansyah, S.Kom., M.Kom.', 'TIK.203', false, 'Gasal 2026/2027'),
  ('TRMM4A-3', 'TRMM', 'TRMM 4A', 'Selasa', 1, 4, '07:30', '11:10', 'Pengembangan Web Berbasis Multimedia', 'Guntur Syahputra, S. Kom., M. Kom.', 'TIK.205', false, 'Gasal 2026/2027'),
  ('TRMM4A-4', 'TRMM', 'TRMM 4A', 'Selasa', 5, 6, '11:10', '12:50', 'Etika profesional di bidang TIK', 'Riwanul Nasron, S.T.,M.T.', 'TIK.312', false, 'Gasal 2026/2027'),
  ('TRMM4A-5', 'TRMM', 'TRMM 4A', 'Rabu', 7, 11, '13:30', '18:00', 'Proyek Industri', 'ASW / MIL', 'TIK.211', false, 'Gasal 2026/2027'),
  ('TRMM4A-6', 'TRMM', 'TRMM 4A', 'Kamis', 1, 3, '07:30', '10:00', 'Praktik Game Cerdas', 'Mursyidah, S.S.T., M.T.', 'TIK.104', true, 'Gasal 2026/2027'),
  ('TRMM4A-7', 'TRMM', 'TRMM 4A', 'Kamis', 7, 11, '13:30', '18:00', 'Sinematografi', 'Umri Erdiansyah, S.Kom., M.Kom.', 'TIK.202', false, 'Gasal 2026/2027'),
  ('TRMM4A-8', 'TRMM', 'TRMM 4A', 'Jumat', 1, 2, '07:30', '09:10', 'Game Cerdas', 'Mursyidah, S.S.T., M.T.', 'TIK.303', false, 'Gasal 2026/2027'),
  ('TRMM4A-9', 'TRMM', 'TRMM 4A', 'Jumat', 3, 4, '09:10', '11:10', 'Teknologi Sistem Terintegrasi', 'Guntur Syahputra, S. Kom., M. Kom.', 'TIK.308', false, 'Gasal 2026/2027'),
  ('TRMM4A-10', 'TRMM', 'TRMM 4A', 'Jumat', 7, 11, '13:30', '18:00', 'Pengembangan Konten Digital', 'Ilham Safar, SST., M.Kom', 'TIK.103', false, 'Gasal 2026/2027'),
  ('TRMM4B-1', 'TRMM', 'TRMM 4B', 'Senin', 1, 4, '07:30', '11:10', 'Sinematografi', 'Umri Erdiansyah, S.Kom., M.Kom.', 'TDC-203', false, 'Gasal 2026/2027'),
  ('TRMM4B-2', 'TRMM', 'TRMM 4B', 'Senin', 5, 6, '11:10', '12:50', 'Game Cerdas', 'Mursyidah, S.S.T., M.T.', 'TIK.301', false, 'Gasal 2026/2027'),
  ('TRMM4B-3', 'TRMM', 'TRMM 4B', 'Selasa', 7, 11, '13:30', '18:00', 'Periklanan', 'Umri Erdiansyah, S.Kom., M.Kom.', 'TDC-308', false, 'Gasal 2026/2027'),
  ('TRMM4B-4', 'TRMM', 'TRMM 4B', 'Rabu', 1, 3, '07:30', '10:00', 'Praktik Game Cerdas', 'Mursyidah, S.S.T., M.T.', 'TIK.103', true, 'Gasal 2026/2027'),
  ('TRMM4B-5', 'TRMM', 'TRMM 4B', 'Rabu', 4, 8, '10:20', '15:10', 'Proyek Industri', 'ASW / MIL', 'TIK.312', false, 'Gasal 2026/2027'),
  ('TRMM4B-6', 'TRMM', 'TRMM 4B', 'Rabu', 9, 11, '15:10', '18:00', 'Teknologi Sistem Terintegrasi', 'Guntur Syahputra, S. Kom., M. Kom.', 'TIK.209', false, 'Gasal 2026/2027'),
  ('TRMM4B-7', 'TRMM', 'TRMM 4B', 'Kamis', 1, 4, '07:30', '11:10', 'Pengembangan Web Berbasis Multimedia', 'Guntur Syahputra, S. Kom., M. Kom.', 'TIK.205', false, 'Gasal 2026/2027'),
  ('TRMM4B-8', 'TRMM', 'TRMM 4B', 'Kamis', 8, 11, '14:20', '18:00', 'Edit Video dan Audio', 'Muhammad Nasir, ST. MT.', 'TDC-202', false, 'Gasal 2026/2027'),
  ('TRMM4B-9', 'TRMM', 'TRMM 4B', 'Jumat', 1, 4, '07:30', '11:10', 'Pengembangan Konten Digital', 'Ilham Safar, SST., M.Kom', 'TIK.202', false, 'Gasal 2026/2027'),
  ('TRMM4B-10', 'TRMM', 'TRMM 4B', 'Jumat', 8, 9, '14:20', '16:00', 'Etika profesional di bidang TIK', 'Riwanul Nasron, S.T.,M.T.', 'TIK.310', false, 'Gasal 2026/2027'),
  ('TRKJ1A-1', 'TRKJ', 'TRKJ 1A', 'Senin', 4, 8, '10:20', '15:10', 'Praktik Algorithma dan Struktur Data', 'Indrawati, SST., MT.', 'TIK.106', true, 'Gasal 2026/2027'),
  ('TRKJ1A-2', 'TRKJ', 'TRKJ 1A', 'Selasa', 1, 4, '07:30', '11:10', 'Menyimak dan Berbicara Academik', 'Mahlil, S.Pd., M.A', 'TIK.313', false, 'Gasal 2026/2027'),
  ('TRKJ1A-3', 'TRKJ', 'TRKJ 1A', 'Selasa', 5, 8, '11:10', '15:10', 'Pengantar Teknologi Informasi', 'Nanda Saputri, SST., M.T.', 'TIK.209', false, 'Gasal 2026/2027'),
  ('TRKJ1A-4', 'TRKJ', 'TRKJ 1A', 'Rabu', 1, 5, '07:30', '12:00', 'Praktik Dasar-dasar Jaringan', 'Afla Nevrisa, S.Kom., M.Kom.', 'TIK.107', true, 'Gasal 2026/2027'),
  ('TRKJ1A-5', 'TRKJ', 'TRKJ 1A', 'Rabu', 7, 8, '13:30', '15:10', 'Dasar-dasar Jaringan', 'Afla Nevrisa, S.Kom., M.Kom.', 'TIK.308', false, 'Gasal 2026/2027'),
  ('TRKJ1A-6', 'TRKJ', 'TRKJ 1A', 'Kamis', 1, 2, '07:30', '09:10', 'Algorithma dan Struktur Data', 'Indrawati, SST., MT.', 'TIK.209', false, 'Gasal 2026/2027'),
  ('TRKJ1A-7', 'TRKJ', 'TRKJ 1A', 'Kamis', 3, 4, '09:10', '11:10', 'Matematika Terapan Untuk TIK', 'Erika Fahmi Br Ginting, S. Kom., M,Kom', 'TIK.301', false, 'Gasal 2026/2027'),
  ('TRKJ1A-8', 'TRKJ', 'TRKJ 1A', 'Kamis', 5, 6, '11:10', '12:50', 'Pendidikan Pancasila', 'Hosea Sitepu, M.Pd', 'TIK.315', false, 'Gasal 2026/2027'),
  ('TRKJ1A-9', 'TRKJ', 'TRKJ 1A', 'Jumat', 1, 5, '07:30', '12:00', 'Praktik Sistem Operasi', 'Firdaus Muttaqin, S.T., M.T.', 'TIK.101', true, 'Gasal 2026/2027'),
  ('TRKJ1A-10', 'TRKJ', 'TRKJ 1A', 'Jumat', 8, 11, '14:20', '18:00', 'Dasar-dasar Elektronik untuk IoT', 'Ir. Muhammad Azzahari, SST., MT.', 'TIK.111', false, 'Gasal 2026/2027'),
  ('TRKJ1B-1', 'TRKJ', 'TRKJ 1B', 'Senin', 1, 2, '07:30', '09:10', 'Matematika Terapan Untuk TIK', 'Husaini, S.Si., M.IT', 'TIK.305', false, 'Gasal 2026/2027'),
  ('TRKJ1B-2', 'TRKJ', 'TRKJ 1B', 'Senin', 3, 5, '09:10', '12:00', 'Pendidikan Pancasila', 'Hosea Sitepu, M.Pd', 'TIK.305', false, 'Gasal 2026/2027'),
  ('TRKJ1B-3', 'TRKJ', 'TRKJ 1B', 'Senin', 7, 8, '13:30', '15:10', 'Algorithma dan Struktur Data', 'Safriadi ST, M.Kom.', 'TIK.211', false, 'Gasal 2026/2027'),
  ('TRKJ1B-4', 'TRKJ', 'TRKJ 1B', 'Selasa', 1, 5, '07:30', '12:00', 'Praktik Sistem Operasi', 'Firdaus Muttaqin, S.T., M.T.', 'TIK.302', true, 'Gasal 2026/2027'),
  ('TRKJ1B-5', 'TRKJ', 'TRKJ 1B', 'Selasa', 6, 7, '12:00', '14:20', 'Dasar-dasar Jaringan', 'Afla Nevrisa, S.Kom., M.Kom.', 'TIK.301', false, 'Gasal 2026/2027'),
  ('TRKJ1B-6', 'TRKJ', 'TRKJ 1B', 'Selasa', 8, 11, '14:20', '18:00', 'Pengantar Teknologi Informasi', 'Afla Nevrisa, S.Kom., M.Kom.', 'TIK.301', false, 'Gasal 2026/2027'),
  ('TRKJ1B-7', 'TRKJ', 'TRKJ 1B', 'Rabu', 4, 7, '10:20', '14:20', 'Menyimak dan Berbicara Academik', 'Rizqina Barophon, S.Pd., M.Pd.', 'TIK.304', false, 'Gasal 2026/2027'),
  ('TRKJ1B-8', 'TRKJ', 'TRKJ 1B', 'Kamis', 1, 5, '07:30', '12:00', 'Praktik Dasar-dasar Jaringan', 'Afla Nevrisa, S.Kom., M.Kom.', 'TIK.107', true, 'Gasal 2026/2027'),
  ('TRKJ1B-9', 'TRKJ', 'TRKJ 1B', 'Kamis', 7, 10, '13:30', '17:10', 'Dasar-dasar Elektronik untuk IoT', 'Ir. Muhammad Azzahari, SST., MT.', 'TIK.112', false, 'Gasal 2026/2027'),
  ('TRKJ1B-10', 'TRKJ', 'TRKJ 1B', 'Jumat', 7, 11, '13:30', '18:00', 'Praktik Algorithma dan Struktur Data', 'Rika Rahmawati, M.Kom.', 'TIK.106', true, 'Gasal 2026/2027'),
  ('TRKJ1C-1', 'TRKJ', 'TRKJ 1C', 'Senin', 1, 4, '07:30', '11:10', 'Pengantar Teknologi Informasi', 'Afla Nevrisa, S.Kom., M.Kom.', 'TIK.209', false, 'Gasal 2026/2027'),
  ('TRKJ1C-2', 'TRKJ', 'TRKJ 1C', 'Senin', 5, 8, '11:10', '15:10', 'Menyimak dan Berbicara Academik', 'Rizqina Barophon, S.Pd., M.Pd.', 'TIK.306', false, 'Gasal 2026/2027'),
  ('TRKJ1C-3', 'TRKJ', 'TRKJ 1C', 'Selasa', 1, 5, '07:30', '12:00', 'Praktik Dasar-dasar Jaringan', 'Ir. Muhammad Azzahari, SST., MT.', 'TIK.107', true, 'Gasal 2026/2027'),
  ('TRKJ1C-4', 'TRKJ', 'TRKJ 1C', 'Selasa', 6, 7, '12:00', '14:20', 'Matematika Terapan Untuk TIK', 'Erika Fahmi Br Ginting, S. Kom., M,Kom', 'TIK.211', false, 'Gasal 2026/2027'),
  ('TRKJ1C-5', 'TRKJ', 'TRKJ 1C', 'Rabu', 7, 11, '13:30', '18:00', 'Praktik Sistem Operasi', 'Firdaus Muttaqin, S.T., M.T.', 'TIK.109', true, 'Gasal 2026/2027'),
  ('TRKJ1C-6', 'TRKJ', 'TRKJ 1C', 'Kamis', 1, 2, '07:30', '09:10', 'Pendidikan Pancasila', 'Hosea Sitepu, M.Pd', 'TIK.304', false, 'Gasal 2026/2027'),
  ('TRKJ1C-7', 'TRKJ', 'TRKJ 1C', 'Kamis', 3, 4, '09:10', '11:10', 'Dasar-dasar Jaringan', 'Ir. Muhammad Azzahari, SST., MT.', 'TIK.309', false, 'Gasal 2026/2027'),
  ('TRKJ1C-8', 'TRKJ', 'TRKJ 1C', 'Kamis', 5, 6, '11:10', '12:50', 'Algorithma dan Struktur Data', 'Zulfan Khairil S. ST., M.Eng.', 'TIK.209', false, 'Gasal 2026/2027'),
  ('TRKJ1C-9', 'TRKJ', 'TRKJ 1C', 'Jumat', 1, 4, '07:30', '11:10', 'Dasar-dasar Elektronik untuk IoT', 'Rika Rahmawati, M.Kom.', 'TIK.112', false, 'Gasal 2026/2027'),
  ('TRKJ1C-10', 'TRKJ', 'TRKJ 1C', 'Jumat', 7, 11, '13:30', '18:00', 'Praktik Algorithma dan Struktur Data', 'Zulfan Khairil S. ST., M.Eng.', 'TIK.209', true, 'Gasal 2026/2027'),
  ('TRKJ1D-1', 'TRKJ', 'TRKJ 1D', 'Senin', 1, 2, '07:30', '09:10', 'Algorithma dan Struktur Data', 'Indrawati, SST., MT.', 'TIK.212', false, 'Gasal 2026/2027'),
  ('TRKJ1D-2', 'TRKJ', 'TRKJ 1D', 'Senin', 5, 8, '11:10', '15:10', 'Pengantar Teknologi Informasi', 'Afla Nevrisa, S.Kom., M.Kom.', 'TIK.209', false, 'Gasal 2026/2027'),
  ('TRKJ1D-3', 'TRKJ', 'TRKJ 1D', 'Selasa', 1, 2, '07:30', '09:10', 'Matematika Terapan Untuk TIK', 'Erika Fahmi Br Ginting, S. Kom., M,Kom', 'TIK.209', false, 'Gasal 2026/2027'),
  ('TRKJ1D-4', 'TRKJ', 'TRKJ 1D', 'Selasa', 6, 7, '12:00', '14:20', 'Dasar-dasar Jaringan', 'Ir. Muhammad Azzahari, SST., MT.', 'TIK.308', false, 'Gasal 2026/2027'),
  ('TRKJ1D-5', 'TRKJ', 'TRKJ 1D', 'Selasa', 8, 11, '14:20', '18:00', 'Dasar-dasar Elektronik untuk IoT', 'Rika Rahmawati, M.Kom.', 'TIK.112', false, 'Gasal 2026/2027'),
  ('TRKJ1D-6', 'TRKJ', 'TRKJ 1D', 'Rabu', 1, 2, '07:30', '09:10', 'Pendidikan Pancasila', 'Hosea Sitepu, M.Pd', 'TIK.307', false, 'Gasal 2026/2027'),
  ('TRKJ1D-7', 'TRKJ', 'TRKJ 1D', 'Rabu', 3, 6, '09:10', '12:50', 'Menyimak dan Berbicara Academik', 'Nurul Kamaliah, S.Pd, M.Pd', 'TIK.306', false, 'Gasal 2026/2027'),
  ('TRKJ1D-8', 'TRKJ', 'TRKJ 1D', 'Rabu', 7, 11, '13:30', '18:00', 'Praktik Dasar-dasar Jaringan', 'Ir. Muhammad Azzahari, SST., MT.', 'TIK.107', true, 'Gasal 2026/2027'),
  ('TRKJ1D-9', 'TRKJ', 'TRKJ 1D', 'Kamis', 1, 5, '07:30', '12:00', 'Praktik Sistem Operasi', 'Firdaus Muttaqin, S.T., M.T.', 'TIK.108', true, 'Gasal 2026/2027'),
  ('TRKJ1D-10', 'TRKJ', 'TRKJ 1D', 'Jumat', 1, 5, '07:30', '12:00', 'Praktik Algorithma dan Struktur Data', 'Indrawati, SST., MT.', 'TIK.103', true, 'Gasal 2026/2027'),
  ('TRKJ2A-1', 'TRKJ', 'TRKJ 2A', 'Senin', 1, 2, '07:30', '09:10', 'Aljabar Linear', 'Nazaruddin, ST., MT', 'TIK.306', false, 'Gasal 2026/2027'),
  ('TRKJ2A-2', 'TRKJ', 'TRKJ 2A', 'Senin', 3, 7, '09:10', '14:20', 'Praktik Penskalaan Jaringan', 'Ir. Muhammad Azzahari, SST., MT.', 'TIK.107', true, 'Gasal 2026/2027'),
  ('TRKJ2A-3', 'TRKJ', 'TRKJ 2A', 'Selasa', 1, 3, '07:30', '10:00', 'Praktik Sistem Operasi Jaringan', 'Rika Rahmawati, M.Kom.', 'TIK.212', true, 'Gasal 2026/2027'),
  ('TRKJ2A-4', 'TRKJ', 'TRKJ 2A', 'Selasa', 5, 7, '11:10', '14:20', 'Dasar-dasar Desain UI / UX', 'Indrawati, SST., MT.', 'TIK.204', false, 'Gasal 2026/2027'),
  ('TRKJ2A-5', 'TRKJ', 'TRKJ 2A', 'Rabu', 1, 2, '07:30', '09:10', 'Kemampuan Interpersonal', 'Zulkarnaini, SE.,M.Si.Ak.CA', 'TIK.303', false, 'Gasal 2026/2027'),
  ('TRKJ2A-6', 'TRKJ', 'TRKJ 2A', 'Rabu', 5, 8, '11:10', '15:10', 'Internet of Things', 'Muhammad Nasir, ST. MT.', 'TIK.112', false, 'Gasal 2026/2027'),
  ('TRKJ2A-7', 'TRKJ', 'TRKJ 2A', 'Kamis', 1, 6, '07:30', '12:50', 'Etika Peretasan', 'Aswandi, S.Kom., M.Kom', 'TIK.109', false, 'Gasal 2026/2027'),
  ('TRKJ2A-8', 'TRKJ', 'TRKJ 2A', 'Kamis', 7, 8, '13:30', '15:10', 'Pendidikan Agama', 'Nazar Fadli, M.Ag., Ph.D.', 'TIK.310', false, 'Gasal 2026/2027'),
  ('TRKJ2A-9', 'TRKJ', 'TRKJ 2A', 'Jumat', 1, 4, '07:30', '11:10', 'Teknologi Sistem Terintegrasi', 'Hari Toha Hidayat, S.Si., M.Cs', 'TIK.105', false, 'Gasal 2026/2027'),
  ('TRKJ2A-10', 'TRKJ', 'TRKJ 2A', 'Jumat', 7, 11, '13:30', '18:00', 'Pengantar Proyek', 'Nanang Prihatin, S.Kom., M.Cs.', 'TIK.211', false, 'Gasal 2026/2027'),
  ('TRKJ2B-1', 'TRKJ', 'TRKJ 2B', 'Senin', 3, 4, '09:10', '11:10', 'Aljabar Linear', 'Nazaruddin, ST., MT', 'TIK.303', false, 'Gasal 2026/2027'),
  ('TRKJ2B-2', 'TRKJ', 'TRKJ 2B', 'Senin', 7, 11, '13:30', '18:00', 'Etika Peretasan', 'Nanang Prihatin, S.Kom., M.Cs.', 'TIK.304', false, 'Gasal 2026/2027'),
  ('TRKJ2B-3', 'TRKJ', 'TRKJ 2B', 'Selasa', 1, 5, '07:30', '12:00', 'Pengantar Proyek', 'Afla Nevrisa, S.Kom., M.Kom.', 'TIK.211', false, 'Gasal 2026/2027'),
  ('TRKJ2B-4', 'TRKJ', 'TRKJ 2B', 'Selasa', 7, 8, '13:30', '15:10', 'Pendidikan Agama', 'Nazar Fadli, M.Ag., Ph.D.', 'TIK.304', false, 'Gasal 2026/2027'),
  ('TRKJ2B-5', 'TRKJ', 'TRKJ 2B', 'Rabu', 1, 2, '07:30', '09:10', 'Kemampuan Interpersonal', 'Maulizar, S.E, M.Si', 'TIK.302', false, 'Gasal 2026/2027'),
  ('TRKJ2B-6', 'TRKJ', 'TRKJ 2B', 'Rabu', 5, 8, '11:10', '15:10', 'Teknologi Sistem Terintegrasi', 'Muhammad Davi, S.Kom., M.Cs.', 'TIK.111', false, 'Gasal 2026/2027'),
  ('TRKJ2B-7', 'TRKJ', 'TRKJ 2B', 'Kamis', 5, 7, '11:10', '14:20', 'Praktik Sistem Operasi Jaringan', 'Rika Rahmawati, M.Kom.', 'TIK.302', true, 'Gasal 2026/2027'),
  ('TRKJ2B-8', 'TRKJ', 'TRKJ 2B', 'Kamis', 8, 11, '14:20', '18:00', 'Dasar-dasar Desain UI / UX', 'Indrawati, SST., MT.', 'TIK.103', false, 'Gasal 2026/2027'),
  ('TRKJ2B-9', 'TRKJ', 'TRKJ 2B', 'Jumat', 1, 5, '07:30', '12:00', 'Praktik Penskalaan Jaringan', 'Ir. Muhammad Azzahari, SST., MT.', 'TIK.110', true, 'Gasal 2026/2027'),
  ('TRKJ2B-10', 'TRKJ', 'TRKJ 2B', 'Jumat', 8, 11, '14:20', '18:00', 'Internet of Things', 'Atthariq, SST., MT.', 'TIK.112', false, 'Gasal 2026/2027'),
  ('TRKJ2C-1', 'TRKJ', 'TRKJ 2C', 'Senin', 1, 6, '07:30', '12:50', 'Etika Peretasan', 'Aswandi, S.Kom., M.Kom', 'TIK.111', false, 'Gasal 2026/2027'),
  ('TRKJ2C-2', 'TRKJ', 'TRKJ 2C', 'Senin', 8, 11, '14:20', '18:00', 'Internet of Things', 'Atthariq, SST., MT.', 'TIK.112', false, 'Gasal 2026/2027'),
  ('TRKJ2C-3', 'TRKJ', 'TRKJ 2C', 'Selasa', 1, 5, '07:30', '12:00', 'Praktik Penskalaan Jaringan', 'Aswandi, S.Kom., M.Kom', 'TIK.109', true, 'Gasal 2026/2027'),
  ('TRKJ2C-4', 'TRKJ', 'TRKJ 2C', 'Selasa', 8, 11, '14:20', '18:00', 'Pengantar Proyek', 'Indrawati, SST., MT.', 'TIK.211', false, 'Gasal 2026/2027'),
  ('TRKJ2C-5', 'TRKJ', 'TRKJ 2C', 'Rabu', 1, 4, '07:30', '11:10', 'Dasar-dasar Desain UI / UX', 'Muhammad Davi, S.Kom., M.Cs.', 'TIK.111', false, 'Gasal 2026/2027'),
  ('TRKJ2C-6', 'TRKJ', 'TRKJ 2C', 'Rabu', 5, 7, '11:10', '14:20', 'Praktik Sistem Operasi Jaringan', 'Rika Rahmawati, M.Kom.', 'TIK.303', true, 'Gasal 2026/2027'),
  ('TRKJ2C-7', 'TRKJ', 'TRKJ 2C', 'Kamis', 1, 2, '07:30', '09:10', 'Aljabar Linear', 'Erna Yusniyanti, S.Si., M.Si.', 'TIK.303', false, 'Gasal 2026/2027'),
  ('TRKJ2C-8', 'TRKJ', 'TRKJ 2C', 'Kamis', 5, 8, '11:10', '15:10', 'Teknologi Sistem Terintegrasi', 'Hari Toha Hidayat, S.Si., M.Cs', 'TIK.106', false, 'Gasal 2026/2027'),
  ('TRKJ2C-9', 'TRKJ', 'TRKJ 2C', 'Jumat', 1, 2, '07:30', '09:10', 'Kemampuan Interpersonal', 'Halimatus Sakdiah, S.E, M.M', 'TIK.306', false, 'Gasal 2026/2027'),
  ('TRKJ2C-10', 'TRKJ', 'TRKJ 2C', 'Jumat', 7, 8, '13:30', '15:10', 'Pendidikan Agama', 'Nazar Fadli, M.Ag., Ph.D.', 'TIK.301', false, 'Gasal 2026/2027'),
  ('TRKJ2D-1', 'TRKJ', 'TRKJ 2D', 'Senin', 1, 4, '07:30', '11:10', 'Dasar-dasar Desain UI / UX', 'Mutiara S. Simanjuntak, S.Kom., M. Kom', 'TIK.110', false, 'Gasal 2026/2027'),
  ('TRKJ2D-2', 'TRKJ', 'TRKJ 2D', 'Senin', 5, 7, '11:10', '14:20', 'Praktik Sistem Operasi Jaringan', 'Rika Rahmawati, M.Kom.', 'TIK.311', true, 'Gasal 2026/2027'),
  ('TRKJ2D-3', 'TRKJ', 'TRKJ 2D', 'Senin', 8, 9, '14:20', '16:00', 'Aljabar Linear', 'Nazaruddin, ST., MT', 'TIK.212', false, 'Gasal 2026/2027'),
  ('TRKJ2D-4', 'TRKJ', 'TRKJ 2D', 'Selasa', 1, 5, '07:30', '12:00', 'Pengantar Proyek', 'Atthariq, SST., MT.', 'TIK.111', false, 'Gasal 2026/2027'),
  ('TRKJ2D-5', 'TRKJ', 'TRKJ 2D', 'Selasa', 7, 11, '13:30', '18:00', 'Praktik Penskalaan Jaringan', 'Aswandi, S.Kom., M.Kom', 'TIK.206', true, 'Gasal 2026/2027'),
  ('TRKJ2D-6', 'TRKJ', 'TRKJ 2D', 'Rabu', 1, 4, '07:30', '11:10', 'Internet of Things', 'Muhammad Nasir, ST. MT.', 'TIK.112', false, 'Gasal 2026/2027'),
  ('TRKJ2D-7', 'TRKJ', 'TRKJ 2D', 'Rabu', 7, 8, '13:30', '15:10', 'Pendidikan Agama', 'Nazar Fadli, M.Ag., Ph.D.', 'TIK.209', false, 'Gasal 2026/2027'),
  ('TRKJ2D-8', 'TRKJ', 'TRKJ 2D', 'Kamis', 1, 6, '07:30', '12:50', 'Etika Peretasan', 'Nanang Prihatin, S.Kom., M.Cs.', 'TIK.111', false, 'Gasal 2026/2027'),
  ('TRKJ2D-9', 'TRKJ', 'TRKJ 2D', 'Kamis', 7, 8, '13:30', '15:10', 'Kemampuan Interpersonal', 'Diana, SE.,Ak.,M.Si.', 'TIK.315', false, 'Gasal 2026/2027'),
  ('TRKJ2D-10', 'TRKJ', 'TRKJ 2D', 'Jumat', 8, 11, '14:20', '18:00', 'Teknologi Sistem Terintegrasi', 'Hari Toha Hidayat, S.Si., M.Cs', 'TIK.102', false, 'Gasal 2026/2027'),
  ('TRKJ3A-1', 'TRKJ', 'TRKJ 3A', 'Senin', 1, 5, '07:30', '12:00', 'Manajemen dan Penyimpanan Jaringan', 'Anwar, S.Si., M.Cs.', 'TIK.109', false, 'Gasal 2026/2027'),
  ('TRKJ3A-2', 'TRKJ', 'TRKJ 3A', 'Senin', 6, 7, '12:00', '14:20', 'Manajemen Risiko Keamanan Siber', 'Atthariq, SST., MT.', 'TIK.312', false, 'Gasal 2026/2027'),
  ('TRKJ3A-3', 'TRKJ', 'TRKJ 3A', 'Senin', 8, 9, '14:20', '16:00', 'Tata Kelola IT', 'Firdaus Muttaqin, S.T., M.T.', 'TIK.301', false, 'Gasal 2026/2027'),
  ('TRKJ3A-4', 'TRKJ', 'TRKJ 3A', 'Selasa', 1, 4, '07:30', '11:10', 'Pengembangan dan Manajemen Perangkat Lunak', 'Husaini, S.Si., M.IT', 'TIK.310', false, 'Gasal 2026/2027'),
  ('TRKJ3A-5', 'TRKJ', 'TRKJ 3A', 'Selasa', 5, 6, '11:10', '12:50', 'Paradigma Sistem untuk IT', 'Husaini, S.Si., M.IT', 'TIK.306', false, 'Gasal 2026/2027'),
  ('TRKJ3A-6', 'TRKJ', 'TRKJ 3A', 'Rabu', 1, 5, '07:30', '12:00', 'Komputasi Seluler', 'Hari Toha Hidayat, S.Si., M.Cs', 'TIK.315', false, 'Gasal 2026/2027'),
  ('TRKJ3A-7', 'TRKJ', 'TRKJ 3A', 'Rabu', 8, 11, '14:20', '18:00', 'Praktik Manajemen Risiko Keamanan Siber', 'Atthariq, SST., MT.', 'TIK.306', true, 'Gasal 2026/2027'),
  ('TRKJ3A-8', 'TRKJ', 'TRKJ 3A', 'Kamis', 4, 8, '10:20', '15:10', 'Praktik Website dan Sistem Mobile', 'Muhammad Davi, S.Kom., M.Cs.', 'TIK.101', true, 'Gasal 2026/2027'),
  ('TRKJ3A-9', 'TRKJ', 'TRKJ 3A', 'Jumat', 1, 5, '07:30', '12:00', 'Proyek Inovasi Produk', 'RHD / HSN', 'TIK.209', false, 'Gasal 2026/2027'),
  ('TRKJ3B-1', 'TRKJ', 'TRKJ 3B', 'Senin', 1, 5, '07:30', '12:00', 'Komputasi Seluler', 'Hari Toha Hidayat, S.Si., M.Cs', 'TIK.316', false, 'Gasal 2026/2027'),
  ('TRKJ3B-2', 'TRKJ', 'TRKJ 3B', 'Selasa', 1, 5, '07:30', '12:00', 'Praktik Website dan Sistem Mobile', 'Muhammad Davi, S.Kom., M.Cs.', 'TIK.101', true, 'Gasal 2026/2027'),
  ('TRKJ3B-3', 'TRKJ', 'TRKJ 3B', 'Selasa', 6, 8, '12:00', '15:10', 'Praktik Manajemen Risiko Keamanan Siber', 'Firdaus Muttaqin, S.T., M.T.', 'TIK.111', true, 'Gasal 2026/2027'),
  ('TRKJ3B-4', 'TRKJ', 'TRKJ 3B', 'Rabu', 1, 2, '07:30', '09:10', 'Tata Kelola IT', 'Firdaus Muttaqin, S.T., M.T.', 'TIK.209', false, 'Gasal 2026/2027'),
  ('TRKJ3B-5', 'TRKJ', 'TRKJ 3B', 'Rabu', 3, 7, '09:10', '14:20', 'Proyek Inovasi Produk', 'ATQ / IDR', 'TIK.213', false, 'Gasal 2026/2027'),
  ('TRKJ3B-6', 'TRKJ', 'TRKJ 3B', 'Kamis', 1, 4, '07:30', '11:10', 'Pengembangan dan Manajemen Perangkat Lunak', 'Husaini, S.Si., M.IT', 'TIK.313', false, 'Gasal 2026/2027'),
  ('TRKJ3B-7', 'TRKJ', 'TRKJ 3B', 'Kamis', 5, 6, '11:10', '12:50', 'Paradigma Sistem untuk IT', 'Husaini, S.Si., M.IT', 'TIK.304', false, 'Gasal 2026/2027'),
  ('TRKJ3B-8', 'TRKJ', 'TRKJ 3B', 'Kamis', 7, 8, '13:30', '15:10', 'Manajemen Risiko Keamanan Siber', 'Firdaus Muttaqin, S.T., M.T.', 'TIK.212', false, 'Gasal 2026/2027'),
  ('TRKJ3B-9', 'TRKJ', 'TRKJ 3B', 'Jumat', 1, 5, '07:30', '12:00', 'Manajemen dan Penyimpanan Jaringan', 'Anwar, S.Si., M.Cs.', 'TIK.214', false, 'Gasal 2026/2027'),
  ('TRKJ3C-1', 'TRKJ', 'TRKJ 3C', 'Senin', 1, 2, '07:30', '09:10', 'Paradigma Sistem untuk IT', 'M.Reza Zulman, SST., M.Sc.', 'TIK.304', false, 'Gasal 2026/2027'),
  ('TRKJ3C-2', 'TRKJ', 'TRKJ 3C', 'Senin', 3, 6, '09:10', '12:50', 'Pengembangan dan Manajemen Perangkat Lunak', 'Husaini, S.Si., M.IT', 'TIK.307', false, 'Gasal 2026/2027'),
  ('TRKJ3C-3', 'TRKJ', 'TRKJ 3C', 'Selasa', 1, 5, '07:30', '12:00', 'Komputasi Seluler', 'Arwin Putra, M.Kom', 'TIK.308', false, 'Gasal 2026/2027'),
  ('TRKJ3C-4', 'TRKJ', 'TRKJ 3C', 'Selasa', 6, 8, '12:00', '15:10', 'Praktik Manajemen Risiko Keamanan Siber', 'Atthariq, SST., MT.', 'TIK.107', true, 'Gasal 2026/2027'),
  ('TRKJ3C-5', 'TRKJ', 'TRKJ 3C', 'Rabu', 1, 2, '07:30', '09:10', 'Manajemen Risiko Keamanan Siber', 'Atthariq, SST., MT.', 'TIK.311', false, 'Gasal 2026/2027'),
  ('TRKJ3C-6', 'TRKJ', 'TRKJ 3C', 'Rabu', 7, 11, '13:30', '18:00', 'Proyek Inovasi Produk', 'NSP / HSN', 'TIK.214', false, 'Gasal 2026/2027'),
  ('TRKJ3C-7', 'TRKJ', 'TRKJ 3C', 'Kamis', 1, 2, '07:30', '09:10', 'Tata Kelola IT', 'Amri, SST., MT', 'TIK.214', false, 'Gasal 2026/2027'),
  ('TRKJ3C-8', 'TRKJ', 'TRKJ 3C', 'Kamis', 7, 11, '13:30', '18:00', 'Manajemen dan Penyimpanan Jaringan', 'Anwar, S.Si., M.Cs.', 'TIK.108', false, 'Gasal 2026/2027'),
  ('TRKJ3C-9', 'TRKJ', 'TRKJ 3C', 'Jumat', 1, 5, '07:30', '12:00', 'Praktik Website dan Sistem Mobile', 'Muhammad Davi, S.Kom., M.Cs.', 'TIK.301', true, 'Gasal 2026/2027'),
  ('TRKJ3D-1', 'TRKJ', 'TRKJ 3D', 'Senin', 1, 5, '07:30', '12:00', 'Komputasi Seluler', 'Arwin Putra, M.Kom', 'TIK.312', false, 'Gasal 2026/2027'),
  ('TRKJ3D-2', 'TRKJ', 'TRKJ 3D', 'Selasa', 7, 11, '13:30', '18:00', 'Manajemen dan Penyimpanan Jaringan', 'Anwar, S.Si., M.Cs.', 'TIK.108', false, 'Gasal 2026/2027'),
  ('TRKJ3D-3', 'TRKJ', 'TRKJ 3D', 'Rabu', 1, 4, '07:30', '11:10', 'Pengembangan dan Manajemen Perangkat Lunak', 'Husaini, S.Si., M.IT', 'TIK.211', false, 'Gasal 2026/2027'),
  ('TRKJ3D-4', 'TRKJ', 'TRKJ 3D', 'Rabu', 5, 6, '11:10', '12:50', 'Tata Kelola IT', 'Amri, SST., MT', 'TIK.214', false, 'Gasal 2026/2027'),
  ('TRKJ3D-5', 'TRKJ', 'TRKJ 3D', 'Rabu', 9, 11, '15:10', '18:00', 'Paradigma Sistem untuk IT', 'M.Reza Zulman, SST., M.Sc.', 'TIK.301', false, 'Gasal 2026/2027'),
  ('TRKJ3D-6', 'TRKJ', 'TRKJ 3D', 'Kamis', 3, 7, '09:10', '14:20', 'Proyek Inovasi Produk', 'IDR / NDW', 'TIK.211', false, 'Gasal 2026/2027'),
  ('TRKJ3D-7', 'TRKJ', 'TRKJ 3D', 'Jumat', 1, 2, '07:30', '09:10', 'Manajemen Risiko Keamanan Siber', 'Atthariq, SST., MT.', 'TIK.308', false, 'Gasal 2026/2027'),
  ('TRKJ3D-8', 'TRKJ', 'TRKJ 3D', 'Jumat', 3, 5, '09:10', '12:00', 'Praktik Manajemen Risiko Keamanan Siber', 'Atthariq, SST., MT.', 'TIK.107', true, 'Gasal 2026/2027'),
  ('TRKJ3D-9', 'TRKJ', 'TRKJ 3D', 'Jumat', 7, 11, '13:30', '18:00', 'Praktik Website dan Sistem Mobile', 'Muhammad Davi, S.Kom., M.Cs.', 'TIK.104', true, 'Gasal 2026/2027'),
  ('TRKJ4A-1', 'TRKJ', 'TRKJ 4A', 'Senin', 1, 5, '07:30', '12:00', 'Robotika, Jaringan Cerdas & Otomasi', 'Mustainul Abdi, SST., M.Kom.', 'TIK.112', false, 'Gasal 2026/2027'),
  ('TRKJ4A-2', 'TRKJ', 'TRKJ 4A', 'Selasa', 1, 3, '07:30', '10:00', 'Praktik Sistem Administrator dan Layanan Infrastruktur IT', 'Anwar, S.Si., M.Cs.', 'TIK.108', true, 'Gasal 2026/2027'),
  ('TRKJ4A-3', 'TRKJ', 'TRKJ 4A', 'Selasa', 4, 7, '10:20', '14:20', 'Audit Keamanan Siber', 'Nanang Prihatin, S.Kom., M.Cs.', 'TIK.311', false, 'Gasal 2026/2027'),
  ('TRKJ4A-4', 'TRKJ', 'TRKJ 4A', 'Rabu', 1, 4, '07:30', '11:10', 'Arsitektur Sistem Enterprise', 'Rika Rahmawati, M.Kom.', 'TIK.313', false, 'Gasal 2026/2027'),
  ('TRKJ4A-5', 'TRKJ', 'TRKJ 4A', 'Rabu', 5, 6, '11:10', '12:50', 'Sistem Administrator dan Layanan Infrastruktur IT', 'Muhammad Rizka, SST., M. Kom.', 'TIK.212', false, 'Gasal 2026/2027'),
  ('TRKJ4A-6', 'TRKJ', 'TRKJ 4A', 'Rabu', 7, 9, '13:30', '16:00', 'Praktik Sistem dan Layanan Virtual', 'Amri, SST., MT', 'TIK.110', true, 'Gasal 2026/2027'),
  ('TRKJ4A-7', 'TRKJ', 'TRKJ 4A', 'Kamis', 1, 4, '07:30', '11:10', 'Audit Infrastruktur Jaringan', 'Hari Toha Hidayat, S.Si., M.Cs', 'TIK.110', false, 'Gasal 2026/2027'),
  ('TRKJ4A-8', 'TRKJ', 'TRKJ 4A', 'Jumat', 1, 5, '07:30', '12:00', 'Proyek Industri Jaringan', 'Amri, SST., MT', 'TIK.108', false, 'Gasal 2026/2027'),
  ('TRKJ4B-1', 'TRKJ', 'TRKJ 4B', 'Senin', 1, 4, '07:30', '11:10', 'Arsitektur Sistem Enterprise', 'Rika Rahmawati, M.Kom.', 'TIK.310', false, 'Gasal 2026/2027'),
  ('TRKJ4B-2', 'TRKJ', 'TRKJ 4B', 'Senin', 5, 7, '11:10', '14:20', 'Praktik Sistem dan Layanan Virtual', 'Firdaus Muttaqin, S.T., M.T.', 'TIK.110', true, 'Gasal 2026/2027'),
  ('TRKJ4B-3', 'TRKJ', 'TRKJ 4B', 'Selasa', 1, 4, '07:30', '11:10', 'Aplikasi Layanan Jaringan', 'Amri, SST., MT', 'TIK.110', false, 'Gasal 2026/2027'),
  ('TRKJ4B-4', 'TRKJ', 'TRKJ 4B', 'Selasa', 5, 8, '11:10', '15:10', 'Audit Infrastruktur Jaringan', 'Hari Toha Hidayat, S.Si., M.Cs', 'TIK.110', false, 'Gasal 2026/2027'),
  ('TRKJ4B-5', 'TRKJ', 'TRKJ 4B', 'Rabu', 1, 3, '07:30', '10:00', 'Praktik Sistem Administrator dan Layanan Infrastruktur IT', 'Aswandi, S.Kom., M.Kom', 'TIK.108', true, 'Gasal 2026/2027'),
  ('TRKJ4B-6', 'TRKJ', 'TRKJ 4B', 'Rabu', 4, 8, '10:20', '15:10', 'Proyek Industri Jaringan', 'Anwar, S.Si., M.Cs.', 'TIK.108', false, 'Gasal 2026/2027'),
  ('TRKJ4B-7', 'TRKJ', 'TRKJ 4B', 'Kamis', 1, 5, '07:30', '12:00', 'Robotika, Jaringan Cerdas & Otomasi', 'Muhammad Nasir, ST. MT.', 'TIK.112', false, 'Gasal 2026/2027'),
  ('TRKJ4B-8', 'TRKJ', 'TRKJ 4B', 'Jumat', 1, 4, '07:30', '11:10', 'Audit Keamanan Siber', 'Nanang Prihatin, S.Kom., M.Cs.', 'TIK.315', false, 'Gasal 2026/2027'),
  ('TRKJ4B-9', 'TRKJ', 'TRKJ 4B', 'Jumat', 8, 9, '14:20', '16:00', 'Sistem Administrator dan Layanan Infrastruktur IT', 'Aswandi, S.Kom., M.Kom', 'TIK.309', false, 'Gasal 2026/2027'),
  ('TRKJ4C-1', 'TRKJ', 'TRKJ 4C', 'Senin', 1, 5, '07:30', '12:00', 'Proyek Industri Jaringan', 'Nanang Prihatin, S.Kom., M.Cs.', 'TIK.108', false, 'Gasal 2026/2027'),
  ('TRKJ4C-2', 'TRKJ', 'TRKJ 4C', 'Senin', 6, 8, '12:00', '15:10', 'Praktik Sistem Administrator dan Layanan Infrastruktur IT', 'Anwar, S.Si., M.Cs.', 'TIK.108', true, 'Gasal 2026/2027'),
  ('TRKJ4C-3', 'TRKJ', 'TRKJ 4C', 'Selasa', 1, 5, '07:30', '12:00', 'Robotika, Jaringan Cerdas & Otomasi', 'Muhammad Nasir, ST. MT.', 'TIK.112', false, 'Gasal 2026/2027'),
  ('TRKJ4C-4', 'TRKJ', 'TRKJ 4C', 'Selasa', 7, 11, '13:30', '18:00', 'Aplikasi Layanan Jaringan', 'Amri, SST., MT', 'TIK.303', false, 'Gasal 2026/2027'),
  ('TRKJ4C-5', 'TRKJ', 'TRKJ 4C', 'Rabu', 1, 3, '07:30', '10:00', 'Praktik Sistem dan Layanan Virtual', 'Amri, SST., MT', 'TIK.110', true, 'Gasal 2026/2027'),
  ('TRKJ4C-6', 'TRKJ', 'TRKJ 4C', 'Rabu', 4, 7, '10:20', '14:20', 'Audit Keamanan Siber', 'Nanang Prihatin, S.Kom., M.Cs.', 'TIK.310', false, 'Gasal 2026/2027'),
  ('TRKJ4C-7', 'TRKJ', 'TRKJ 4C', 'Rabu', 8, 11, '14:20', '18:00', 'Audit Infrastruktur Jaringan', 'Hari Toha Hidayat, S.Si., M.Cs', 'TIK.213', false, 'Gasal 2026/2027'),
  ('TRKJ4C-8', 'TRKJ', 'TRKJ 4C', 'Kamis', 1, 4, '07:30', '11:10', 'Arsitektur Sistem Enterprise', 'Rika Rahmawati, M.Kom.', 'TIK.307', false, 'Gasal 2026/2027'),
  ('TRKJ4C-9', 'TRKJ', 'TRKJ 4C', 'Kamis', 5, 8, '11:10', '15:10', 'Aplikasi Layanan Jaringan', 'Amri, SST., MT', 'TIK.110', false, 'Gasal 2026/2027'),
  ('TRKJ4C-10', 'TRKJ', 'TRKJ 4C', 'Jumat', 7, 8, '13:30', '15:10', 'Sistem Administrator dan Layanan Infrastruktur IT', 'Anwar, S.Si., M.Cs.', 'TIK.212', false, 'Gasal 2026/2027'),
  ('TI1A-1', 'TI', 'TI 1A', 'Senin', 1, 2, '07:30', '09:10', 'Pengantar Teknik Informatika dan Orkom', 'Mulyadi, ST., M.Eng.', 'TIK.314', false, 'Gasal 2026/2027'),
  ('TI1A-2', 'TI', 'TI 1A', 'Senin', 3, 4, '09:10', '11:10', 'Konsep Pemrograman', 'Hendrawaty, ST., MT', 'TIK.314', false, 'Gasal 2026/2027'),
  ('TI1A-3', 'TI', 'TI 1A', 'Senin', 7, 11, '13:30', '18:00', 'Praktikum Konsep Basis Data', 'Salahuddin, ST., M.Cs.', 'TIK.103', true, 'Gasal 2026/2027'),
  ('TI1A-4', 'TI', 'TI 1A', 'Selasa', 1, 5, '07:30', '12:00', 'Praktikum Konsep Pemrograman', 'Muhammad Arhami, S.Si., M.Kom', 'TIK.104', true, 'Gasal 2026/2027'),
  ('TI1A-5', 'TI', 'TI 1A', 'Rabu', 1, 2, '07:30', '09:10', 'Konsep Basis Data', 'Salahuddin, ST., M.Cs.', 'TIK.303', false, 'Gasal 2026/2027'),
  ('TI1A-6', 'TI', 'TI 1A', 'Rabu', 3, 4, '09:10', '11:10', 'Logika dan Algoritma', 'Hendrawaty, ST., MT', 'TIK.303', false, 'Gasal 2026/2027'),
  ('TI1A-7', 'TI', 'TI 1A', 'Rabu', 5, 6, '11:10', '12:50', 'English for Listening', 'Drs. Teuku Mustaqim, M.Pd.', 'TIK.305', false, 'Gasal 2026/2027'),
  ('TI1A-8', 'TI', 'TI 1A', 'Kamis', 1, 2, '07:30', '09:10', 'Matematika Diskrit', 'Cut Dwita Rahma, S.T., M.T.', 'TIK.310', false, 'Gasal 2026/2027'),
  ('TI1A-9', 'TI', 'TI 1A', 'Kamis', 5, 6, '11:10', '12:50', 'Konsep Teknologi Informasi', 'Huzaeni, S.ST., M.IT', 'TIK.310', false, 'Gasal 2026/2027'),
  ('TI1A-10', 'TI', 'TI 1A', 'Jumat', 10, 11, '16:20', '18:00', 'Agama', 'Taufiqul Hadi, Lc, MA', 'TIK.302', false, 'Gasal 2026/2027'),
  ('TI1B-1', 'TI', 'TI 1B', 'Senin', 1, 2, '07:30', '09:10', 'Konsep Basis Data', 'Salahuddin, ST., M.Cs.', 'TIK.308', false, 'Gasal 2026/2027'),
  ('TI1B-2', 'TI', 'TI 1B', 'Selasa', 4, 5, '10:20', '12:00', 'English for Listening', 'Drs. Teuku Mustaqim, M.Pd.', 'TIK.303', false, 'Gasal 2026/2027'),
  ('TI1B-3', 'TI', 'TI 1B', 'Rabu', 3, 4, '09:10', '11:10', 'Logika dan Algoritma', 'Suci Andriani, M.Kom.', 'TIK.302', false, 'Gasal 2026/2027'),
  ('TI1B-4', 'TI', 'TI 1B', 'Rabu', 7, 11, '13:30', '18:00', 'Praktikum Konsep Pemrograman', 'Muhammad Arhami, S.Si., M.Kom', 'TIK.104', true, 'Gasal 2026/2027'),
  ('TI1B-5', 'TI', 'TI 1B', 'Kamis', 1, 2, '07:30', '09:10', 'Konsep Teknologi Informasi', 'Huzaeni, S.ST., M.IT', 'TIK.308', false, 'Gasal 2026/2027'),
  ('TI1B-6', 'TI', 'TI 1B', 'Kamis', 3, 4, '09:10', '11:10', 'Konsep Pemrograman', 'Huzaeni, S.ST., M.IT', 'TIK.308', false, 'Gasal 2026/2027'),
  ('TI1B-7', 'TI', 'TI 1B', 'Jumat', 1, 2, '07:30', '09:10', 'Matematika Diskrit', 'Suci Andriani, M.Kom.', 'TIK.313', false, 'Gasal 2026/2027'),
  ('TI1B-8', 'TI', 'TI 1B', 'Jumat', 4, 5, '10:20', '12:00', 'Agama', 'Taufiqul Hadi, Lc, MA', 'TIK.304', false, 'Gasal 2026/2027'),
  ('TI1B-9', 'TI', 'TI 1B', 'Jumat', 7, 11, '13:30', '18:00', 'Praktikum Konsep Basis Data', 'Huzaeni, S.ST., M.IT', 'TIK.105', true, 'Gasal 2026/2027'),
  ('TI1C-1', 'TI', 'TI 1C', 'Senin', 3, 4, '09:10', '11:10', 'Konsep Teknologi Informasi', 'Huzaeni, S.ST., M.IT', 'TIK.313', false, 'Gasal 2026/2027'),
  ('TI1C-2', 'TI', 'TI 1C', 'Senin', 5, 6, '11:10', '12:50', 'Matematika Diskrit', 'Erika Fahmi Br Ginting, S. Kom., M,Kom', 'TIK.313', false, 'Gasal 2026/2027'),
  ('TI1C-3', 'TI', 'TI 1C', 'Selasa', 1, 2, '07:30', '09:10', 'Logika dan Algoritma', 'Hendrawaty, ST., MT', 'TIK.301', false, 'Gasal 2026/2027'),
  ('TI1C-4', 'TI', 'TI 1C', 'Rabu', 1, 5, '07:30', '12:00', 'Praktikum Konsep Pemrograman', 'Muhammad Arhami, S.Si., M.Kom', 'TIK.202', true, 'Gasal 2026/2027'),
  ('TI1C-5', 'TI', 'TI 1C', 'Rabu', 7, 11, '13:30', '18:00', 'Praktikum Konsep Basis Data', 'Mahdi, ST., M.Cs', 'TIK.101', true, 'Gasal 2026/2027'),
  ('TI1C-6', 'TI', 'TI 1C', 'Kamis', 3, 4, '09:10', '11:10', 'Konsep Pemrograman', 'Arwin Putra, M.Kom', 'TIK.302', false, 'Gasal 2026/2027'),
  ('TI1C-7', 'TI', 'TI 1C', 'Jumat', 1, 2, '07:30', '09:10', 'Konsep Basis Data', 'Mahdi, ST., M.Cs', 'TIK.307', false, 'Gasal 2026/2027'),
  ('TI1C-8', 'TI', 'TI 1C', 'Jumat', 3, 4, '09:10', '11:10', 'English for Listening', 'Rizqina Barophon, S.Pd., M.Pd.', 'TIK.307', false, 'Gasal 2026/2027'),
  ('TI1C-9', 'TI', 'TI 1C', 'Jumat', 8, 9, '14:20', '16:00', 'Agama', 'Taufiqul Hadi, Lc, MA', 'TIK.313', false, 'Gasal 2026/2027'),
  ('TI1D-1', 'TI', 'TI 1D', 'Senin', 1, 2, '07:30', '09:10', 'Logika dan Algoritma', 'Husna Gemasih, S.Inf., M.Cs', 'TIK.302', false, 'Gasal 2026/2027'),
  ('TI1D-2', 'TI', 'TI 1D', 'Senin', 4, 5, '10:20', '12:00', 'Pengantar Teknik Informatika dan Orkom', 'Zulfan Khairil S. ST., M.Eng.', 'TIK.315', false, 'Gasal 2026/2027'),
  ('TI1D-3', 'TI', 'TI 1D', 'Senin', 7, 11, '13:30', '18:00', 'Praktikum Konsep Pemrograman', 'Muhammad Arhami, S.Si., M.Kom', 'TIK.111', true, 'Gasal 2026/2027'),
  ('TI1D-4', 'TI', 'TI 1D', 'Selasa', 4, 5, '10:20', '12:00', 'Konsep Teknologi Informasi', 'Radhiyatammardhiyah, SST., M.Sc.', 'TIK.307', false, 'Gasal 2026/2027'),
  ('TI1D-5', 'TI', 'TI 1D', 'Selasa', 7, 11, '13:30', '18:00', 'Praktikum Konsep Basis Data', 'Mahdi, ST., M.Cs', 'TIK.101', true, 'Gasal 2026/2027'),
  ('TI1D-6', 'TI', 'TI 1D', 'Rabu', 1, 2, '07:30', '09:10', 'English for Listening', 'Rizqina Barophon, S.Pd., M.Pd.', 'TIK.305', false, 'Gasal 2026/2027'),
  ('TI1D-7', 'TI', 'TI 1D', 'Rabu', 5, 6, '11:10', '12:50', 'Matematika Diskrit', 'Husna Gemasih, S.Inf., M.Cs', 'TIK.311', false, 'Gasal 2026/2027'),
  ('TI1D-8', 'TI', 'TI 1D', 'Kamis', 1, 2, '07:30', '09:10', 'Konsep Pemrograman', 'Hendrawaty, ST., MT', 'TIK.212', false, 'Gasal 2026/2027'),
  ('TI1D-9', 'TI', 'TI 1D', 'Jumat', 1, 2, '07:30', '09:10', 'Agama', 'Taufiqul Hadi, Lc, MA', 'TIK.304', false, 'Gasal 2026/2027'),
  ('TI1D-10', 'TI', 'TI 1D', 'Jumat', 5, 6, '11:10', '12:50', 'Konsep Basis Data', 'Mahdi, ST., M.Cs', 'TIK.304', false, 'Gasal 2026/2027'),
  ('TI1E-1', 'TI', 'TI 1E', 'Senin', 1, 2, '07:30', '09:10', 'Konsep Basis Data', 'Huzaeni, S.ST., M.IT', 'TIK.302', false, 'Gasal 2026/2027'),
  ('TI1E-2', 'TI', 'TI 1E', 'Senin', 5, 6, '11:10', '12:50', 'Konsep Pemrograman', 'Hendrawaty, ST., MT', 'TIK.302', false, 'Gasal 2026/2027'),
  ('TI1E-3', 'TI', 'TI 1E', 'Selasa', 1, 2, '07:30', '09:10', 'Logika dan Algoritma', 'Suci Andriani, M.Kom.', 'TIK.312', false, 'Gasal 2026/2027'),
  ('TI1E-4', 'TI', 'TI 1E', 'Selasa', 3, 4, '09:10', '11:10', 'Matematika Diskrit', 'Cut Dwita Rahma, S.T., M.T.', 'TIK.312', false, 'Gasal 2026/2027'),
  ('TI1E-5', 'TI', 'TI 1E', 'Selasa', 5, 6, '11:10', '12:50', 'English for Listening', 'Rizqina Barophon, S.Pd., M.Pd.', 'TIK.314', false, 'Gasal 2026/2027'),
  ('TI1E-6', 'TI', 'TI 1E', 'Rabu', 1, 2, '07:30', '09:10', 'Konsep Teknologi Informasi', 'Huzaeni, S.ST., M.IT', 'TIK.308', false, 'Gasal 2026/2027'),
  ('TI1E-7', 'TI', 'TI 1E', 'Kamis', 1, 2, '07:30', '09:10', 'Pengantar Teknik Informatika dan Orkom', 'Zulfan Khairil S. ST., M.Eng.', 'TIK.311', false, 'Gasal 2026/2027'),
  ('TI1E-8', 'TI', 'TI 1E', 'Kamis', 7, 11, '13:30', '18:00', 'Praktikum Konsep Basis Data', 'Salahuddin, ST., M.Cs.', 'TIK.104', true, 'Gasal 2026/2027'),
  ('TI1E-9', 'TI', 'TI 1E', 'Jumat', 1, 5, '07:30', '12:00', 'Praktikum Konsep Pemrograman', 'Muhammad Arhami, S.Si., M.Kom', 'TIK.111', true, 'Gasal 2026/2027'),
  ('TI1E-10', 'TI', 'TI 1E', 'Jumat', 6, 7, '12:00', '14:20', 'Agama', 'Taufiqul Hadi, Lc, MA', 'TIK.302', false, 'Gasal 2026/2027'),
  ('TI2A-1', 'TI', 'TI 2A', 'Senin', 1, 5, '07:30', '12:00', 'Praktikum Administrasi Basis Data', 'Dr.Rahmad Hidayat, S.Kom., M.Cs', 'TIK.101', true, 'Gasal 2026/2027'),
  ('TI2A-2', 'TI', 'TI 2A', 'Senin', 6, 7, '12:00', '14:20', 'Rekayasa Perangkat Lunak', 'Huzaeni, S.ST., M.IT', 'TIK.212', false, 'Gasal 2026/2027'),
  ('TI2A-3', 'TI', 'TI 2A', 'Selasa', 1, 5, '07:30', '12:00', 'Praktikum Pemrograman Berorientasi Objek', 'M.Reza Zulman, SST., M.Sc.', 'TIK.103', true, 'Gasal 2026/2027'),
  ('TI2A-4', 'TI', 'TI 2A', 'Selasa', 6, 7, '12:00', '14:20', 'Konsep Jaringan Komputer', 'Azhar, ST., MT', 'TIK.213', false, 'Gasal 2026/2027'),
  ('TI2A-5', 'TI', 'TI 2A', 'Selasa', 8, 9, '14:20', '16:00', 'Pengolahan Citra Digital (OBE)', 'Zulfan Khairil S. ST., M.Eng.', 'TIK.307', false, 'Gasal 2026/2027'),
  ('TI2A-6', 'TI', 'TI 2A', 'Rabu', 1, 5, '07:30', '12:00', 'Praktikum Konsep Jaringan Komputer', 'Azhar, ST., MT', 'TIK.104', true, 'Gasal 2026/2027'),
  ('TI2A-7', 'TI', 'TI 2A', 'Rabu', 6, 7, '12:00', '14:20', 'Pemrograman Berorientasi Objek', 'Ahmad Afif, M. Kom.', 'TIK.313', false, 'Gasal 2026/2027'),
  ('TI2A-8', 'TI', 'TI 2A', 'Kamis', 1, 5, '07:30', '12:00', 'Workshop Web Enterprise (MVC, Framework)', 'Dr.Rahmad Hidayat, S.Kom., M.Cs', 'TIK.202', true, 'Gasal 2026/2027'),
  ('TI2A-9', 'TI', 'TI 2A', 'Kamis', 5, 6, '11:10', '12:50', 'English for Academic Writing', 'Rizqina Barophon, S.Pd., M.Pd.', 'TIK.311', false, 'Gasal 2026/2027'),
  ('TI2A-10', 'TI', 'TI 2A', 'Kamis', 7, 8, '13:30', '15:10', 'Aljabar Linier', 'M. Arif Nugraha, S.T., M.T.', 'TIK.309', false, 'Gasal 2026/2027'),
  ('TI2A-11', 'TI', 'TI 2A', 'Jumat', 1, 5, '07:30', '12:00', 'Praktikum Pengolahan Citra Digital (OBE)', 'Mustainul Abdi, SST., M.Kom.', 'TIK.102', true, 'Gasal 2026/2027'),
  ('TI2B-1', 'TI', 'TI 2B', 'Senin', 1, 5, '07:30', '12:00', 'Praktikum Konsep Jaringan Komputer', 'Azhar, ST., MT', 'TIK.103', true, 'Gasal 2026/2027'),
  ('TI2B-2', 'TI', 'TI 2B', 'Senin', 6, 7, '12:00', '14:20', 'Pemrograman Berorientasi Objek', 'Suci Andriani, M.Kom.', 'TIK.316', false, 'Gasal 2026/2027'),
  ('TI2B-3', 'TI', 'TI 2B', 'Selasa', 1, 5, '07:30', '12:00', 'Praktikum Pengolahan Citra Digital (OBE)', 'Mutiara S. Simanjuntak, S.Kom., M. Kom', 'TIK.106', true, 'Gasal 2026/2027'),
  ('TI2B-4', 'TI', 'TI 2B', 'Selasa', 6, 7, '12:00', '14:20', 'Rekayasa Perangkat Lunak', 'M.Reza Zulman, SST., M.Sc.', 'TIK.302', false, 'Gasal 2026/2027'),
  ('TI2B-5', 'TI', 'TI 2B', 'Selasa', 9, 10, '15:10', '17:10', 'Konsep Jaringan Komputer', 'Azhar, ST., MT', 'TIK.213', false, 'Gasal 2026/2027'),
  ('TI2B-6', 'TI', 'TI 2B', 'Rabu', 1, 2, '07:30', '09:10', 'Pengolahan Citra Digital (OBE)', 'Zulfan Khairil S. ST., M.Eng.', 'TIK.309', false, 'Gasal 2026/2027'),
  ('TI2B-7', 'TI', 'TI 2B', 'Rabu', 3, 4, '09:10', '11:10', 'Aljabar Linier', 'Erika Fahmi Br Ginting, S. Kom., M,Kom', 'TIK.309', false, 'Gasal 2026/2027'),
  ('TI2B-8', 'TI', 'TI 2B', 'Rabu', 5, 8, '11:10', '15:10', 'Workshop Web Enterprise (MVC, Framework)', 'Arwin Putra, M.Kom', 'TIK.105', true, 'Gasal 2026/2027'),
  ('TI2B-9', 'TI', 'TI 2B', 'Kamis', 1, 2, '07:30', '09:10', 'English for Academic Writing', 'Rizqina Barophon, S.Pd., M.Pd.', 'TIK.312', false, 'Gasal 2026/2027'),
  ('TI2B-10', 'TI', 'TI 2B', 'Kamis', 3, 7, '09:10', '14:20', 'Praktikum Pemrograman Berorientasi Objek', 'Suci Andriani, M.Kom.', 'TIK.105', true, 'Gasal 2026/2027'),
  ('TI2B-11', 'TI', 'TI 2B', 'Jumat', 1, 5, '07:30', '12:00', 'Praktikum Administrasi Basis Data', 'Zulfan Khairil S. ST., M.Eng.', 'TIK.305', true, 'Gasal 2026/2027'),
  ('TI2C-1', 'TI', 'TI 2C', 'Senin', 1, 5, '07:30', '12:00', 'Praktikum Pemrograman Berorientasi Objek', 'Suci Andriani, M.Kom.', 'TIK.102', true, 'Gasal 2026/2027'),
  ('TI2C-2', 'TI', 'TI 2C', 'Senin', 6, 7, '12:00', '14:20', 'Pengolahan Citra Digital (OBE)', 'Mulyadi, ST., M.Eng.', 'TIK.303', false, 'Gasal 2026/2027'),
  ('TI2C-3', 'TI', 'TI 2C', 'Selasa', 1, 2, '07:30', '09:10', 'English for Academic Writing', 'Rizqina Barophon, S.Pd., M.Pd.', 'TIK.311', false, 'Gasal 2026/2027'),
  ('TI2C-4', 'TI', 'TI 2C', 'Selasa', 7, 11, '13:30', '18:00', 'Praktikum Administrasi Basis Data', 'Dr.Rahmad Hidayat, S.Kom., M.Cs', 'TIK.103', true, 'Gasal 2026/2027'),
  ('TI2C-5', 'TI', 'TI 2C', 'Rabu', 1, 5, '07:30', '12:00', 'Workshop Web Enterprise (MVC, Framework)', 'Arwin Putra, M.Kom', 'TIK.106', true, 'Gasal 2026/2027'),
  ('TI2C-6', 'TI', 'TI 2C', 'Rabu', 5, 6, '11:10', '12:50', 'Aljabar Linier', 'Erika Fahmi Br Ginting, S. Kom., M,Kom', 'TIK.309', false, 'Gasal 2026/2027'),
  ('TI2C-7', 'TI', 'TI 2C', 'Rabu', 7, 8, '13:30', '15:10', 'Rekayasa Perangkat Lunak', 'M.Reza Zulman, SST., M.Sc.', 'TIK.302', false, 'Gasal 2026/2027'),
  ('TI2C-8', 'TI', 'TI 2C', 'Kamis', 1, 2, '07:30', '09:10', 'Konsep Jaringan Komputer', 'M. Khadafi, ST., M.T', 'TIK.213', false, 'Gasal 2026/2027'),
  ('TI2C-9', 'TI', 'TI 2C', 'Kamis', 3, 7, '09:10', '14:20', 'Praktikum Pengolahan Citra Digital (OBE)', 'Mutiara S. Simanjuntak, S.Kom., M. Kom', 'TIK.103', true, 'Gasal 2026/2027'),
  ('TI2C-10', 'TI', 'TI 2C', 'Jumat', 1, 5, '07:30', '12:00', 'Praktikum Konsep Jaringan Komputer', 'Azhar, ST., MT', 'TIK.104', true, 'Gasal 2026/2027'),
  ('TI2C-11', 'TI', 'TI 2C', 'Jumat', 8, 9, '14:20', '16:00', 'Pemrograman Berorientasi Objek', 'Ahmad Afif, M. Kom.', 'TIK.316', false, 'Gasal 2026/2027'),
  ('TI2D-1', 'TI', 'TI 2D', 'Senin', 1, 2, '07:30', '09:10', 'Pengolahan Citra Digital (OBE)', 'Zulfan Khairil S. ST., M.Eng.', 'TIK.303', false, 'Gasal 2026/2027'),
  ('TI2D-2', 'TI', 'TI 2D', 'Senin', 3, 4, '09:10', '11:10', 'English for Academic Writing', 'Nurul Kamaliah, S.Pd, M.Pd', 'TIK.311', false, 'Gasal 2026/2027'),
  ('TI2D-3', 'TI', 'TI 2D', 'Senin', 5, 6, '11:10', '12:50', 'Rekayasa Perangkat Lunak', 'Mutiara S. Simanjuntak, S.Kom., M. Kom', 'TIK.213', false, 'Gasal 2026/2027'),
  ('TI2D-4', 'TI', 'TI 2D', 'Senin', 8, 11, '14:20', '18:00', 'Workshop Web Enterprise (MVC, Framework)', 'Husna Gemasih, S.Inf., M.Cs', 'TIK.105', true, 'Gasal 2026/2027'),
  ('TI2D-5', 'TI', 'TI 2D', 'Selasa', 1, 2, '07:30', '09:10', 'Pemrograman Berorientasi Objek', 'Radhiyatammardhiyah, SST., M.Sc.', 'TIK.316', false, 'Gasal 2026/2027'),
  ('TI2D-6', 'TI', 'TI 2D', 'Selasa', 3, 4, '09:10', '11:10', 'Konsep Jaringan Komputer', 'M. Khadafi, ST., M.T', 'TIK.209', false, 'Gasal 2026/2027'),
  ('TI2D-7', 'TI', 'TI 2D', 'Selasa', 7, 11, '13:30', '18:00', 'Praktikum Pemrograman Berorientasi Objek', 'Suci Andriani, M.Kom.', 'TIK.105', true, 'Gasal 2026/2027'),
  ('TI2D-8', 'TI', 'TI 2D', 'Rabu', 7, 11, '13:30', '18:00', 'Praktikum Pengolahan Citra Digital (OBE)', 'Mutiara S. Simanjuntak, S.Kom., M. Kom', 'TIK.103', true, 'Gasal 2026/2027'),
  ('TI2D-9', 'TI', 'TI 2D', 'Kamis', 7, 11, '13:30', '18:00', 'Praktikum Konsep Jaringan Komputer', 'Azhar, ST., MT', 'TIK.102', true, 'Gasal 2026/2027'),
  ('TI2D-10', 'TI', 'TI 2D', 'Jumat', 1, 2, '07:30', '09:10', 'Aljabar Linier', 'Erika Fahmi Br Ginting, S. Kom., M,Kom', 'TIK.309', false, 'Gasal 2026/2027'),
  ('TI2D-11', 'TI', 'TI 2D', 'Jumat', 7, 11, '13:30', '18:00', 'Praktikum Administrasi Basis Data', 'Dr.Rahmad Hidayat, S.Kom., M.Cs', 'TIK.101', true, 'Gasal 2026/2027'),
  ('TI2E-1', 'TI', 'TI 2E', 'Senin', 1, 2, '07:30', '09:10', 'Aljabar Linier', 'Erika Fahmi Br Ginting, S. Kom., M,Kom', 'TIK.308', false, 'Gasal 2026/2027'),
  ('TI2E-2', 'TI', 'TI 2E', 'Senin', 3, 7, '09:10', '14:20', 'Praktikum Pemrograman Berorientasi Objek', 'M.Reza Zulman, SST., M.Sc.', 'TIK.105', true, 'Gasal 2026/2027'),
  ('TI2E-3', 'TI', 'TI 2E', 'Selasa', 1, 5, '07:30', '12:00', 'Praktikum Konsep Jaringan Komputer', 'Azhar, ST., MT', 'TIK.315', true, 'Gasal 2026/2027'),
  ('TI2E-4', 'TI', 'TI 2E', 'Selasa', 6, 7, '12:00', '14:20', 'Pengolahan Citra Digital (OBE)', 'Ahmad Afif, M. Kom.', 'TIK.307', false, 'Gasal 2026/2027'),
  ('TI2E-5', 'TI', 'TI 2E', 'Selasa', 8, 9, '14:20', '16:00', 'Konsep Jaringan Komputer', 'M. Khadafi, ST., M.T', 'TIK.214', false, 'Gasal 2026/2027'),
  ('TI2E-6', 'TI', 'TI 2E', 'Rabu', 1, 5, '07:30', '12:00', 'Praktikum Administrasi Basis Data', 'Dr.Rahmad Hidayat, S.Kom., M.Cs', 'TIK.102', true, 'Gasal 2026/2027'),
  ('TI2E-7', 'TI', 'TI 2E', 'Rabu', 8, 9, '14:20', '16:00', 'Rekayasa Perangkat Lunak', 'Azhar, ST., MT', 'TIK.212', false, 'Gasal 2026/2027'),
  ('TI2E-8', 'TI', 'TI 2E', 'Kamis', 1, 5, '07:30', '12:00', 'Workshop Web Enterprise (MVC, Framework)', 'Husna Gemasih, S.Inf., M.Cs', 'TIK.106', true, 'Gasal 2026/2027'),
  ('TI2E-9', 'TI', 'TI 2E', 'Kamis', 5, 6, '11:10', '12:50', 'Pemrograman Berorientasi Objek', 'M.Reza Zulman, SST., M.Sc.', 'TIK.316', false, 'Gasal 2026/2027'),
  ('TI2E-10', 'TI', 'TI 2E', 'Kamis', 7, 8, '13:30', '15:10', 'English for Academic Writing', 'Nurul Kamaliah, S.Pd, M.Pd', 'TIK.311', false, 'Gasal 2026/2027'),
  ('TI2E-11', 'TI', 'TI 2E', 'Jumat', 1, 5, '07:30', '12:00', 'Praktikum Pengolahan Citra Digital (OBE)', 'Mutiara S. Simanjuntak, S.Kom., M. Kom', 'TIK.106', true, 'Gasal 2026/2027'),
  ('TI3A-1', 'TI', 'TI 3A', 'Senin', 3, 4, '09:10', '11:10', 'Bahasa Indonesia', 'Dra. Jamilah, M.Pd', 'TIK.211', false, 'Gasal 2026/2027'),
  ('TI3A-2', 'TI', 'TI 3A', 'Senin', 7, 11, '13:30', '18:00', 'Praktikum Keamanan Jaringan Komputer', 'Radhiyatammardhiyah, SST., M.Sc.', 'TIK.315', true, 'Gasal 2026/2027'),
  ('TI3A-3', 'TI', 'TI 3A', 'Selasa', 1, 3, '07:30', '10:00', 'Praktikum Pengolahan Citra Digital', 'Ahmad Afif, M. Kom.', 'TIK.102', true, 'Gasal 2026/2027'),
  ('TI3A-4', 'TI', 'TI 3A', 'Selasa', 6, 7, '12:00', '14:20', 'Keamanan Jaringan Komputer', 'M. Khadafi, ST., M.T', 'TIK.214', false, 'Gasal 2026/2027'),
  ('TI3A-5', 'TI', 'TI 3A', 'Rabu', 1, 2, '07:30', '09:10', 'Pengolahan Citra Digital', 'Mutiara S. Simanjuntak, S.Kom., M. Kom', 'TIK.304', false, 'Gasal 2026/2027'),
  ('TI3A-6', 'TI', 'TI 3A', 'Rabu', 4, 6, '10:20', '12:50', 'Workshop Pengembangan Perangkat Lunak', 'Salahuddin, ST., M.Cs.', 'TIK.103', true, 'Gasal 2026/2027'),
  ('TI3A-7', 'TI', 'TI 3A', 'Rabu', 7, 11, '13:30', '18:00', 'Praktikum Pemrograman Mobile', 'Muhammad Rizka, SST., M. Kom.', 'TIK.106', true, 'Gasal 2026/2027'),
  ('TI3A-8', 'TI', 'TI 3A', 'Kamis', 1, 2, '07:30', '09:10', 'Pemrograman Mobile', 'Arwin Putra, M.Kom', 'TIK.301', false, 'Gasal 2026/2027'),
  ('TI3A-9', 'TI', 'TI 3A', 'Kamis', 3, 4, '09:10', '11:10', 'Sistem Pengambilan Keputusan Dan SIM-SIG', 'Mahdi, ST., M.Cs', 'TIK.315', false, 'Gasal 2026/2027'),
  ('TI3A-10', 'TI', 'TI 3A', 'Jumat', 1, 2, '07:30', '09:10', 'Statistik dan Probabilitas', 'Syukri, ST, MT', 'TIK.213', false, 'Gasal 2026/2027'),
  ('TI3A-11', 'TI', 'TI 3A', 'Jumat', 3, 4, '09:10', '11:10', 'Rancangan Analisa Algoritma', 'Husna Gemasih, S.Inf., M.Cs', 'TIK.303', false, 'Gasal 2026/2027'),
  ('TI3B-1', 'TI', 'TI 3B', 'Senin', 1, 3, '07:30', '10:00', 'Workshop Pengembangan Perangkat Lunak', 'Radhiyatammardhiyah, SST., M.Sc.', 'TIK.106', true, 'Gasal 2026/2027'),
  ('TI3B-2', 'TI', 'TI 3B', 'Senin', 4, 5, '10:20', '12:00', 'Keamanan Jaringan Komputer', 'M. Khadafi, ST., M.T', 'TIK.214', false, 'Gasal 2026/2027'),
  ('TI3B-3', 'TI', 'TI 3B', 'Senin', 6, 7, '12:00', '14:20', 'Pemrograman Mobile', 'Muhammad Rizka, SST., M. Kom.', 'TIK.214', false, 'Gasal 2026/2027'),
  ('TI3B-4', 'TI', 'TI 3B', 'Selasa', 1, 2, '07:30', '09:10', 'Pengolahan Citra Digital', 'Dr.Rahmad Hidayat, S.Kom., M.Cs', 'TIK.214', false, 'Gasal 2026/2027'),
  ('TI3B-5', 'TI', 'TI 3B', 'Selasa', 3, 4, '09:10', '11:10', 'Bahasa Indonesia', 'Dra. Jamilah, M.Pd', 'TIK.214', false, 'Gasal 2026/2027'),
  ('TI3B-6', 'TI', 'TI 3B', 'Selasa', 5, 6, '11:10', '12:50', 'Sistem Pengambilan Keputusan Dan SIM-SIG', 'Mahdi, ST., M.Cs', 'TIK.316', false, 'Gasal 2026/2027'),
  ('TI3B-7', 'TI', 'TI 3B', 'Rabu', 1, 3, '07:30', '10:00', 'Praktikum Keamanan Jaringan Komputer', 'Radhiyatammardhiyah, SST., M.Sc.', 'TIK.109', true, 'Gasal 2026/2027'),
  ('TI3B-8', 'TI', 'TI 3B', 'Rabu', 7, 9, '13:30', '16:00', 'Praktikum Pengolahan Citra Digital', 'Dr.Rahmad Hidayat, S.Kom., M.Cs', 'TIK.102', true, 'Gasal 2026/2027'),
  ('TI3B-9', 'TI', 'TI 3B', 'Kamis', 1, 2, '07:30', '09:10', 'Pengantar Teknik Informatika dan Orkom', 'Mulyadi, ST., M.Eng.', 'TIK.315', false, 'Gasal 2026/2027'),
  ('TI3B-10', 'TI', 'TI 3B', 'Jumat', 1, 2, '07:30', '09:10', 'Rancangan Analisa Algoritma', 'Husna Gemasih, S.Inf., M.Cs', 'TIK.302', false, 'Gasal 2026/2027'),
  ('TI3B-11', 'TI', 'TI 3B', 'Jumat', 3, 4, '09:10', '11:10', 'Statistik dan Probabilitas', 'Syukri, ST, MT', 'TIK.213', false, 'Gasal 2026/2027'),
  ('TI3B-12', 'TI', 'TI 3B', 'Jumat', 7, 11, '13:30', '18:00', 'Praktikum Pemrograman Mobile', 'Muhammad Rizka, SST., M. Kom.', 'TIK.213', true, 'Gasal 2026/2027'),
  ('TI3C-1', 'TI', 'TI 3C', 'Senin', 1, 2, '07:30', '09:10', 'Bahasa Indonesia', 'Dra. Jamilah, M.Pd', 'TIK.211', false, 'Gasal 2026/2027'),
  ('TI3C-2', 'TI', 'TI 3C', 'Senin', 3, 4, '09:10', '11:10', 'Pengantar Teknik Informatika dan Orkom', 'Mulyadi, ST., M.Eng.', 'TIK.306', false, 'Gasal 2026/2027'),
  ('TI3C-3', 'TI', 'TI 3C', 'Senin', 5, 6, '11:10', '12:50', 'Rancangan Analisa Algoritma', 'Muhammad Arhami, S.Si., M.Kom', 'TIK.305', false, 'Gasal 2026/2027'),
  ('TI3C-4', 'TI', 'TI 3C', 'Selasa', 1, 2, '07:30', '09:10', 'Sistem Pengambilan Keputusan Dan SIM-SIG', 'Salahuddin, ST., M.Cs.', 'TIK.309', false, 'Gasal 2026/2027'),
  ('TI3C-5', 'TI', 'TI 3C', 'Selasa', 6, 8, '12:00', '15:10', 'Praktikum Pengolahan Citra Digital', 'Mustainul Abdi, SST., M.Kom.', 'TIK.104', true, 'Gasal 2026/2027'),
  ('TI3C-6', 'TI', 'TI 3C', 'Rabu', 1, 2, '07:30', '09:10', 'Pemrograman Mobile', 'Muhammad Rizka, SST., M. Kom.', 'TIK.214', false, 'Gasal 2026/2027'),
  ('TI3C-7', 'TI', 'TI 3C', 'Rabu', 3, 4, '09:10', '11:10', 'Statistik dan Probabilitas', 'Dr. Ir. Rizal Syahyadi, ST, M.Eng.Sc', 'TIK.212', false, 'Gasal 2026/2027'),
  ('TI3C-8', 'TI', 'TI 3C', 'Rabu', 5, 6, '11:10', '12:50', 'Keamanan Jaringan Komputer', 'M. Khadafi, ST., M.T', 'TIK.211', false, 'Gasal 2026/2027'),
  ('TI3C-9', 'TI', 'TI 3C', 'Kamis', 1, 3, '07:30', '10:00', 'Workshop Pengembangan Perangkat Lunak', 'Salahuddin, ST., M.Cs.', 'TIK.101', true, 'Gasal 2026/2027'),
  ('TI3C-10', 'TI', 'TI 3C', 'Kamis', 4, 5, '10:20', '12:00', 'Pengolahan Citra Digital', 'Mustainul Abdi, SST., M.Kom.', 'TIK.305', false, 'Gasal 2026/2027'),
  ('TI3C-11', 'TI', 'TI 3C', 'Kamis', 7, 11, '13:30', '18:00', 'Praktikum Pemrograman Mobile', 'Muhammad Rizka, SST., M. Kom.', 'TIK.303', true, 'Gasal 2026/2027'),
  ('TI3C-12', 'TI', 'TI 3C', 'Jumat', 1, 5, '07:30', '12:00', 'Praktikum Keamanan Jaringan Komputer', 'Radhiyatammardhiyah, SST., M.Sc.', 'TIK.109', true, 'Gasal 2026/2027'),
  ('TI3D-1', 'TI', 'TI 3D', 'Senin', 1, 5, '07:30', '12:00', 'Praktikum Pemrograman Mobile', 'Muhammad Rizka, SST., M. Kom.', 'TIK.104', true, 'Gasal 2026/2027'),
  ('TI3D-2', 'TI', 'TI 3D', 'Senin', 7, 9, '13:30', '16:00', 'Praktikum Pengolahan Citra Digital', 'Mustainul Abdi, SST., M.Kom.', 'TIK.101', true, 'Gasal 2026/2027'),
  ('TI3D-3', 'TI', 'TI 3D', 'Selasa', 1, 2, '07:30', '09:10', 'Pemrograman Mobile', 'Muhammad Rizka, SST., M. Kom.', 'TIK.305', false, 'Gasal 2026/2027'),
  ('TI3D-4', 'TI', 'TI 3D', 'Selasa', 3, 4, '09:10', '11:10', 'Rancangan Analisa Algoritma', 'Husna Gemasih, S.Inf., M.Cs', 'TIK.305', false, 'Gasal 2026/2027'),
  ('TI3D-5', 'TI', 'TI 3D', 'Selasa', 5, 7, '11:10', '14:20', 'Workshop Pengembangan Perangkat Lunak', 'Arsy Febrina Dewi, SST., M.T', 'TIK.102', true, 'Gasal 2026/2027'),
  ('TI3D-6', 'TI', 'TI 3D', 'Rabu', 1, 2, '07:30', '09:10', 'Statistik dan Probabilitas', 'Dr. Ir. Rizal Syahyadi, ST, M.Eng.Sc', 'TIK.212', false, 'Gasal 2026/2027'),
  ('TI3D-7', 'TI', 'TI 3D', 'Rabu', 3, 4, '09:10', '11:10', 'Bahasa Indonesia', 'Dra. Jamilah, M.Pd', 'TIK.209', false, 'Gasal 2026/2027'),
  ('TI3D-8', 'TI', 'TI 3D', 'Kamis', 1, 2, '07:30', '09:10', 'Pengolahan Citra Digital', 'Mustainul Abdi, SST., M.Kom.', 'TIK.305', false, 'Gasal 2026/2027'),
  ('TI3D-9', 'TI', 'TI 3D', 'Kamis', 5, 6, '11:10', '12:50', 'Keamanan Jaringan Komputer', 'M. Khadafi, ST., M.T', 'TIK.214', false, 'Gasal 2026/2027'),
  ('TI3D-10', 'TI', 'TI 3D', 'Jumat', 3, 4, '09:10', '11:10', 'Sistem Pengambilan Keputusan Dan SIM-SIG', 'Mahdi, ST., M.Cs', 'TIK.316', false, 'Gasal 2026/2027'),
  ('TI3D-11', 'TI', 'TI 3D', 'Jumat', 7, 11, '13:30', '18:00', 'Praktikum Keamanan Jaringan Komputer', 'Radhiyatammardhiyah, SST., M.Sc.', 'TIK.109', true, 'Gasal 2026/2027'),
  ('TI3E-1', 'TI', 'TI 3E', 'Senin', 1, 2, '07:30', '09:10', 'Keamanan Jaringan Komputer', 'M. Khadafi, ST., M.T', 'TIK.214', false, 'Gasal 2026/2027'),
  ('TI3E-2', 'TI', 'TI 3E', 'Senin', 4, 5, '10:20', '12:00', 'Sistem Pengambilan Keputusan Dan SIM-SIG', 'Mahdi, ST., M.Cs', 'TIK.308', false, 'Gasal 2026/2027'),
  ('TI3E-3', 'TI', 'TI 3E', 'Senin', 7, 8, '13:30', '15:10', 'Pemrograman Mobile', 'Arwin Putra, M.Kom', 'TIK.305', false, 'Gasal 2026/2027'),
  ('TI3E-4', 'TI', 'TI 3E', 'Selasa', 4, 5, '10:20', '12:00', 'Pengolahan Citra Digital', 'Mustainul Abdi, SST., M.Kom.', 'TIK.301', false, 'Gasal 2026/2027'),
  ('TI3E-5', 'TI', 'TI 3E', 'Selasa', 7, 11, '13:30', '18:00', 'Praktikum Pemrograman Mobile', 'Arwin Putra, M.Kom', 'TIK.106', true, 'Gasal 2026/2027'),
  ('TI3E-6', 'TI', 'TI 3E', 'Rabu', 1, 3, '07:30', '10:00', 'Praktikum Pengolahan Citra Digital', 'Mustainul Abdi, SST., M.Kom.', 'TIK.101', true, 'Gasal 2026/2027'),
  ('TI3E-7', 'TI', 'TI 3E', 'Rabu', 4, 8, '10:20', '15:10', 'Praktikum Keamanan Jaringan Komputer', 'Radhiyatammardhiyah, SST., M.Sc.', 'TIK.307', true, 'Gasal 2026/2027'),
  ('TI3E-8', 'TI', 'TI 3E', 'Kamis', 1, 3, '07:30', '10:00', 'Workshop Pengembangan Perangkat Lunak', 'Ghiyalti Novilia, SST, MT', 'TIK.102', true, 'Gasal 2026/2027'),
  ('TI3E-9', 'TI', 'TI 3E', 'Kamis', 4, 5, '10:20', '12:00', 'Rancangan Analisa Algoritma', 'Ghiyalti Novilia, SST, MT', 'TIK.303', false, 'Gasal 2026/2027'),
  ('TI3E-10', 'TI', 'TI 3E', 'Kamis', 6, 7, '12:00', '14:20', 'Statistik dan Probabilitas', 'Muhammad A Rifai , SE AK, Msc', 'TIK.213', false, 'Gasal 2026/2027'),
  ('TI3E-11', 'TI', 'TI 3E', 'Jumat', 3, 4, '09:10', '11:10', 'Bahasa Indonesia', 'Dra. Jamilah, M.Pd', 'TIK.211', false, 'Gasal 2026/2027'),
  ('TRPL1A-1', 'TRPL', 'TRPL 1A', 'Senin', 7, 8, '13:30', '15:10', 'Pendidikan Agama', 'Nazar Fadli, M.Ag., Ph.D.', 'TIK.213', false, 'Gasal 2026/2027'),
  ('TRPL1A-2', 'TRPL', 'TRPL 1A', 'Selasa', 1, 3, '07:30', '10:00', 'Workshop Pemograman Dasar', 'Mustainul Abdi, SST., M.Kom.', 'TIK.105', true, 'Gasal 2026/2027'),
  ('TRPL1A-3', 'TRPL', 'TRPL 1A', 'Selasa', 4, 5, '10:20', '12:00', 'Interaksi Manusia dan Komputer', 'Fachri Yanuar Rudi F, S.ST., M.T.', 'TIK.213', false, 'Gasal 2026/2027'),
  ('TRPL1A-4', 'TRPL', 'TRPL 1A', 'Selasa', 7, 11, '13:30', '18:00', 'Praktikum Dasar Jaringan Komputer', 'Muhammad Davi, S.Kom., M.Cs.', 'TIK.109', true, 'Gasal 2026/2027'),
  ('TRPL1A-5', 'TRPL', 'TRPL 1A', 'Rabu', 1, 3, '07:30', '10:00', 'Pengantar Rekayasa Perangkat Lunak', 'M.Reza Zulman, SST., M.Sc.', 'TIK.105', false, 'Gasal 2026/2027'),
  ('TRPL1A-6', 'TRPL', 'TRPL 1A', 'Rabu', 5, 6, '11:10', '12:50', 'Pendidikan Pancasila', 'Hosea Sitepu, M.Pd', 'TIK.316', false, 'Gasal 2026/2027'),
  ('TRPL1A-7', 'TRPL', 'TRPL 1A', 'Rabu', 9, 10, '15:10', '17:10', 'Analisis dan Spesifikasi Kebutuhan Perangkat Lunak', 'Safriadi ST, M.Kom.', 'TIK.310', false, 'Gasal 2026/2027'),
  ('TRPL1A-8', 'TRPL', 'TRPL 1A', 'Kamis', 1, 2, '07:30', '09:10', 'Konsep Dasar Jaringan Komputer', 'Muhammad Davi, S.Kom., M.Cs.', 'TIK.309', false, 'Gasal 2026/2027'),
  ('TRPL1A-9', 'TRPL', 'TRPL 1A', 'Kamis', 5, 7, '11:10', '14:20', 'Bahasa Inggris Umum', 'Mahlil, S.Pd., M.A', 'TIK.313', false, 'Gasal 2026/2027'),
  ('TRPL1A-10', 'TRPL', 'TRPL 1A', 'Kamis', 8, 10, '14:20', '17:10', 'Basis Data', 'Guntur Syahputra, S. Kom., M. Kom.', 'TIK.105', false, 'Gasal 2026/2027')
ON CONFLICT (id) DO UPDATE
SET study_program = EXCLUDED.study_program,
    class_name = EXCLUDED.class_name,
    day = EXCLUDED.day,
    start_session = EXCLUDED.start_session,
    end_session = EXCLUDED.end_session,
    start_time = EXCLUDED.start_time,
    end_time = EXCLUDED.end_time,
    course_name = EXCLUDED.course_name,
    lecturer_name = EXCLUDED.lecturer_name,
    room_code = EXCLUDED.room_code,
    is_practicum = EXCLUDED.is_practicum,
    semester = EXCLUDED.semester;

