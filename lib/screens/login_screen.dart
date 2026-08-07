import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    setState(() => _isSubmitting = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(email: email, password: password);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showSnackBar(auth.error ?? 'Login failed');
    }

    setState(() => _isSubmitting = false);
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: DhanWiserColors.negative,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DhanWiserColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // ── D Logo Avatar ──
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: DhanWiserColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'D',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: DhanWiserColors.backgroundDark,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Brand Name ──
              Center(
                child: Text(
                  'DhanWiser',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: DhanWiserColors.textPrimaryDark,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // ── Welcome Title ──
              Text(
                'Welcome back.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: DhanWiserColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to your account',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: DhanWiserColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 36),

              // ── Email Field ──
              Text(
                'EMAIL',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DhanWiserColors.textSecondaryDark,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: GoogleFonts.dmSans(
                  color: DhanWiserColors.textPrimaryDark,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'smit@example.com',
                  hintStyle: GoogleFonts.dmSans(
                    color: DhanWiserColors.textMuted,
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: DhanWiserColors.surfaceContainerDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: DhanWiserColors.outlineDark),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: DhanWiserColors.outlineDark),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: DhanWiserColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 20),

              // ── Password Field ──
              Text(
                'PASSWORD',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DhanWiserColors.textSecondaryDark,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
                style: GoogleFonts.dmSans(
                  color: DhanWiserColors.textPrimaryDark,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: GoogleFonts.dmSans(
                    color: DhanWiserColors.textMuted,
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: DhanWiserColors.surfaceContainerDark,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: DhanWiserColors.textMuted,
                      size: 22,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: DhanWiserColors.outlineDark),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: DhanWiserColors.outlineDark),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: DhanWiserColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 12),

              // ── Forgot Password ──
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot password?',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DhanWiserColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Sign In Button ──
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _login,
                  style: FilledButton.styleFrom(
                    backgroundColor: DhanWiserColors.primary,
                    foregroundColor: DhanWiserColors.backgroundDark,
                    disabledBackgroundColor:
                        DhanWiserColors.primary.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: DhanWiserColors.backgroundDark,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Sign In',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Divider ──
              Row(
                children: [
                  const Expanded(
                      child: Divider(color: DhanWiserColors.outlineDark)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: GoogleFonts.dmSans(
                        color: DhanWiserColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Expanded(
                      child: Divider(color: DhanWiserColors.outlineDark)),
                ],
              ),
              const SizedBox(height: 24),

              // ── Sign Up Link ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: DhanWiserColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/signup'),
                    child: Text(
                      'Sign up',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: DhanWiserColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Skip Login (Testing) ──
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: DhanWiserColors.outlineDark),
                    borderRadius: BorderRadius.circular(12),
                    color: DhanWiserColors.surfaceContainerDark,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '⚠️  Server down?',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: DhanWiserColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final auth = Provider.of<AuthProvider>(
                                context,
                                listen: false);
                            auth.loginAsGuest();
                            Navigator.pushReplacementNamed(
                                context, '/home');
                          },
                          icon: const Icon(Icons.science_rounded,
                              size: 18),
                          label: Text(
                            'Skip Login (Testing Mode)',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: DhanWiserColors.warning,
                            side: BorderSide(
                                color: DhanWiserColors.warning
                                    .withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
