import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _serverVisibility = true;
  bool _friendRequest = true;

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
          'Profile',
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
             onPressed: () {
               // Handle logout
               Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (route) => false);
             },
             child: Text(
               'Logout',
               style: GoogleFonts.inter(
                 color: DhanWiserColors.error,
                 fontWeight: FontWeight.w600,
               ),
             ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
               child: Column(
                 children: [
                   Stack(
                     children: [
                        CircleAvatar(
                         radius: 50,
                         backgroundColor: DhanWiserColors.gray200,
                         backgroundImage: NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80'),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: DhanWiserColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: surfaceColor, width: 3),
                            ),
                            child: Icon(Icons.check, color: Colors.white, size: 16),
                          ),
                        ),
                     ],
                   ),
                   const SizedBox(height: 16),
                   Text(
                     'Smit Patel',
                     style: GoogleFonts.inter(
                       fontSize: 24,
                       fontWeight: FontWeight.bold,
                       color: textColor,
                     ),
                   ),
                   Text(
                     '@smitpatel',
                     style: GoogleFonts.inter(
                       fontSize: 14,
                       color: subTextColor,
                     ),
                   ),
                 ],
               ),
            ),

            const SizedBox(height: 32),

            // UPI Section
            Text(
              'Payment Methods',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                   _buildUpiItem('smit@okhdfc', true, isDark),
                   const Divider(height: 24),
                   _buildUpiItem('smit.paytm@upi', false, isDark),
                   const SizedBox(height: 16),
                   SizedBox(
                     width: double.infinity,
                     child: OutlinedButton.icon(
                       onPressed: () {},
                       icon: Icon(Icons.add, size: 18),
                       label: Text('Add New UPI ID'),
                       style: OutlinedButton.styleFrom(
                         foregroundColor: DhanWiserColors.primary,
                         side: BorderSide(color: DhanWiserColors.primary),
                         padding: const EdgeInsets.symmetric(vertical: 12),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                       ),
                     ),
                   ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            
            // Privacy Settings
             Text(
              'Privacy & Security',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Show in Search',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    subtitle: Text(
                      'Allow friends to find you by phone number',
                       style: GoogleFonts.inter(
                        fontSize: 12,
                        color: subTextColor,
                      ),
                    ),
                    value: _friendRequest,
                    onChanged: (val) => setState(() => _friendRequest = val),
                  ),
                  Divider(height: 1, indent: 16, endIndent: 16),
                   SwitchListTile(
                    title: Text(
                      'Public Server Visibility',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                         color: textColor,
                      ),
                    ),
                     subtitle: Text(
                      'Show servers you manage on your profile',
                       style: GoogleFonts.inter(
                        fontSize: 12,
                        color: subTextColor,
                      ),
                    ),
                    value: _serverVisibility,
                    onChanged: (val) => setState(() => _serverVisibility = val),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Account Actions
            _buildActionItem(Icons.notifications_outlined, 'Notifications', isDark),
            _buildActionItem(Icons.security, 'Security', isDark),
            _buildActionItem(Icons.help_outline, 'Help & Support', isDark),
             
             // Divider and Version
             const Padding(
               padding: EdgeInsets.symmetric(vertical: 24),
               child: Divider(),
             ),
             Center(
               child: Text(
                 'Version 1.0.0',
                 style: GoogleFonts.inter(
                   color: subTextColor,
                   fontSize: 12,
                 ),
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiItem(String upiId, bool isPrimary, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? DhanWiserColors.gray800 : DhanWiserColors.gray100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.qr_code, size: 20, color: DhanWiserColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                upiId,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isPrimary ? (isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight) : (isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight),
                ),
              ),
              if(isPrimary)
                Text(
                  'Primary',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: DhanWiserColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        Icon(Icons.more_vert, color: isDark ? DhanWiserColors.gray500 : DhanWiserColors.gray400),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String title, bool isDark) {
    return ListTile(
      leading: Icon(icon, color: isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          color: isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? DhanWiserColors.gray600 : DhanWiserColors.gray400),
      contentPadding: EdgeInsets.zero,
      onTap: () {},
    );
  }
}
