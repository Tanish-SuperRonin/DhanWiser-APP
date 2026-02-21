import "package:flutter/material.dart";
import "package:dhanwiser_fixed/screens/onboarding_screen.dart";
import "package:dhanwiser_fixed/screens/home_screen.dart";
import "package:dhanwiser_fixed/screens/create_server_screen.dart";
import "package:dhanwiser_fixed/screens/server_detail_screen.dart";
import "package:dhanwiser_fixed/screens/add_expense_screen.dart";
import "package:dhanwiser_fixed/screens/profile_screen.dart";
import "package:dhanwiser_fixed/screens/friend_discovery_screen.dart";
import "package:dhanwiser_fixed/screens/activity_screen.dart";
import "package:shared_preferences/shared_preferences.dart";
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isOnboardingCompleted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    setState(() {
      _isOnboardingCompleted = hasSeenOnboarding;
      _isLoading = false;
    });
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    setState(() {
      _isOnboardingCompleted = true;
    });
    // Navigation is handled in OnboardingScreen or by rebuilding MyApp with new state
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF5048E5),
          body: Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DhanWiser',
      theme: ThemeData(
        primaryColor: const Color(0xFF5048E5),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF5048E5),
          secondary: const Color(0xFF10B981),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5048E5),
          elevation: 0,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF5048E5),
        scaffoldBackgroundColor: const Color(0xFF121121),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF5048E5),
          secondary: const Color(0xFF10B981),
          surface: const Color(0xFF1E1C30),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: _isOnboardingCompleted
          ? const HomeScreen()
          : OnboardingScreen(onOnboardingComplete: _completeOnboarding),
      routes: {
        '/onboarding': (context) => OnboardingScreen(onOnboardingComplete: _completeOnboarding),
        '/home': (context) => const HomeScreen(),
        '/create-server': (context) => const CreateServerScreen(),
        '/server-detail': (context) => const ServerDetailScreen(),
        '/add-expense': (context) => const AddExpenseScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/friend-discovery': (context) => const FriendDiscoveryScreen(),
        '/activity': (context) => const ActivityScreen(),
      },
    );
  }
}