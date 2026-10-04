import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/iconly_icons.dart';
import '../theme/colors.dart';
import '../theme/design_tokens.dart';

/// Luxury Fintech Hero Balance Card inspired by Apple Card, Revolut & Stripe.
class HeroBalanceCard extends StatelessWidget {
  final double netBalance;
  final double owedToYou;
  final double youOwe;
  final bool isLoading;
  final VoidCallback? onSettleTap;
  final VoidCallback? onAddExpenseTap;

  const HeroBalanceCard({
    super.key,
    required this.netBalance,
    required this.owedToYou,
    required this.youOwe,
    this.isLoading = false,
    this.onSettleTap,
    this.onAddExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DhanWiserColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isSettled = netBalance.abs() < 0.01;
    final isPositive = netBalance > 0.01;

    final statusColor = isLoading
        ? colors.textSecondary
        : isSettled
            ? colors.textSecondary
            : (isPositive ? colors.positive : colors.negative);

    final statusText = isLoading
        ? 'Updating'
        : isSettled
            ? 'All Settled Up'
            : (isPositive ? 'You are owed' : 'You owe');

    return Container(
      decoration: BoxDecoration(
        borderRadius: DhanWiserTokens.radiusLarge,
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x28000000) : const Color(0x0A0F172A),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: DhanWiserTokens.radiusLarge,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? colors.card : Colors.white,
            borderRadius: DhanWiserTokens.radiusLarge,
            border: Border.all(
              color: colors.cardBorder,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Label & Status Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'NET BALANCE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Big, tabular hero amount.
                if (isLoading)
                  Container(
                    width: 190,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        netBalance.abs().toStringAsFixed(0),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                          color: colors.textPrimary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        '.${(netBalance.abs() % 1 * 100).toStringAsFixed(0).padLeft(2, '0')}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                // Divider with subtle gradient
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.outlineVariant.withValues(alpha: 0.8),
                        colors.outlineVariant.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Sub-stats: Owed to you vs You owe
                Row(
                  children: [
                    // Owed to you
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color:
                                  colors.primaryFixed.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              IconlyBold.arrowDown2,
                              size: 18,
                              color: colors.positive,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Owed to you',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isLoading
                                    ? '—'
                                    : '₹${owedToYou.toStringAsFixed(0)}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: colors.positive,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Vertical hairline divider
                    Container(
                      width: 1,
                      height: 36,
                      color: colors.outlineVariant.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 16),

                    // You owe
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: colors.negative.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              IconlyBold.arrowUp2,
                              size: 18,
                              color: colors.negative,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You owe',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isLoading
                                    ? '—'
                                    : '₹${youOwe.toStringAsFixed(0)}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: colors.negative,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onAddExpenseTap,
                        icon: const Icon(IconlyBold.plus, size: 19),
                        label: const Text('Add expense'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSettleTap,
                        icon: const Icon(IconlyBold.swap, size: 18),
                        label: const Text('Settle up'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
