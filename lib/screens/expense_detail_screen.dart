import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final String title;
  final String amount;
  final String date;
  final String paidBy;
  final IconData categoryIcon;

  const ExpenseDetailScreen({
    super.key,
    this.title = 'Dinner at Social',
    this.amount = '₹4,500',
    this.date = 'Oct 12, 2024',
    this.paidBy = 'You',
    this.categoryIcon = Icons.restaurant,
  });

  String get _categoryEmoji {
    switch (categoryIcon) {
      case Icons.restaurant: return '🍕';
      case Icons.directions_car: return '🚗';
      case Icons.home: return '🏠';
      case Icons.lightbulb: return '💡';
      case Icons.movie: return '🎬';
      default: return '📦';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? DhanWiserColors.backgroundDark : DhanWiserColors.backgroundLight;
    final text = isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight;
    final sub = isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight;
    final surface = isDark ? DhanWiserColors.surfaceElevatedDark : Colors.white;

    final splits = [
      {'name': 'You', 'amount': '₹1,500', 'status': 'Paid'},
      {'name': 'Rahul', 'amount': '₹1,500', 'status': 'Unpaid'},
      {'name': 'Priya', 'amount': '₹1,500', 'status': 'Paid'},
    ];

    final splitColors = [DhanWiserColors.primary, DhanWiserColors.coral, DhanWiserColors.teal];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ── Header ──
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? DhanWiserColors.surfaceElevatedDark : DhanWiserColors.gray100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_back_rounded, color: text, size: 20),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? DhanWiserColors.surfaceElevatedDark : DhanWiserColors.gray100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.more_horiz_rounded, color: sub, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Hero card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
                      blurRadius: 16, offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: DhanWiserColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(child: Text(_categoryEmoji, style: const TextStyle(fontSize: 28))),
                    ),
                    const SizedBox(height: 14),
                    Text(title, style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.w700, color: text, letterSpacing: -0.3)),
                    const SizedBox(height: 4),
                    Text(date, style: GoogleFonts.inter(fontSize: 14, color: sub)),
                    const SizedBox(height: 16),
                    Text(amount, style: GoogleFonts.inter(
                      fontSize: 40, fontWeight: FontWeight.w800, color: text, letterSpacing: -2)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: DhanWiserColors.teal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Paid by $paidBy',
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600, color: DhanWiserColors.teal),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Split section ──
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'SPLIT DETAILS',
                  style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600, color: sub, letterSpacing: 0.8),
                ),
              ),
              ...List.generate(splits.length, (index) {
                final split = splits[index];
                final color = splitColors[index % splitColors.length];
                final isPaid = split['status'] == 'Paid';

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
                        blurRadius: 8, offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Center(child: Text(
                          split['name']![0],
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700, color: color, fontSize: 18),
                        )),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(split['name']!, style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, color: text, fontSize: 15)),
                            Text(split['amount']!, style: GoogleFonts.inter(
                              fontSize: 13, color: sub)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? DhanWiserColors.mint.withValues(alpha: 0.1)
                              : DhanWiserColors.coral.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          split['status']!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isPaid ? DhanWiserColors.mint : DhanWiserColors.coral,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
