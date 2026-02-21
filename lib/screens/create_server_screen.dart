import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class CreateServerScreen extends StatefulWidget {
  const CreateServerScreen({Key? key}) : super(key: key);

  @override
  State<CreateServerScreen> createState() => _CreateServerScreenState();
}

class _CreateServerScreenState extends State<CreateServerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _serverNameController = TextEditingController();
  bool _isPrivate = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _serverNameController.dispose();
    super.dispose();
  }

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
          'Add Server',
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: DhanWiserColors.primary,
          unselectedLabelColor: subTextColor,
          indicatorColor: DhanWiserColors.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Create New'),
            Tab(text: 'Discover'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // CREATE SERVER TAB
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: isDark ? DhanWiserColors.gray800 : DhanWiserColors.gray100,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? DhanWiserColors.gray700 : DhanWiserColors.gray300,
                            width: 2,
                            style: BorderStyle.solid, // Dashed border not supported natively
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 32,
                          color: subTextColor,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: DhanWiserColors.primary,
                          radius: 16,
                          child: Icon(Icons.add, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                Text(
                  'Server Name',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _serverNameController,
                  style: GoogleFonts.inter(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'e.g., Goa Trip 2024, Flat 302',
                    hintStyle: GoogleFonts.inter(color: subTextColor),
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
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 24),

                // Privacy Toggle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: DhanWiserColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.lock_outline, color: DhanWiserColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Private Server',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            Text(
                              'Only invited members can join',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isPrivate,
                        onChanged: (value) => setState(() => _isPrivate = value),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle server creation
                      Navigator.pushReplacementNamed(context, '/server-detail'); // Just mocking navigation
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DhanWiserColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: DhanWiserColors.primary.withOpacity(0.4),
                    ),
                    child: Text(
                      'Create Server',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // DISCOVER TAB
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextField(
                style: GoogleFonts.inter(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Search communities...',
                  hintStyle: GoogleFonts.inter(color: subTextColor),
                  prefixIcon: Icon(Icons.search, color: subTextColor),
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Popular Communities',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildCommunityCard(
                context,
                'Bangalore Trekking Club',
                '2.4k members • Public',
                'https://images.unsplash.com/photo-1551632811-561732d1e306?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
              ),
              _buildCommunityCard(
                context,
                'Tech Meetups',
                '856 members • Public',
                'https://images.unsplash.com/photo-1543269865-cbf427effbad?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
              ),
              _buildCommunityCard(
                context,
                'Foodies United',
                '1.2k members • Public',
                'https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityCard(BuildContext context, String name, String subtitle, String imageUrl) {
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
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
              backgroundColor: isDark ? DhanWiserColors.gray800 : DhanWiserColors.gray100,
              foregroundColor: DhanWiserColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'Join',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
