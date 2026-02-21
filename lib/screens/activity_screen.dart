import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? DhanWiserColors.backgroundDark : DhanWiserColors.backgroundLight;
    final textColor = isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight;
    final subTextColor = isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Activity & Reminders',
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check_circle_outline, color: DhanWiserColors.primary),
            onPressed: () {
              // Mark all as read
            },
            tooltip: 'Mark all as read',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reminders Section
             Text(
              'Reminders',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: subTextColor,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            _buildReminderCard(
              context,
              'Rent Payment Due',
              'Flat 302 • Today',
              '₹12,450',
              true,
            ),
             _buildReminderCard(
              context,
              'Settle up with Rahul',
              'Goa Trip 2024 • Tomorrow',
              '₹450',
              false,
            ),

            const SizedBox(height: 32),

            // Recent Activity Section
             Text(
              'Recent Activity',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: subTextColor,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
             _buildActivityItem(
               context,
               'You paid ₹850 for Cab',
               'Goa Trip 2024 • Just now',
               Icons.local_taxi,
               Color(0xFFF59E0B),
             ),
             _buildActivityItem(
               context,
               'Priya added "Dinner at Titlie"',
               'Goa Trip 2024 • 2h ago',
               Icons.restaurant,
               DhanWiserColors.primary,
             ),
             _buildActivityItem(
               context,
               'Rahul settled ₹1,200',
               'Flat 302 • Yesterday',
               Icons.check_circle,
               DhanWiserColors.success,
             ),
             _buildActivityItem(
               context,
               'Added to "Office Lunch"',
               'By Amit • 2 days ago',
               Icons.group_add,
               Color(0xFF8B5CF6),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, String title, String subtitle, String amount, bool isUrgent) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final surfaceColor = isDark ? DhanWiserColors.surfaceDark : DhanWiserColors.surfaceLight;
      final borderColor = isDark ? DhanWiserColors.gray700 : DhanWiserColors.gray200;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isUrgent ? DhanWiserColors.error.withOpacity(0.5) : borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUrgent ? DhanWiserColors.error.withOpacity(0.1) : DhanWiserColors.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active,
                color: isUrgent ? DhanWiserColors.error : DhanWiserColors.warning,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
             Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                 Text(
                   amount,
                   style: GoogleFonts.inter(
                     fontSize: 16,
                     fontWeight: FontWeight.bold,
                     color: isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight,
                   ),
                 ),
                 TextButton(
                   onPressed: () {},
                   style: TextButton.styleFrom(
                     padding: EdgeInsets.zero,
                     minimumSize: Size(50, 24),
                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                     alignment: Alignment.centerRight,
                   ),
                   child: Text(
                     'Pay Now',
                     style: GoogleFonts.inter(
                       fontSize: 12,
                       fontWeight: FontWeight.w600,
                       color: DhanWiserColors.primary,
                     ),
                   ),
                 ),
              ],
            ),
          ],
        ),
      );
  }

  Widget _buildActivityItem(
    BuildContext context, 
    String title, 
    String subtitle, 
    IconData icon, 
    Color iconColor,
  ) {
     final isDark = Theme.of(context).brightness == Brightness.dark;
     
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
