-- ==============================================================================
-- SKRIP LENGKAP BACKEND SUPABASE (ZERO-DEPENDENCY & 100% PRODUCTION READY)
-- SISTEM MANAJEMEN PEMINJAMAN LABORATORIUM & RUANG KELAS (SIM-LAB & RUANG PBM)
-- JURUSAN TEKNOLOGI INFORMASI DAN KOMPUTER - POLITEKNIK NEGERI LHOKSEUMAWE
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
  id          TEXT PRIMARY KEY,             -- Contoh: 'TIK.101', 'TDC-202'
  name        TEXT NOT NULL,
  type        TEXT NOT NULL CHECK (type IN ('lab', 'theoryClass', 'studio')),
  floor       INTEGER NOT NULL DEFAULT 1,
  building    TEXT NOT NULL DEFAULT 'Gedung TIK',
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
  id              TEXT PRIMARY KEY,        -- Contoh: 'TRMM1A-SENIN-1-3-TIK101'
  study_program   TEXT NOT NULL,           -- 'TRMM', 'TRKJ', 'TI'
  class_name      TEXT NOT NULL,           -- 'TRMM 1A', 'TI 3C'
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
  user_id                     UUID REFERENCES auth.users(id) ON DELETE SET NULL, -- Opsional / Nullable untuk Peminjam Tamu/Mahasiswa tanpa akun
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

-- 5. TABEL PROFIL PENGGUNA (EXTEND AUTH.USERS)
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

-- Auto Trigger Profile saat Register Baru
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
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
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 6. STORED PROCEDURE CEK BENTROK JADWAL
CREATE OR REPLACE FUNCTION public.check_booking_conflict(
  p_room_code    TEXT,
  p_day          TEXT,
  p_start_session INTEGER,
  p_end_session   INTEGER,
  p_booking_date  DATE,
  p_exclude_id    UUID DEFAULT NULL
)
RETURNS TABLE(has_conflict BOOLEAN, conflict_type TEXT, message TEXT)
LANGUAGE plpgsql AS $$
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
$$;

-- 8. ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roster_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.receptionist_officers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policy Rooms (Publik & Authenticated bisa lihat master ruang)
DROP POLICY IF EXISTS "rooms_read_all" ON public.rooms;
CREATE POLICY "rooms_read_all" ON public.rooms FOR SELECT USING (true);

DROP POLICY IF EXISTS "rooms_manage_admin" ON public.rooms;
CREATE POLICY "rooms_manage_admin" ON public.rooms FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'laboran')));

-- Policy Roster (Publik & Mahasiswa bisa lihat roster jadwal hari ini)
DROP POLICY IF EXISTS "roster_read_all" ON public.roster_items;
CREATE POLICY "roster_read_all" ON public.roster_items FOR SELECT USING (true);

DROP POLICY IF EXISTS "roster_manage_admin" ON public.roster_items;
CREATE POLICY "roster_manage_admin" ON public.roster_items FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'laboran')));

-- Policy Receptionist Officers (Publik/Kiosk/PC bisa baca & ubah dosen piket secara sinkron)
DROP POLICY IF EXISTS "officers_read_all" ON public.receptionist_officers;
DROP POLICY IF EXISTS "officers_manage_admin" ON public.receptionist_officers;
CREATE POLICY "officers_select_policy" ON public.receptionist_officers FOR SELECT USING (true);
CREATE POLICY "officers_insert_policy" ON public.receptionist_officers FOR INSERT WITH CHECK (true);
CREATE POLICY "officers_update_policy" ON public.receptionist_officers FOR UPDATE USING (true);

-- Policy Bookings (Bisa dibaca semua & bisa di-insert mahasiswa tanpa akun)
DROP POLICY IF EXISTS "bookings_select_policy" ON public.bookings;
CREATE POLICY "bookings_select_policy" ON public.bookings FOR SELECT USING (true);

DROP POLICY IF EXISTS "bookings_insert_policy" ON public.bookings;
CREATE POLICY "bookings_insert_policy" ON public.bookings FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "bookings_update_policy" ON public.bookings;
CREATE POLICY "bookings_update_policy" ON public.bookings FOR UPDATE USING (true);

-- Policy Profiles
DROP POLICY IF EXISTS "profiles_select_policy" ON public.profiles;
CREATE POLICY "profiles_select_policy" ON public.profiles FOR SELECT TO authenticated
  USING (
    id = auth.uid() OR
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'laboran'))
  );

DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
CREATE POLICY "profiles_update_own" ON public.profiles FOR UPDATE TO authenticated
  USING (id = auth.uid());

-- 8. STORAGE BUCKET UNTUK VIDEO CHECKOUT KEBERSIHAN & AC
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'video-inspeksi',
  'video-inspeksi',
  TRUE,
  524288000, -- 500 MB
  ARRAY['video/mp4', 'video/quicktime', 'video/webm', 'video/x-msvideo', 'video/3gpp']
)
ON CONFLICT (id) DO UPDATE
SET public = TRUE,
    file_size_limit = 524288000;

-- Storage Policies
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
CREATE POLICY "Allow authenticated uploads" ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'video-inspeksi');

DROP POLICY IF EXISTS "Allow public read video" ON storage.objects;
CREATE POLICY "Allow public read video" ON storage.objects FOR SELECT TO public
  USING (bucket_id = 'video-inspeksi');

DROP POLICY IF EXISTS "Allow authenticated update video" ON storage.objects;
CREATE POLICY "Allow authenticated update video" ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'video-inspeksi');
