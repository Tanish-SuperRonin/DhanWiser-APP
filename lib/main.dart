import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:google_fonts/google_fonts.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:dhanwiser_fixed/theme/colors.dart";

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
import "package:dhanwiser_fixed/screens/settings_screen.dart";
import "package:dhanwiser_fixed/screens/expense_detail_screen.dart";

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
        theme: ThemeData(
          primaryColor: DhanWiserColors.primary,
          scaffoldBackgroundColor: DhanWiserColors.backgroundLight,
          colorScheme: ColorScheme.light(
            primary: DhanWiserColors.primary,
            secondary: DhanWiserColors.teal,
            surface: DhanWiserColors.surfaceLight,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: DhanWiserColors.backgroundLight,
            elevation: 0,
            iconTheme: IconThemeData(color: DhanWiserColors.textPrimaryLight),
            titleTextStyle: GoogleFonts.inter(
              color: DhanWiserColors.textPrimaryLight,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          textTheme: GoogleFonts.interTextTheme(),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: DhanWiserColors.primary,
          scaffoldBackgroundColor: DhanWiserColors.backgroundDark,
          colorScheme: ColorScheme.dark(
            primary: DhanWiserColors.primary,
            secondary: DhanWiserColors.teal,
            surface: DhanWiserColors.surfaceDark,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: DhanWiserColors.backgroundDark,
            elevation: 0,
            iconTheme: IconThemeData(color: DhanWiserColors.textPrimaryDark),
            titleTextStyle: GoogleFonts.inter(
              color: DhanWiserColors.textPrimaryDark,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
          useMaterial3: true,
        ),
        themeMode: themeProv.themeMode,
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
          if (settings.name == '/server-detail') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => ServerDetailScreen(
                serverId: args?['serverId'] ?? 0,
                serverName: args?['serverName'] ?? 'Server',
                members: args?['members'] ?? '0 members',
                imageUrl: args?['imageUrl'] ?? '',
              ),
            );
          }
          if (settings.name == '/add-expense') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => AddExpenseScreen(
                serverId: args?['serverId'],
              ),
            );
          }
          if (settings.name == '/expense-detail') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => ExpenseDetailScreen(
                title: args?['title'] ?? 'Expense',
                amount: args?['amount'] ?? '₹0',
                date: args?['date'] ?? '',
                paidBy: args?['paidBy'] ?? 'Unknown',
              ),
            );
          }
          return null;
        },
      ),
      ),
    );
  }
}

/// Startup widget that checks onboarding + auth state
class AppStartup extends StatefulWidget {
  const AppStartup({super.key});

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  @override
  void initState() {
    super.initState();
    _initialize();
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
    return Scaffold(
      backgroundColor: const Color(0xFF121121),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5048E5), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'DhanWiser',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              color: Color(0xFF5048E5),
            ),
          ],
        ),
      ),
    );
  }
}