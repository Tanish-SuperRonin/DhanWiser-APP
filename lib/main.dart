import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:google_fonts/google_fonts.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:dhanwiser_fixed/theme/app_theme.dart";

// Providers
import "package:dhanwiser_fixed/providers/auth_provider.dart";
import "package:dhanwiser_fixed/providers/server_provider.dart";
import "package:dhanwiser_fixed/providers/notification_provider.dart";
import "package:dhanwiser_fixed/providers/theme_provider.dart";

// Screens
import "package:dhanwiser_fixed/screens/onboarding_screen.dart";
import "package:dhanwiser_fixed/screens/login_screen.dart";
import "package:dhanwiser_fixed/screens/signup_screen.dart";
import "package:dhanwiser_fixed/screens/home_screen.dart";
import "package:dhanwiser_fixed/screens/create_server_screen.dart";
import "package:dhanwiser_fixed/screens/server_detail_screen.dart";
import "package:dhanwiser_fixed/screens/add_expense_screen.dart";
import "package:dhanwiser_fixed/screens/profile_screen.dart";
import "package:dhanwiser_fixed/screens/friend_discovery_screen.dart";
import "package:dhanwiser_fixed/screens/activity_screen.dart";
import "package:dhanwiser_fixed/screens/settlement_screen.dart";
import "package:dhanwiser_fixed/screens/settlement_request_screen.dart";
import "package:dhanwiser_fixed/screens/settings_screen.dart";
import "package:dhanwiser_fixed/screens/expense_detail_screen.dart";
import "package:dhanwiser_fixed/screens/settlement_successful_screen.dart";
import "package:dhanwiser_fixed/screens/group_settings_screen.dart";

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServerProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProv, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DhanWiser',

          // ── Material Design 3 Themes ──
          theme: DhanWiserTheme.lightTheme,
          darkTheme: DhanWiserTheme.darkTheme,
          themeMode: themeProv.themeMode,

          builder: (context, child) {
            return ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
              ),
              child: child!,
            );
          },

          home: const AppStartup(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/home': (context) => const HomeScreen(),
            '/create-server': (context) => const CreateServerScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/friend-discovery': (context) => const FriendDiscoveryScreen(),
            '/activity': (context) => const ActivityScreen(),
            '/settlement': (context) => const SettlementScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
          onGenerateRoute: (settings) {
            // M3 shared axis transition
            Widget? page;

            if (settings.name == '/server-detail') {
              final args = settings.arguments as Map<String, dynamic>?;
              page = ServerDetailScreen(
                serverId: args?['serverId'] ?? 0,
                serverName: args?['serverName'] ?? 'Server',
                members: args?['members'] ?? '0 members',
                imageUrl: args?['imageUrl'] ?? '',
              );
            }
            if (settings.name == '/add-expense') {
              final args = settings.arguments as Map<String, dynamic>?;
              page = AddExpenseScreen(
                serverId: args?['serverId'],
              );
            }
            if (settings.name == '/expense-detail') {
              final args = settings.arguments as Map<String, dynamic>?;
              page = ExpenseDetailScreen(
                title: args?['title'] ?? 'Expense',
                amount: args?['amount'] ?? '₹0',
                date: args?['date'] ?? '',
                paidBy: args?['paidBy'] ?? 'Unknown',
                participants: args?['participants'] != null
                    ? List<Map<String, dynamic>>.from(args!['participants'])
                    : null,
              );
            }
            if (settings.name == '/settlement-request') {
              final args = settings.arguments as Map<String, dynamic>?;
              page = SettlementRequestScreen(
                settlementId: args?['settlementId'] ?? 0,
              );
            }
            if (settings.name == '/settlement-successful') {
              final args = settings.arguments as Map<String, dynamic>?;
              page = SettlementSuccessfulScreen(
                amount: args?['amount'] ?? 0.0,
                receiverName: args?['receiverName'] ?? 'Unknown',
              );
            }
            if (settings.name == '/group-settings') {
              final args = settings.arguments as Map<String, dynamic>?;
              page = GroupSettingsScreen(
                serverId: args?['serverId'] ?? 0,
                serverName: args?['serverName'] ?? '',
                isAdmin: args?['isAdmin'] ?? false,
                isCreator: args?['isCreator'] ?? false,
              );
            }

            if (page != null) {
              return _buildM3PageRoute(page, settings);
            }
            return null;
          },
        ),
      ),
    );
  }

  /// Material 3 inspired page route with predictive back & fade-through transition
  PageRoute _buildM3PageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // M3 fade-through transition
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.04),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }
}

/// Startup widget that checks onboarding + auth state
class AppStartup extends StatefulWidget {
  const AppStartup({super.key});

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initialize();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    // Capture context-dependent references before any await
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    // Check onboarding first
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    if (!hasSeenOnboarding) {
      if (mounted) {
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (_) => const OnboardingScreen(),
          ),
        );
      }
      return;
    }

    // Check auth state
    await authProvider.initialize();

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      navigator.pushReplacementNamed('/home');
    } else {
      navigator.pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // M3 branded icon with surface tint
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: cs.onPrimaryContainer,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'DhanWiser',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: cs.primary,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
