import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/colors.dart';
import 'package:dhanwiser_fixed/theme/text_styles.dart';
import 'package:dhanwiser_fixed/widgets/bouncing_button.dart';

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
    Widget? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: DhanWiserTextStyles.bodyRegular(context)
          .copyWith(color: DhanWiserColors.of(context).textDisabled),
      prefixIcon: prefix,
      suffixIcon: suffix,
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
        borderSide: BorderSide(color: DhanWiserColors.of(context).primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DhanWiserColors.of(context).negative),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DhanWiserColors.of(context).negative, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DhanWiserColors.of(context).background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),

                // ── D Logo (centered) ──
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: DhanWiserColors.of(context).primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'D',
                        style: DhanWiserTextStyles.headline2(context)
                            .copyWith(color: DhanWiserColors.of(context).background),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Center(
                  child: Text(
                    'DhanWiser',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: DhanWiserColors.of(context).textPrimary),
                  ),
                ),
                SizedBox(height: 32),

                // ── Title ──
                Text(
                  'Create account.',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(color: DhanWiserColors.of(context).textPrimary),
                ),
                SizedBox(height: 6),
                Text(
                  'Join your friends on DhanWiser',
                  style: DhanWiserTextStyles.bodyRegular(context)
                      .copyWith(color: DhanWiserColors.of(context).textSecondary),
                ),
                SizedBox(height: 28),

                // ── Error ──
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (auth.error == null) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: DhanWiserColors.of(context).negativeSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: DhanWiserColors.of(context).negative, size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              auth.error!,
                              style: DhanWiserTextStyles.overline(context)
                                  .copyWith(
                                color: DhanWiserColors.of(context).negative,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // ── Full Name ──
                _buildLabel('FULL NAME'),
                SizedBox(height: 8),
                TextFormField(
                  controller: _fullNameController,
                  style: DhanWiserTextStyles.bodyRegular(context)
                      .copyWith(color: DhanWiserColors.of(context).textPrimary),
                  decoration: _inputDeco(hint: 'e.g. Smit Nayi'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Full name is required' : null,
                ),
                SizedBox(height: 16),

                // ── Username ──
                _buildLabel('USERNAME'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  style: DhanWiserTextStyles.bodyRegular(context)
                      .copyWith(color: DhanWiserColors.of(context).textPrimary),
                  decoration: _inputDeco(
                    hint: '@smitnayi',
                    prefix: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 0),
                      child: Text(
                        '@',
                        style: DhanWiserTextStyles.bodyRegular(context)
                            .copyWith(color: DhanWiserColors.of(context).textDisabled),
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Username is required';
                    if (v.length < 3) return 'At least 3 characters';
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v)) {
                      return 'Only letters, numbers, and underscores';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 4),
                Text(
                  'Others find you by this',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: DhanWiserColors.of(context).textDisabled),
                ),
                SizedBox(height: 16),

                // ── Email ──
                _buildLabel('EMAIL'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: DhanWiserTextStyles.bodyRegular(context)
                      .copyWith(color: DhanWiserColors.of(context).textPrimary),
                  decoration: _inputDeco(hint: 'smit@example.com'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // ── Password ──
                _buildLabel('PASSWORD'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: DhanWiserTextStyles.bodyRegular(context)
                      .copyWith(color: DhanWiserColors.of(context).textPrimary),
                  decoration: _inputDeco(
                    hint: '••••••••',
                    suffix: PremiumIconButton(
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
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'At least 6 characters';
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // ── UPI ID (optional) — highlighted in amber ──
                Text(
                  'UPI ID (OPTIONAL)',
                  style: DhanWiserTextStyles.overline(context).copyWith(
                      color: DhanWiserColors.of(context).primary, letterSpacing: 1),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _upiController,
                  style: DhanWiserTextStyles.bodyRegular(context)
                      .copyWith(color: DhanWiserColors.of(context).textPrimary),
                  decoration: _inputDeco(hint: 'name@okbank'),
                ),
                SizedBox(height: 4),
                Text(
                  'Add later in settings. We encrypt and never expose this.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: DhanWiserColors.of(context).textDisabled),
                ),
                SizedBox(height: 28),

                // ── Continue Button ──
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: PremiumFilledButton(
                        onPressed: auth.isLoading ? null : _signup,
                        style: FilledButton.styleFrom(
                          backgroundColor: DhanWiserColors.of(context).primary,
                          foregroundColor: DhanWiserColors.of(context).background,
                          disabledBackgroundColor:
                              DhanWiserColors.of(context).primary.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: auth.isLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: DhanWiserColors.of(context).background,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Continue',
                                style: Theme.of(context).textTheme.titleMedium!,
                              ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 24),

                // ── Login link ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: DhanWiserTextStyles.caption(context)
                          .copyWith(color: DhanWiserColors.of(context).textSecondary),
                    ),
                    SizedBox(width: 6),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: Text(
                        'Sign In',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: DhanWiserColors.of(context).primary),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: DhanWiserTextStyles.overline(context)
          .copyWith(color: DhanWiserColors.of(context).textSecondary, letterSpacing: 1),
    );
  }
}
