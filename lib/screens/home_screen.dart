import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Placeholder for navigation logic
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigation logic will be added here or via a dedicated layout wrapper
    if (index == 2) {
       // Navigate to Create/Join Server
       Navigator.pushNamed(context, '/create-server');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? DhanWiserColors.backgroundDark : DhanWiserColors.backgroundLight;
    final surfaceColor = isDark ? DhanWiserColors.surfaceDark : DhanWiserColors.surfaceLight;
    final textColor = isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight;
    final subTextColor = isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header / Greeting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good evening,',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: subTextColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'Smit Patel',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                      borderRadius: BorderRadius.circular(24),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: DhanWiserColors.gray200,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),

                // Net Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        DhanWiserColors.primary,
                        Color(0xFF6E66F0), // Lighter shade for gradient
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: DhanWiserColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Net Balance',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '+2.4%',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.trending_up, color: Colors.white, size: 14),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹12,450',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _buildBalanceStat('To Receive', '₹14,200', Colors.white),
                          Container(height: 32, width: 1, color: Colors.white.withOpacity(0.2)),
                          _buildBalanceStat('To Pay', '₹1,750', Colors.white.withOpacity(0.9)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Active Servers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Servers',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/activity'),
                      child: Text(
                        'View All',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: DhanWiserColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildServerCard(
                        context,
                        'Goa Trip 2024',
                        '5 members',
                        'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                        true,
                      ),
                      _buildServerCard(
                        context,
                        'Flat 302',
                        '3 members',
                        'https://images.unsplash.com/photo-1580587771525-78b9dba3b91d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                        false,
                      ),
                      _buildServerCard(
                        context,
                        'Office Lunch',
                        '8 members',
                        'https://images.unsplash.com/photo-1543362906-acfc94d6eb74?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                        false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Recent Activity
                Text(
                  'Recent Activity',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                _buildActivityItem(
                  context,
                  'Dinner at Social',
                  'You paid ₹4,500',
                  'Just now',
                  Icons.restaurant,
                  DhanWiserColors.primary,
                ),
                _buildActivityItem(
                  context,
                  'Grocery Shopping',
                  'Rahul added ₹1,200',
                  '2h ago',
                  Icons.shopping_cart,
                  Color(0xFFF59E0B),
                ),
                 _buildActivityItem(
                  context,
                  'Electricity Bill',
                  'You owe ₹850',
                  'Yesterday',
                   Icons.bolt,
                  Color(0xFFEF4444),
                ),
                // Add padding at bottom for FAB
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-expense'),
        backgroundColor: DhanWiserColors.primary,
        child: Icon(Icons.add, color: Colors.white),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: surfaceColor,
        elevation: 8,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavBarItem(0, Icons.home_rounded, Icons.home_outlined),
              _buildNavBarItem(1, Icons.explore_rounded, Icons.explore_outlined),
              const SizedBox(width: 40), // Gap for FAB
              _buildNavBarItem(3, Icons.notifications_rounded, Icons.notifications_outlined),
              _buildNavBarItem(4, Icons.person_rounded, Icons.person_outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceStat(String label, String amount, Color textColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: textColor.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerCard(BuildContext context, String name, String members, String imageUrl, bool hasAlert) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/server-detail'),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isDark ? DhanWiserColors.surfaceDark : DhanWiserColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? DhanWiserColors.gray700 : DhanWiserColors.gray200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
             Stack(
               children: [
                 ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 100,
                      width: double.infinity,
                      color: DhanWiserColors.gray200,
                      child: Icon(Icons.image, color: DhanWiserColors.gray400),
                    ),
                  ),
                ),
                if (hasAlert)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: DhanWiserColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
               ],
             ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    members,
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
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, 
    String title, 
    String subtitle, 
    String time, 
    IconData icon, 
    Color iconColor,
  ) {
     final isDark = Theme.of(context).brightness == Brightness.dark;
     
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/activity'),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(int index, IconData selectedIcon, IconData unselectedIcon) {
    bool isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(
        isSelected ? selectedIcon : unselectedIcon,
        color: isSelected ? DhanWiserColors.primary : DhanWiserColors.gray400,
        size: 28,
      ),
      onPressed: () {
          if (index == 1) {
            Navigator.pushNamed(context, '/friend-discovery');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/activity');
          } else if (index == 4) {
             Navigator.pushNamed(context, '/profile');
          }
          else {
            _onItemTapped(index);
          }
      },
    );
  }
}