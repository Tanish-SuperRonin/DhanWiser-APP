import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class FriendDiscoveryScreen extends StatelessWidget {
  const FriendDiscoveryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? DhanWiserColors.backgroundDark : DhanWiserColors.backgroundLight;
    final surfaceColor = isDark ? DhanWiserColors.surfaceDark : DhanWiserColors.surfaceLight;
    final textColor = isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight;
    final subTextColor = isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight;
    final borderColor = isDark ? DhanWiserColors.gray700 : DhanWiserColors.gray200;

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
          'Find Friends',
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              style: GoogleFonts.inter(color: textColor),
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                hintStyle: GoogleFonts.inter(color: subTextColor),
                prefixIcon: Icon(Icons.search, color: subTextColor),
                filled: true,
                fillColor: surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: DhanWiserColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Friend Requests
            Text(
              'Friend Requests (3)',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildRequestCard(
              context,
              'Amit Kumar',
              'Via Contacts',
              'https://images.unsplash.com/photo-1599566150163-29194dcaad36?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
            ),
            _buildRequestCard(
              context,
              'Neha Sharma',
              'Mutual: Priya',
              'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
            ),

            const SizedBox(height: 32),

            // Suggested
            Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(
                  'Suggested for You',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                TextButton(
                  onPressed: (){},
                  child: Text(
                     'Sync Contacts',
                     style: GoogleFonts.inter(
                       color: DhanWiserColors.primary,
                       fontWeight: FontWeight.w600,
                     ),
                  ),
                ),
               ],
            ),
            const SizedBox(height: 16),
             _buildSuggestionCard(
              context,
              'Rohan Das',
              '25 mutual friends',
              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
            ),
             _buildSuggestionCard(
              context,
              'Anjali Singh',
              'From your office',
              'https://images.unsplash.com/photo-1517841905240-472988babdf9?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, String name, String subtitle, String imageUrl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? DhanWiserColors.surfaceDark : DhanWiserColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? DhanWiserColors.gray700 : DhanWiserColors.gray200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.check_circle, color: DhanWiserColors.success),
                onPressed: () {},
                splashRadius: 24,
              ),
              IconButton(
                icon: Icon(Icons.cancel, color: DhanWiserColors.error),
                onPressed: () {},
                splashRadius: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }

    Widget _buildSuggestionCard(BuildContext context, String name, String subtitle, String imageUrl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? DhanWiserColors.surfaceDark : DhanWiserColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? DhanWiserColors.gray700 : DhanWiserColors.gray200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: DhanWiserColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              'Add',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
