import 'dart:convert';
import 'package:dio/dio.dart';
import '../security/crypto_security_service.dart';

/// Interceptor Dio untuk protokol keamanan jaringan dan data end-to-end.
/// Menyematkan signature integritas HMAC-SHA256, timestamp anti-replay,
/// dan mengenkripsi payload request secara transparan.
class SecurityInterceptor extends Interceptor {
  SecurityInterceptor({this.enablePayloadEncryption = false});

  final bool enablePayloadEncryption;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final nonce = CryptoSecurityService.generateNonce();

    // Serialize body untuk pembuatan signature
    String bodyString = '';
    if (options.data != null) {
      if (options.data is Map<String, dynamic>) {
        bodyString = jsonEncode(options.data);
      } else {
        bodyString = options.data.toString();
      }
    }

    // Buat digital signature HMAC-SHA256
    final signature = CryptoSecurityService.generateSignature(
      payload: bodyString,
      timestamp: timestamp,
      nonce: nonce,
    );

    // Sisipkan protokol security headers
    options.headers['X-Client-Timestamp'] = timestamp.toString();
    options.headers['X-Nonce'] = nonce;
    options.headers['X-Request-Signature'] = signature;
    options.headers['X-Security-Protocol'] = 'AES256-HMAC-SHA256';
    options.headers['X-Client-Version'] = '1.0.0';

    // Opsional: enkripsi payload in-transit jika diaktifkan
    if (enablePayloadEncryption && options.data is Map<String, dynamic>) {
      final encryptedBody = CryptoSecurityService.encryptPayload(
        options.data as Map<String, dynamic>,
      );
      options.data = {'encrypted_payload': encryptedBody};
      options.headers['X-Payload-Encrypted'] = 'true';
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Jika response terenkripsi, dekripsi secara transparan
    if (response.data is Map<String, dynamic> &&
        response.data['encrypted_payload'] != null) {
      final decrypted = CryptoSecurityService.decryptPayload(
        response.data['encrypted_payload'] as String,
      );
      response.data = decrypted;
    }
    super.onResponse(response, handler);
  }
}
