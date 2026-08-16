import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';

enum ActivityType {
  pendaftaranBaru,
  verifikasiDokumen,
  verifikasiAkun,
  resetPassword,
  uploadDokumen,
}

class ActivityLog {
  const ActivityLog({
    required this.id,
    required this.type,
    required this.actorName,
    required this.targetName,
    required this.timestamp,
    required this.description,
  });

  final String id;
  final ActivityType type;
  final String actorName;
  final String targetName;
  final DateTime timestamp;
  final String description;

  IconData get icon => switch (type) {
        ActivityType.pendaftaranBaru => Icons.assignment_turned_in_rounded,
        ActivityType.verifikasiDokumen => Icons.fact_check_rounded,
        ActivityType.verifikasiAkun => Icons.verified_user_rounded,
        ActivityType.resetPassword => Icons.key_rounded,
        ActivityType.uploadDokumen => Icons.cloud_upload_rounded,
      };

  Color get color => switch (type) {
        ActivityType.pendaftaranBaru => AppTokens.primaryPurpleLight,
        ActivityType.verifikasiDokumen => AppTokens.success,
        ActivityType.verifikasiAkun => AppTokens.accentGoldLight,
        ActivityType.resetPassword => AppTokens.accentGold,
        ActivityType.uploadDokumen => AppTokens.info,
      };
}
