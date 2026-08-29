library;

/// Konfigurasi Supabase Backend — Sistem Manajemen Peminjaman Ruang & Lab PBM TIK PNL
/// Settings → API → Project URL & anon/public key

const String supabaseUrl = 'https://oojqbdnopdbolyuprmqa.supabase.co';
const String supabaseAnonKey = 'sb_publishable_eo50rFNcCtRttuxEEB4C3A_qXh-Nxcl';

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
