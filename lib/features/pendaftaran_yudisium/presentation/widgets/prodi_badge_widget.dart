import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/glass_card.dart';

/// Badge warna per program studi dengan glassmorphism
class ProdiBadgeWidget extends StatelessWidget {
  const ProdiBadgeWidget({
    super.key,
    required this.programStudi,
    this.size = ProdiBadgeSize.medium,
    this.showLabel = true,
  });

  final String programStudi; // 'TI', 'TRKJ', 'TRMM'
  final ProdiBadgeSize size;
  final bool showLabel;

  static Color colorFor(String prodi) => switch (prodi.toUpperCase()) {
        'TI'   => AppTokens.prodiTI,
        'TRKJ' => AppTokens.prodiTRKJ,
        'TRMM' => AppTokens.prodiTRMM,
        _      => AppTokens.primaryGreenLight,
      };

  static String labelFor(String prodi) => switch (prodi.toUpperCase()) {
        'TRKJ' => 'D4 - Teknologi Rekayasa Komputer Jaringan',
        'TRMM' => 'D4 - Teknologi Rekayasa Multimedia',
        'TI'   => 'D4 - Teknik Informatika',
        _      => prodi,
      };

  @override
  Widget build(BuildContext context) {
    final color = colorFor(programStudi);

    return switch (size) {
      ProdiBadgeSize.chip => _buildChip(context, color),
      ProdiBadgeSize.medium => _buildMedium(context, color),
      ProdiBadgeSize.large => _buildLarge(context, color),
    };
  }

  Widget _buildChip(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spaceSM,
        vertical: AppTokens.spaceXXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTokens.radiusCircle),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            programStudi.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: AppTokens.textXS,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedium(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spaceMD,
        vertical: AppTokens.spaceXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.radiusSM),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school_outlined, color: color, size: 16),
          const SizedBox(width: AppTokens.spaceXS),
          Text(
            programStudi.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: AppTokens.textSM,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLarge(BuildContext context, Color color) {
    return GlassCard(
      fillColor: color.withValues(alpha: 0.08),
      borderColor: color.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(AppTokens.spaceMD),
      child: Row(
        // mainAxisSize.min agar Row tidak memaksa Expanded ketika parent tidak
        // memberikan bounded width (misalnya sebagai non-Expanded child dari Row lain)
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTokens.radiusSM),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(Icons.school_rounded, color: color, size: 24),
          ),
          const SizedBox(width: AppTokens.spaceMD),
          if (showLabel)
            Flexible(
              // Flexible (bukan Expanded) — bisa menyusut ketika space tidak tersedia
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      programStudi.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontSize: AppTokens.textSM,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      labelFor(programStudi),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: color.withValues(alpha: 0.7),
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum ProdiBadgeSize { chip, medium, large }
