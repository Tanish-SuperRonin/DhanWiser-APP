import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final String title;
  final String amount;
  final String date;
  final String paidBy;
  final IconData categoryIcon;
  final List<Map<String, dynamic>>? participants;

  const ExpenseDetailScreen({
    super.key,
    this.title = 'Expense',
    this.amount = '₹0',
    this.date = '',
    this.paidBy = 'Unknown',
    this.categoryIcon = Icons.inventory_2_rounded,
    this.participants,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use real participants if available, otherwise show a simple paidBy row
    final splits = participants ?? [
      {'name': paidBy, 'amount': amount, 'status': 'Paid'},
    ];

    final splitColors = [
      DhanWiserColors.primary,
      DhanWiserColors.coral,
      DhanWiserColors.teal,
      DhanWiserColors.warning,
      DhanWiserColors.tertiary,
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Hero card ──
            Card(
              elevation: 1,
              color: isDark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest,
              surfaceTintColor: cs.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(categoryIcon, color: cs.primary, size: 28),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (date.isNotEmpty)
                      Text(
                        date,
                        style: GoogleFonts.inter(
                            fontSize: 14, color: cs.onSurfaceVariant),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      amount,
                      style: GoogleFonts.inter(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // M3 tonal chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: DhanWiserColors.teal.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Paid by $paidBy',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: DhanWiserColors.teal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── How This Split Works — Explainer ──
            Card(
              elevation: 0,
              color: isDark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calculate_rounded, size: 18, color: cs.primary),
                        const SizedBox(width: 8),
                        Text(
                          'How this split works',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Step 1: Payer
                    _buildStepRow(
                      '1',
                      DhanWiserColors.teal,
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(fontSize: 13, color: cs.onSurface, height: 1.4),
                          children: [
                            TextSpan(
                              text: paidBy,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const TextSpan(text: ' paid '),
                            TextSpan(
                              text: amount,
                              style: TextStyle(fontWeight: FontWeight.w700, color: DhanWiserColors.teal),
                            ),
                            const TextSpan(text: ' upfront (the Payer)'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Step 2: Split
                    _buildStepRow(
                      '2',
                      cs.primary,
                      Text(
                        'The total is split among ${splits.length} ${splits.length == 1 ? 'person' : 'people'} — each person\'s share is shown below.',
                        style: GoogleFonts.inter(fontSize: 13, color: cs.onSurface, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Step 3: Debtors
                    _buildStepRow(
                      '3',
                      DhanWiserColors.coral,
                      Text(
                        'Everyone except the payer owes their share to the payer (they are Debtors).',
                        style: GoogleFonts.inter(fontSize: 13, color: cs.onSurface, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Split section ──
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'SPLIT DETAILS',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            ...List.generate(splits.length, (index) {
              final split = splits[index];
              final color = splitColors[index % splitColors.length];
              final name = split['name']?.toString() ??
                  split['fullName']?.toString() ??
                  'Member';
              final splitAmount = split['amount']?.toString() ?? '₹0';
              final amountOwed = split['amountOwed'];
              final amountPaid = split['amountPaid'];

              // Determine display amount and status
              String displayAmount;
              bool isPaid;
              if (amountOwed != null) {
                final owed = amountOwed is num
                    ? amountOwed.toDouble()
                    : double.tryParse(amountOwed.toString()) ?? 0;
                final paid = amountPaid is num
                    ? amountPaid.toDouble()
                    : double.tryParse(amountPaid?.toString() ?? '0') ?? 0;
                displayAmount = '₹${owed.toStringAsFixed(2)}';
                isPaid = paid > 0;
              } else {
                displayAmount =
                    splitAmount.startsWith('₹') ? splitAmount : '₹$splitAmount';
                isPaid = split['status'] == 'Paid';
              }

              final initial =
                  name.isNotEmpty ? name[0].toUpperCase() : '?';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                color: isDark
                    ? cs.surfaceContainerHigh
                    : cs.surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: color,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              displayAmount,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? DhanWiserColors.mint.withValues(alpha: 0.10)
                              : DhanWiserColors.coral.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isPaid ? 'Payer' : 'Owes',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isPaid
                                ? DhanWiserColors.mint
                                : DhanWiserColors.coral,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(String step, Color color, Widget content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(
            child: Text(
              step,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: content),
      ],
    );
  }
}
