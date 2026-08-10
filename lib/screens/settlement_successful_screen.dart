import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'package:dhanwiser_fixed/theme/text_styles.dart';
import 'package:dhanwiser_fixed/widgets/bouncing_button.dart';

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
      backgroundColor: DhanWiserColors.of(context).background,
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
                                color: DhanWiserColors.of(context).primary
                                    .withValues(alpha: 0.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: DhanWiserColors.of(context).primary
                                        .withValues(alpha: 0.3),
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
                                color: DhanWiserColors.of(context).primaryContainer,
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                color: DhanWiserColors.of(context).onPrimaryContainer,
                                size: 48,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Payment Successful!',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(color: DhanWiserColors.of(context).textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your settlement request has been sent to $receiverName.',
                        textAlign: TextAlign.center,
                        style: DhanWiserTextStyles.bodyRegular(context)
                            .copyWith(color: DhanWiserColors.of(context).textSecondary),
                      ),
                      const SizedBox(height: 32),
                      // Amount Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: DhanWiserColors.of(context).card.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(24),
                          border:
                              Border.all(color: DhanWiserColors.of(context).surfaceVariant),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Amount Settled',
                              style: DhanWiserTextStyles.caption(context)
                                  .copyWith(
                                      color: DhanWiserColors.of(context).textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${amount.toStringAsFixed(0)}',
                              style: DhanWiserTextStyles.displayLarge(context)
                                  .copyWith(
                                      color: DhanWiserColors.of(context).primary,
                                      letterSpacing: -1),
                            ),
                            const SizedBox(height: 24),
                            // Split line
                            Container(
                              height: 1,
                              color: DhanWiserColors.of(context).surfaceVariant,
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
                                        color: DhanWiserColors.of(context).surfaceVariant,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Y',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: DhanWiserColors.of(context).textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'You',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                              color:
                                                  DhanWiserColors.of(context).textPrimary),
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
                                        color: DhanWiserColors.of(context).primary,
                                      ),
                                    ),
                                    Container(
                                      width: 40,
                                      height: 2,
                                      color: DhanWiserColors.of(context).primary,
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: DhanWiserColors.of(context).primary,
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
                                        color: DhanWiserColors.of(context).surfaceVariant,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Center(
                                        child: Text(
                                          receiverName.isNotEmpty
                                              ? receiverName[0].toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: DhanWiserColors.of(context).textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      receiverName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                              color:
                                                  DhanWiserColors.of(context).textPrimary),
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
                  PremiumElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DhanWiserColors.of(context).primary,
                      foregroundColor: DhanWiserColors.of(context).background,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Back to Home',
                      style: Theme.of(context).textTheme.titleMedium!,
                    ),
                  ),
                  const SizedBox(height: 12),
                  PremiumTextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (route) => false);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: DhanWiserColors.of(context).textPrimary,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Back to Home',
                      style: Theme.of(context).textTheme.titleMedium!,
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
