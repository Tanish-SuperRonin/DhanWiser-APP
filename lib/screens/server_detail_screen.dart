import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class ServerDetailScreen extends StatefulWidget {
  const ServerDetailScreen({Key? key}) : super(key: key);

  @override
  State<ServerDetailScreen> createState() => _ServerDetailScreenState();
}

class _ServerDetailScreenState extends State<ServerDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: surfaceColor,
              elevation: 0,
              pinned: true,
              expandedHeight: 180, // Reduced height
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: textColor),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.settings_outlined, color: textColor),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.share_outlined, color: textColor),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image with Gradient Overlay
                    Image.network(
                      'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: DhanWiserColors.primary),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 60, // Adjusted from 70 to give space for TabBar
                      left: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Goa Trip 2024',
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.people, color: Colors.white.withOpacity(0.8), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '5 members',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: surfaceColor,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: DhanWiserColors.primary,
                    unselectedLabelColor: subTextColor,
                    indicatorColor: DhanWiserColors.primary,
                    indicatorWeight: 3,
                    labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Expenses'),
                      Tab(text: 'Balances'),
                      Tab(text: 'Members'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // EXPENSES TAB
            _buildExpensesTab(context, surfaceColor, textColor, subTextColor, borderColor),

            // BALANCES TAB (Placeholder)
            Center(child: Text('Balances View', style: GoogleFonts.inter(color: subTextColor))),

             // MEMBERS TAB (Placeholder)
            Center(child: Text('Members View', style: GoogleFonts.inter(color: subTextColor))),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-expense'),
        backgroundColor: DhanWiserColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Expense',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildExpensesTab(BuildContext context, Color surfaceColor, Color textColor, Color subTextColor, Color borderColor) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Overview
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Spending',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: subTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹45,200',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: borderColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Share',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: subTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹9,040',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: DhanWiserColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // Date Header: Today
            Text(
              'Today',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: subTextColor,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildExpenseItem(
              context,
              'Dinner at Titlie',
              'Paid by Rahul',
              '₹4,500',
              Icons.restaurant,
              DhanWiserColors.primary,
              true,
            ),
            _buildExpenseItem(
              context,
              'Cab to Baga',
              'Paid by You',
              '₹850',
              Icons.local_taxi,
              Color(0xFFF59E0B),
              false,
            ),

            const SizedBox(height: 24),
             // Date Header: Yesterday
            Text(
              'Yesterday',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: subTextColor,
              ),
            ),
            const SizedBox(height: 16),

             _buildExpenseItem(
              context,
              'Villa Booking Advance',
              'Paid by Smit',
              '₹15,000',
              Icons.home,
              Color(0xFF10B981),
              true,
            ),
             _buildExpenseItem(
              context,
              'Drinks & Snacks',
              'Paid by Priya',
              '₹2,400',
              Icons.local_bar,
              Color(0xFFEC4899),
              false,
            ),
            
            // Padding for FAB
            const SizedBox(height: 80),
          ],
        ),
      );
  }

  Widget _buildExpenseItem(
    BuildContext context,
    String title,
    String subtitle,
    String amount,
    IconData icon,
    Color iconColor,
    bool isLent, // To show if user lent or borrowed, simplifying here
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? DhanWiserColors.surfaceDark : DhanWiserColors.surfaceLight;
    final textColor = isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight;
    final subTextColor = isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight;
    final borderColor = isDark ? DhanWiserColors.gray700 : DhanWiserColors.gray200;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                    color: textColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: subTextColor,
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
                  color: textColor,
                ),
              ),
              Text(
                isLent ? 'you lent' : 'you borrowed',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isLent ? DhanWiserColors.success : DhanWiserColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
