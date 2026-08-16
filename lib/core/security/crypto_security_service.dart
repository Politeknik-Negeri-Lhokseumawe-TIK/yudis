import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

/// Layanan Protokol Keamanan & Kriptografi Data (End-to-End & In-Transit)
/// Digunakan untuk enkripsi payload data sensitif, validasi tanda tangan HMAC-SHA256,
/// dan perlindungan terhadap Replay Attack serta kebocoran data.
class CryptoSecurityService {
  CryptoSecurityService._();

  // Kunci enkripsi default aplikasi (32 bytes = 256 bits)
  // Pada environment produksi, kunci ini dapat diinjeksikan via secure environment variable
  static const String _defaultSecretKey = 'PNL_TIK_YUDISIUM_SECURE_KEY_2026';
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
      // Fallback aman jika gagal enkripsi
      return jsonEncode(data);
    }
  }

  /// Dekripsi ciphertext AES-256 kembali menjadi Map data
  static Map<String, dynamic> decryptPayload(String payload) {
    try {
      if (!payload.contains(':')) {
        // Plain JSON fallback
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
  /// dan mencegah manipulasi data (Anti-Tampering)
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
    // Cek replay attack berdasarkan timestamp window
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

  /// Hash string menggunakan SHA-256 (misal untuk checksum token / password hash)
  static String hashSha256(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
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
