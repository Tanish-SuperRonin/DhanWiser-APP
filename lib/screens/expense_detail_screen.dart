import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'package:dhanwiser_fixed/theme/text_styles.dart';
import 'package:dhanwiser_fixed/widgets/bouncing_button.dart';

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
    this.categoryIcon = Icons.restaurant_rounded,
    this.participants,
  });

  @override
  Widget build(BuildContext context) {
    final parsedAmount = double.tryParse(
            amount.replaceAll('₹', '').replaceAll(',', '').trim()) ??
        0.0;
    final splitShare =
        parsedAmount > 0 ? (parsedAmount / 2).toStringAsFixed(2) : '0.00';

    final splits = participants ??
        [
          {'name': 'You', 'amount': '₹$splitShare', 'status': 'Owe'},
          {'name': paidBy, 'amount': amount, 'status': 'Paid'},
        ];

    final isPaidByMe = paidBy.toLowerCase() == 'you';

    return Scaffold(
      backgroundColor: DhanWiserColors.of(context).background,
      appBar: AppBar(
        backgroundColor: DhanWiserColors.of(context).background,
        elevation: 0,
        leading: PremiumIconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: DhanWiserColors.of(context).textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Split Receipt',
          style: DhanWiserTextStyles.buttonLarge(context)
              .copyWith(color: DhanWiserColors.of(context).primary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Receipt Card
            Container(
              decoration: BoxDecoration(
                color: DhanWiserColors.of(context).card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: DhanWiserColors.of(context).surfaceVariant),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: DhanWiserColors.of(context).primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(categoryIcon,
                              color: DhanWiserColors.of(context).onPrimaryContainer,
                              size: 28),
                        ),
                        SizedBox(height: 16),
                        Text(
                          title,
                          style: DhanWiserTextStyles.headline2(context)
                              .copyWith(color: DhanWiserColors.of(context).textPrimary),
                        ),
                        if (date.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Text(
                            date,
                            style: DhanWiserTextStyles.caption(context)
                                .copyWith(color: DhanWiserColors.of(context).textSecondary),
                          ),
                        ],
                        SizedBox(height: 32),

                        // Bill Details
                        Text(
                          'BILL DETAILS',
                          style: DhanWiserTextStyles.overline(context).copyWith(
                              color: DhanWiserColors.of(context).textSecondary,
                              letterSpacing: 1),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(color: DhanWiserColors.of(context).textPrimary),
                            ),
                            Text(
                              amount,
                              style: DhanWiserTextStyles.headline2(context)
                                  .copyWith(color: DhanWiserColors.of(context).primary),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Paid by',
                              style: DhanWiserTextStyles.caption(context)
                                  .copyWith(
                                      color: DhanWiserColors.of(context).textSecondary),
                            ),
                            Text(
                              paidBy,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: DhanWiserColors.of(context).textPrimary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Dashed separator
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 24,
                        decoration: BoxDecoration(
                          color: DhanWiserColors.of(context).background,
                          borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(12)),
                        ),
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final dashCount =
                                (constraints.constrainWidth() / 8).floor();
                            return Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(dashCount, (_) {
                                return SizedBox(
                                  width: 4,
                                  height: 1,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                        color: DhanWiserColors.of(context).surfaceVariant),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                      Container(
                        width: 12,
                        height: 24,
                        decoration: BoxDecoration(
                          color: DhanWiserColors.of(context).background,
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(12)),
                        ),
                      ),
                    ],
                  ),

                  // Split Info
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR SHARE',
                          style: DhanWiserTextStyles.overline(context).copyWith(
                              color: DhanWiserColors.of(context).textSecondary,
                              letterSpacing: 1),
                        ),
                        SizedBox(height: 16),
                        ...splits
                            .where((s) => s['status'] != 'Paid')
                            .map((split) {
                          final name = split['name']?.toString() ?? 'Member';
                          final splitAmount =
                              split['amount']?.toString() ?? '₹0';
                          final amountOwed = split['amountOwed'];

                          String displayAmount;
                          if (amountOwed != null) {
                            final owed = amountOwed is num
                                ? amountOwed.toDouble()
                                : double.tryParse(amountOwed.toString()) ?? 0;
                            displayAmount = '₹${owed.toStringAsFixed(2)}';
                          } else {
                            displayAmount = splitAmount.startsWith('₹')
                                ? splitAmount
                                : '₹$splitAmount';
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: DhanWiserColors.of(context).surfaceVariant,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.person_rounded,
                                          color: DhanWiserColors.of(context).textPrimary,
                                          size: 20),
                                    ),
                                    SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name == 'You'
                                              ? 'You owe $paidBy'
                                              : '$name owes you',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                  color: DhanWiserColors.of(context).textPrimary),
                                        ),
                                        Text(
                                          '1 of ${splits.length} people split',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  color: DhanWiserColors.of(context).textSecondary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  displayAmount,
                                  style:
                                      DhanWiserTextStyles.buttonLarge(context)
                                          .copyWith(
                                              color: DhanWiserColors.of(context).error),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Actions
            PremiumElevatedButton(
              onPressed: () {
                if (!isPaidByMe) {
                  // Actually, Settle Now would go to Settlement Request flow, or just "Settlement Successful" for demo
                  Navigator.pushNamed(context, '/settlement-request');
                }
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
                isPaidByMe ? 'Remind All' : 'Settle Now',
                style: DhanWiserTextStyles.buttonLarge(context),
              ),
            ),
            SizedBox(height: 12),
            PremiumOutlinedButtonIcon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded, size: 20),
              label: Text(
                'Download PDF',
                style: DhanWiserTextStyles.buttonLarge(context),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: DhanWiserColors.of(context).textPrimary,
                side: BorderSide(color: DhanWiserColors.of(context).surfaceVariant),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
