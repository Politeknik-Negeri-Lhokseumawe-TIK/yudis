import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/glass_card.dart';

class ProdiProgressCard extends StatelessWidget {
  const ProdiProgressCard({
    super.key,
    required this.totalPendaftar,
    required this.trkjCount,
    required this.trmmCount,
    required this.tiCount,
  });

  final int totalPendaftar;
  final int trkjCount;
  final int trmmCount;
  final int tiCount;

  @override
  Widget build(BuildContext context) {
    final total = totalPendaftar > 0 ? totalPendaftar : 1;

    return GlassCard(
      padding: const EdgeInsets.all(AppTokens.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTokens.spaceXS),
                decoration: BoxDecoration(
                  color: AppTokens.primaryPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                ),
                child: const Icon(Icons.pie_chart_outline_rounded,
                    color: AppTokens.primaryPurpleLight, size: 18),
              ),
              const SizedBox(width: AppTokens.spaceSM),
              Text(
                'Distribusi per Program Studi',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceLG),

          // 1. TRKJ
          _buildProdiRow(
            context: context,
            name: 'Teknologi Rekayasa Komputer Jaringan',
            code: 'TRKJ',
            count: trkjCount,
            total: total,
            color: AppTokens.prodiTRKJ,
          ),
          const SizedBox(height: AppTokens.spaceMD),

          // 2. TRMM
          _buildProdiRow(
            context: context,
            name: 'Teknologi Rekayasa Multimedia',
            code: 'TRMM',
            count: trmmCount,
            total: total,
            color: AppTokens.prodiTRMM,
          ),
          const SizedBox(height: AppTokens.spaceMD),

          // 3. TI
          _buildProdiRow(
            context: context,
            name: 'Teknik Informatika',
            code: 'TI',
            count: tiCount,
            total: total,
            color: AppTokens.prodiTI,
          ),
        ],
      ),
    );
  }

  Widget _buildProdiRow({
    required BuildContext context,
    required String name,
    required String code,
    required int count,
    required int total,
    required Color color,
  }) {
    final ratio = (count / total).clamp(0.0, 1.0);
    final percent = (ratio * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withValues(alpha: 0.35)),
              ),
              child: Text(
                code,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$count Mahasiswa ($percent%)',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: ratio),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return LinearProgressIndicator(
                value: val,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.06),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              );
            },
          ),
        ),
      ],
    );
  }
}
