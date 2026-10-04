import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/streak_service.dart';
import '../theme/colors.dart';
import '../theme/iconly_icons.dart';

class DailyStreakCard extends StatelessWidget {
  final DailyStreakInfo? streakInfo;
  final VoidCallback onActionTap;

  const DailyStreakCard({
    super.key,
    required this.streakInfo,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DhanWiserColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final streak = streakInfo?.streakDays ?? 1;
    final tip = streakInfo?.dailyTip ??
        '💡 Settle balances within 24h to keep groups in harmony.';
    final ledgerStatus = streakInfo?.ledgerStatus ?? '✨ Clean Ledger';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? colors.surfaceContainer
            : colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? colors.primaryFixed.withValues(alpha: 0.2)
              : colors.outlineVariant.withValues(alpha: 0.8),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0x33000000)
                : colors.primaryFixed.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Streak Counter + Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                const Color(0xFFFF7D3B),
                                const Color(0xFFEA580C),
                              ]
                            : [
                                const Color(0xFFFFECE5),
                                const Color(0xFFFFD8CC),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 5),
                        Text(
                          '$streak ${streak == 1 ? 'Day' : 'Days'} In Sync',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : colors.primaryFixed,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onActionTap,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colors.primaryFixed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Review',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.primaryFixed,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        IconlyLight.arrowRight2,
                        size: 12,
                        color: colors.primaryFixed,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Ledger status text
          Text(
            ledgerStatus,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),

          // Daily Financial Tip
          Text(
            tip,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
