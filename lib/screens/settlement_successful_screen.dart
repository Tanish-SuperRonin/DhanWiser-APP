import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class SettlementSuccessfulScreen extends StatelessWidget {
  final double amount;
  final String receiverName;

  const SettlementSuccessfulScreen({
    super.key,
    required this.amount,
    required this.receiverName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DhanWiserColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glowing Icon
                      SizedBox(
                        width: 128,
                        height: 128,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: DhanWiserColors.primary.withValues(alpha: 0.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: DhanWiserColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: DhanWiserColors.primaryContainer,
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                color: DhanWiserColors.onPrimaryContainer,
                                size: 48,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Payment Successful!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: DhanWiserColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your settlement request has been sent to $receiverName.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: DhanWiserColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Amount Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: DhanWiserColors.card.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: DhanWiserColors.surfaceVariant),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Amount Settled',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: DhanWiserColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${amount.toStringAsFixed(0)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: DhanWiserColors.primary,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Split line
                            Container(
                              height: 1,
                              color: DhanWiserColors.surfaceVariant,
                            ),
                            const SizedBox(height: 24),
                            // Split between
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: DhanWiserColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Y',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: DhanWiserColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'You',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: DhanWiserColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                // Arrows
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: DhanWiserColors.primary,
                                      ),
                                    ),
                                    Container(
                                      width: 40,
                                      height: 2,
                                      color: DhanWiserColors.primary,
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: DhanWiserColors.primary,
                                      size: 14,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: DhanWiserColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Center(
                                        child: Text(
                                          receiverName.isNotEmpty ? receiverName[0].toUpperCase() : '?',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: DhanWiserColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      receiverName,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: DhanWiserColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DhanWiserColors.primary,
                      foregroundColor: DhanWiserColors.background,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Back to Home',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (route) => false);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: DhanWiserColors.textPrimary,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Back to Home',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
