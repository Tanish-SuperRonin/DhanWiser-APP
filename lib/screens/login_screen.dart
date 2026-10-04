import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/iconly_icons.dart';
import 'package:provider/provider.dart';
import '../utils/validators.dart';
import '../providers/auth_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/bouncing_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
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
      _showSnackBar('Please fill in your email and password');
      return;
    }

    setState(() => _isSubmitting = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(email: email, password: password);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showSnackBar(auth.error ?? 'Invalid email or password');
    }

    setState(() => _isSubmitting = false);
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: DhanWiserColors.of(context).carmine,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = DhanWiserColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Brand Monogram ──
                    Center(
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? colors.card : const Color(0xFF0F172A),
                          border: Border.all(
                            color: colors.cardBorder,
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'D',
                            style: DhanWiserTextStyles.headline1(context).copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: isDark ? colors.primary : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Brand Title & Tagline ──
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'DhanWiser',
                            style: DhanWiserTextStyles.headline1(context).copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: colors.card,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: colors.cardBorder),
                            ),
                            child: Text(
                              'Intelligent Expense & Split System',
                              style: DhanWiserTextStyles.overline(context).copyWith(
                                color: colors.textSecondary,
                                fontSize: 10,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ── Sign In Card Container ──
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colors.cardBorder),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back',
                            style: DhanWiserTextStyles.title1(context).copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Enter your credentials to access your financial circles',
                            style: DhanWiserTextStyles.caption(context).copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Email Input ──
                          Text(
                            'EMAIL ADDRESS',
                            style: DhanWiserTextStyles.overline(context).copyWith(
                              color: colors.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            validator: Validators.email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            style: DhanWiserTextStyles.bodyRegular(context).copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: 'alex@example.com',
                              prefixIcon: Icon(IconlyLight.message, color: colors.textSecondary, size: 20),
                              filled: true,
                              fillColor: colors.surfaceContainer,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: colors.cardBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: colors.cardBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: colors.primary, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // ── Password Input ──
                          Text(
                            'PASSWORD',
                            style: DhanWiserTextStyles.overline(context).copyWith(
                              color: colors.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            validator: (v) => Validators.notEmpty(v, 'Password'),
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _login(),
                            style: DhanWiserTextStyles.bodyRegular(context).copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: Icon(IconlyLight.lock, color: colors.textSecondary, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? IconlyLight.hide : IconlyLight.show,
                                  color: colors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: colors.surfaceContainer,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: colors.cardBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: colors.cardBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: colors.primary, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Password reset link sent to registered email'),
                                    backgroundColor: colors.emerald,
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot password?',
                                style: DhanWiserTextStyles.caption(context).copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Sign In Action Button ──
                          BouncingButton(
                            onTap: _isSubmitting ? null : _login,
                            child: Container(
                              height: 52,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isDark ? colors.primary : const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? colors.primary : const Color(0xFF0F172A))
                                        .withValues(alpha: 0.2),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: _isSubmitting
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: isDark ? colors.background : Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Sign In',
                                      style: DhanWiserTextStyles.buttonLarge(context).copyWith(
                                        color: isDark ? colors.background : Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Register Navigation Row ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: DhanWiserTextStyles.caption(context).copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, '/signup'),
                          child: Text(
                            'Create Account',
                            style: DhanWiserTextStyles.caption(context).copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Debug / Guest Mode ──
                    if (kDebugMode)
                      Center(
                        child: BouncingButton(
                          onTap: () {
                            final auth = Provider.of<AuthProvider>(context, listen: false);
                            auth.loginAsGuest();
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: colors.card,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: colors.cardBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt_rounded, size: 16, color: colors.warning),
                                const SizedBox(width: 6),
                                Text(
                                  'Explore in Guest / Demo Mode',
                                  style: DhanWiserTextStyles.caption(context).copyWith(
                                    color: colors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
