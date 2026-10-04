import 'package:flutter/material.dart';
import '../theme/iconly_icons.dart';
import 'package:provider/provider.dart';
import '../utils/validators.dart';
import '../providers/auth_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/bouncing_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _upiController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signup(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      upiId: _upiController.text.trim().isNotEmpty
          ? _upiController.text.trim()
          : null,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  InputDecoration _inputDeco({
    required String hint,
    required DhanWiserColors colors,
    Widget? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefix,
      suffixIcon: suffix,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.carmine),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.carmine, width: 2),
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
                    // ── Brand Monogram & Header ──
                    Center(
                      child: Container(
                        width: 54,
                        height: 54,
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
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'DhanWiser',
                        style: DhanWiserTextStyles.headline2(context).copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Sign Up Card Container ──
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
                            'Create Account',
                            style: DhanWiserTextStyles.title1(context).copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Join your friends and manage group splits seamlessly',
                            style: DhanWiserTextStyles.caption(context).copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Error Banner ──
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              if (auth.error == null) return const SizedBox.shrink();
                              return Container(
                                margin: const EdgeInsets.only(bottom: 18),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: colors.carmine.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: colors.carmine.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline_rounded, color: colors.carmine, size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        auth.error!,
                                        style: DhanWiserTextStyles.caption(context).copyWith(
                                          color: colors.carmine,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          // ── Full Name ──
                          _buildLabel('FULL NAME', colors),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _fullNameController,
                            style: DhanWiserTextStyles.bodyRegular(context).copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _inputDeco(
                              hint: 'Alex Sharma',
                              colors: colors,
                              prefix: Icon(IconlyLight.profile, color: colors.textSecondary, size: 20),
                            ),
                            validator: (v) => Validators.notEmpty(v, 'Full Name'),
                          ),
                          const SizedBox(height: 16),

                          // ── Username ──
                          _buildLabel('USERNAME', colors),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _usernameController,
                            style: DhanWiserTextStyles.bodyRegular(context).copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _inputDeco(
                              hint: 'alexsharma',
                              colors: colors,
                              prefix: Padding(
                                padding: const EdgeInsets.only(left: 14, right: 8, top: 13),
                                child: Text(
                                  '@',
                                  style: DhanWiserTextStyles.bodyBold(context).copyWith(
                                    color: colors.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Username is required';
                              if (v.length < 3) return 'At least 3 characters';
                              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v)) {
                                return 'Letters, numbers, and underscores only';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // ── Email ──
                          _buildLabel('EMAIL ADDRESS', colors),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: DhanWiserTextStyles.bodyRegular(context).copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _inputDeco(
                              hint: 'alex@example.com',
                              colors: colors,
                              prefix: Icon(IconlyLight.message, color: colors.textSecondary, size: 20),
                            ),
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 16),

                          // ── Password ──
                          _buildLabel('PASSWORD', colors),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: DhanWiserTextStyles.bodyRegular(context).copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _inputDeco(
                              hint: '••••••••',
                              colors: colors,
                              prefix: Icon(IconlyLight.lock, color: colors.textSecondary, size: 20),
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword ? IconlyLight.hide : IconlyLight.show,
                                  color: colors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: Validators.password,
                          ),
                          const SizedBox(height: 16),

                          // ── UPI ID (Optional) ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLabel('UPI ID', colors),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'OPTIONAL',
                                  style: DhanWiserTextStyles.overline(context).copyWith(
                                    color: colors.primary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _upiController,
                            style: DhanWiserTextStyles.bodyRegular(context).copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _inputDeco(
                              hint: 'alex@okhdfcbank',
                              colors: colors,
                              prefix: Icon(IconlyLight.wallet, color: colors.emerald, size: 20),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Continue Action Button ──
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              return BouncingButton(
                                onTap: auth.isLoading ? null : _signup,
                                child: Container(
                                  width: double.infinity,
                                  height: 52,
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
                                  child: auth.isLoading
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: isDark ? colors.background : Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Create My Account',
                                          style: DhanWiserTextStyles.buttonLarge(context).copyWith(
                                            color: isDark ? colors.background : Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Sign In Navigation ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: DhanWiserTextStyles.caption(context).copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: Text(
                            'Sign In',
                            style: DhanWiserTextStyles.caption(context).copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildLabel(String text, DhanWiserColors colors) {
    return Text(
      text,
      style: DhanWiserTextStyles.overline(context).copyWith(
        color: colors.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}
