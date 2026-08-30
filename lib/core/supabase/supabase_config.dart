library;

/// Konfigurasi Supabase Backend — Sistem Manajemen Peminjaman Ruang & Lab PBM TIK PNL
/// Settings → API → Project URL & anon/public key

const String supabaseUrl = 'https://oojqbdnopdbolyuprmqa.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9vanFiZG5vcGRib2x5dXBybXFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY4ODg3NDUsImV4cCI6MjEwMjQ2NDc0NX0.jM_AdvtChC06bH9b1ByUSVOkIQUkWysFyBJX1-yqxps';

/// Supabase Tables & Storage Buckets
class SupabaseTables {
  SupabaseTables._();

  static const String rooms = 'rooms';
  static const String rosterItems = 'roster_items';
  static const String bookings = 'bookings';
  static const String profiles = 'profiles';
}

class SupabaseBuckets {
  SupabaseBuckets._();

  static const String videoInspeksi = 'video-inspeksi';
}
