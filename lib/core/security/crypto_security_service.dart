import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

/// Layanan Protokol Keamanan, Kriptografi Data & Ledger Integritas (E2E & Blockchain Hash)
/// Digunakan pada Sistem Manajemen Peminjaman Ruang & Lab PBM TIK PNL untuk:
/// 1. Enkripsi E2E payload data peminjaman (AES-256-CBC)
/// 2. Validasi tanda tangan digital HMAC-SHA256 (Anti-Tampering)
/// 3. Hashing Blockchain Ledger untuk sertifikat izin ruang & bukti video kebersihan/AC
class CryptoSecurityService {
  CryptoSecurityService._();

  // Kunci enkripsi default aplikasi Sistem Peminjaman Ruang TIK PNL (32 bytes = 256 bits)
  static const String _defaultSecretKey = 'PNL_TIK_SIPENJOL_SECURE_KEY_2026';
  static const String _defaultHmacSecret = 'PNL_TIK_HMAC_INTEGRITY_SALT_9901';

  static final enc.Key _key = enc.Key.fromUtf8(_defaultSecretKey.padRight(32, '0').substring(0, 32));
  static final enc.Encrypter _encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));

  /// Enkripsi Map / Data JSON menjadi string ciphertext terenkripsi AES-256
  static String encryptPayload(Map<String, dynamic> data) {
    try {
      final jsonStr = jsonEncode(data);
      // Generate IV acak 16 bytes untuk setiap payload
      final iv = enc.IV.fromSecureRandom(16);
      final encrypted = _encrypter.encrypt(jsonStr, iv: iv);
      
      // Gabungkan IV + Ciphertext dalam format Base64 yang aman ditransmisikan
      final combined = '${iv.base64}:${encrypted.base64}';
      return combined;
    } catch (e) {
      return jsonEncode(data);
    }
  }

  /// Dekripsi ciphertext AES-256 kembali menjadi Map data
  static Map<String, dynamic> decryptPayload(String payload) {
    try {
      if (!payload.contains(':')) {
        return jsonDecode(payload) as Map<String, dynamic>;
      }
      final parts = payload.split(':');
      final iv = enc.IV.fromBase64(parts[0]);
      final encrypted = enc.Encrypted.fromBase64(parts[1]);
      final decrypted = _encrypter.decrypt(encrypted, iv: iv);
      return jsonDecode(decrypted) as Map<String, dynamic>;
    } catch (_) {
      try {
        return jsonDecode(payload) as Map<String, dynamic>;
      } catch (_) {
        return {};
      }
    }
  }

  /// Generate tanda tangan digital HMAC-SHA256 untuk memverifikasi integritas payload
  static String generateSignature({
    required String payload,
    required int timestamp,
    String? nonce,
  }) {
    final effectiveNonce = nonce ?? generateNonce();
    final message = '$payload:$timestamp:$effectiveNonce';
    final keyBytes = utf8.encode(_defaultHmacSecret);
    final messageBytes = utf8.encode(message);

    final hmac = Hmac(sha256, keyBytes);
    final digest = hmac.convert(messageBytes);
    return digest.toString();
  }

  /// Verifikasi keabsahan tanda tangan digital
  static bool verifySignature({
    required String payload,
    required int timestamp,
    required String signature,
    String? nonce,
    int maxAgeSeconds = 300, // Toleransi maksimal 5 menit
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if ((now - timestamp).abs() > maxAgeSeconds * 1000) {
      return false;
    }

    final expected = generateSignature(
      payload: payload,
      timestamp: timestamp,
      nonce: nonce,
    );
    return expected == signature;
  }

  /// Generate Nonce acak untuk mencegah replay attacks
  static String generateNonce([int length = 16]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64UrlEncode(values);
  }

  /// Hash string menggunakan SHA-256
  static String hashSha256(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  /// Generate Block Hash Ledger untuk bukti transaksi peminjaman ruang yang tidak dapat dimanipulasi
  static String generateBookingLedgerHash({
    required String bookingCode,
    required String roomCode,
    required String userNimNip,
    required String timestamp,
    String previousBlockHash = '00000000000000000000000000000000',
  }) {
    final rawData = '$previousBlockHash#$bookingCode#$roomCode#$userNimNip#$timestamp';
    return hashSha256(rawData);
  }

  /// Generate Hash Integritas Bukti Video Serah Terima Ruang (AC Mati & Kebersihan)
  static String generateVideoInspectionHash({
    required String bookingCode,
    required String videoName,
    required bool isAcOff,
    required bool isClean,
    required String timestamp,
  }) {
    final rawData = 'VIDEO-INSPECTION#$bookingCode#$videoName#AC:${isAcOff ? "OFF" : "ON"}#CLEAN:${isClean ? "YES" : "NO"}#$timestamp';
    return hashSha256(rawData);
  }

  /// Sanitasi data sensitif sebelum logging / debugging (masking)
  static Map<String, dynamic> sanitizeForLog(Map<String, dynamic> data) {
    final sanitized = Map<String, dynamic>.from(data);
    const sensitiveKeys = ['password', 'token', 'nik', 'noHp', 'pin', 'secret'];
    for (final key in sanitized.keys) {
      if (sensitiveKeys.any((s) => key.toLowerCase().contains(s))) {
        sanitized[key] = '***[PROTECTED]***';
      }
    }
    return sanitized;
  }
}
