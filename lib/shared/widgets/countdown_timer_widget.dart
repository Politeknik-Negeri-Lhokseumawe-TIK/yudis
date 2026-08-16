import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

/// Widget Countdown Timer real-time dengan tampilan flip card glassmorphism
/// Menghitung mundur menuju target DateTime (misal: 26 Agustus 2026).
class CountdownTimerWidget extends StatefulWidget {
  const CountdownTimerWidget({
    super.key,
    required this.targetDate,
    this.compact = false,
  });

  final DateTime targetDate;
  final bool compact;

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(_calculateRemaining);
      }
    });
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    if (widget.targetDate.isAfter(now)) {
      _remaining = widget.targetDate.difference(now);
    } else {
      _remaining = Duration.zero;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    // Warna status berdasarkan urgensi deadline
    final Color statusColor;
    final String statusLabel;
    if (days > 7) {
      statusColor = AppTokens.success;
      statusLabel = 'Pendaftaran Dibuka';
    } else if (days > 2) {
      statusColor = AppTokens.accentGold;
      statusLabel = 'Segera Berakhir';
    } else {
      statusColor = AppTokens.error;
      statusLabel = 'Mendekati Batas Akhir!';
    }

    if (widget.compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppTokens.radiusSM),
          border: Border.all(color: statusColor.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 14, color: statusColor),
            const SizedBox(width: 6),
            Text(
              'Sisa Waktu: ${days}h ${hours}j ${minutes}m',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppTokens.spaceMD),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.7),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Sisa Waktu Pendaftaran',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTokens.radiusCircle),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceMD),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeUnit(context, days.toString().padLeft(2, '0'), 'Hari', statusColor),
              _buildColon(),
              _buildTimeUnit(context, hours.toString().padLeft(2, '0'), 'Jam', statusColor),
              _buildColon(),
              _buildTimeUnit(context, minutes.toString().padLeft(2, '0'), 'Menit', statusColor),
              _buildColon(),
              _buildTimeUnit(context, seconds.toString().padLeft(2, '0'), 'Detik', statusColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColon() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: Text(
        ':',
        style: TextStyle(
          color: Colors.white38,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeUnit(BuildContext context, String value, String unit, Color accent) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTokens.primaryPurple.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.03),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(AppTokens.radiusSM),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              unit,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
