import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/colors.dart';
import 'package:dhanwiser_fixed/theme/text_styles.dart';
import 'package:dhanwiser_fixed/widgets/bouncing_button.dart';

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
        backgroundColor: DhanWiserColors.of(context).negative,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DhanWiserColors.of(context).background,
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
                  decoration: BoxDecoration(
                    color: DhanWiserColors.of(context).primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'D',
                      style: DhanWiserTextStyles.headline1(context)
                          .copyWith(color: DhanWiserColors.of(context).background),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Brand Name ──
              Center(
                child: Text(
                  'DhanWiser',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: DhanWiserColors.of(context).textPrimary, letterSpacing: -0.5),
                ),
              ),
              const SizedBox(height: 40),

              // ── Welcome Title ──
              Text(
                'Welcome back.',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: DhanWiserColors.of(context).textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to your account',
                style: DhanWiserTextStyles.bodyRegular(context)
                    .copyWith(color: DhanWiserColors.of(context).textSecondary),
              ),
              const SizedBox(height: 36),

              // ── Email Field ──
              Text(
                'EMAIL',
                style: DhanWiserTextStyles.overline(context).copyWith(
                    color: DhanWiserColors.of(context).textSecondary, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: DhanWiserTextStyles.bodyRegular(context)
                    .copyWith(color: DhanWiserColors.of(context).textPrimary),
                decoration: InputDecoration(
                  hintText: 'smit@example.com',
                  hintStyle: DhanWiserTextStyles.bodyRegular(context)
                      .copyWith(color: DhanWiserColors.of(context).textDisabled),
                  filled: true,
                  fillColor: DhanWiserColors.of(context).surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: DhanWiserColors.of(context).outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: DhanWiserColors.of(context).outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: DhanWiserColors.of(context).primary, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 20),

              // ── Password Field ──
              Text(
                'PASSWORD',
                style: DhanWiserTextStyles.overline(context).copyWith(
                    color: DhanWiserColors.of(context).textSecondary, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
                style: DhanWiserTextStyles.bodyRegular(context)
                    .copyWith(color: DhanWiserColors.of(context).textPrimary),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: DhanWiserTextStyles.bodyRegular(context)
                      .copyWith(color: DhanWiserColors.of(context).textDisabled),
                  filled: true,
                  fillColor: DhanWiserColors.of(context).surfaceContainer,
                  suffixIcon: PremiumIconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: DhanWiserColors.of(context).textDisabled,
                      size: 22,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: DhanWiserColors.of(context).outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: DhanWiserColors.of(context).outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: DhanWiserColors.of(context).primary, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 12),

              // ── Forgot Password ──
              Align(
                alignment: Alignment.centerRight,
                child: PremiumTextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot password?',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: DhanWiserColors.of(context).primary),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Sign In Button ──
              SizedBox(
                height: 56,
                child: PremiumFilledButton(
                  onPressed: _isSubmitting ? null : _login,
                  style: FilledButton.styleFrom(
                    backgroundColor: DhanWiserColors.of(context).primary,
                    foregroundColor: DhanWiserColors.of(context).background,
                    disabledBackgroundColor:
                        DhanWiserColors.of(context).primary.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: DhanWiserColors.of(context).background,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Sign In',
                          style: Theme.of(context).textTheme.titleMedium!,
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Divider ──
              Row(
                children: [
                  Expanded(child: Divider(color: DhanWiserColors.of(context).outline)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: DhanWiserTextStyles.caption(context)
                          .copyWith(color: DhanWiserColors.of(context).textDisabled),
                    ),
                  ),
                  Expanded(child: Divider(color: DhanWiserColors.of(context).outline)),
                ],
              ),
              const SizedBox(height: 24),

              // ── Sign Up Link ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: DhanWiserTextStyles.caption(context)
                        .copyWith(color: DhanWiserColors.of(context).textSecondary),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/signup'),
                    child: Text(
                      'Sign up',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(color: DhanWiserColors.of(context).primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Skip Login (Testing Mode - Debug Only) ──
              if (kDebugMode)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: DhanWiserColors.of(context).outline),
                      borderRadius: BorderRadius.circular(12),
                      color: DhanWiserColors.of(context).surfaceContainer,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '⚠️  Server down?',
                          style: DhanWiserTextStyles.overline(context)
                              .copyWith(color: DhanWiserColors.of(context).warning),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: PremiumOutlinedButtonIcon(
                            onPressed: () {
                              final auth = Provider.of<AuthProvider>(context,
                                  listen: false);
                              auth.loginAsGuest();
                              Navigator.pushReplacementNamed(context, '/home');
                            },
                            icon: const Icon(Icons.science_rounded, size: 18),
                            label: Text(
                              'Skip Login (Testing Mode)',
                              style: DhanWiserTextStyles.overline(context),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: DhanWiserColors.of(context).warning,
                              side: BorderSide(
                                  color: DhanWiserColors.of(context).warning
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
