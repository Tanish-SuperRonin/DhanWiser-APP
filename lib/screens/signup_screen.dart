import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/colors.dart';

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
      hintStyle: GoogleFonts.dmSans(
        color: DhanWiserColors.textDisabled,
        fontSize: 16,
      ),
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: DhanWiserColors.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DhanWiserColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DhanWiserColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: DhanWiserColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DhanWiserColors.negative),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: DhanWiserColors.negative, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DhanWiserColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ── D Logo (centered) ──
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: DhanWiserColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'D',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: DhanWiserColors.background,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'DhanWiser',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: DhanWiserColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Title ──
                Text(
                  'Create account.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: DhanWiserColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Join your friends on DhanWiser',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    color: DhanWiserColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Error ──
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (auth.error == null) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: DhanWiserColors.negativeSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: DhanWiserColors.negative, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              auth.error!,
                              style: GoogleFonts.dmSans(
                                color: DhanWiserColors.negative,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
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
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fullNameController,
                  style: GoogleFonts.dmSans(
                      color: DhanWiserColors.textPrimary, fontSize: 16),
                  decoration: _inputDeco(hint: 'e.g. Smit Nayi'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Full name is required' : null,
                ),
                const SizedBox(height: 16),

                // ── Username ──
                _buildLabel('USERNAME'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  style: GoogleFonts.dmSans(
                      color: DhanWiserColors.textPrimary, fontSize: 16),
                  decoration: _inputDeco(
                    hint: '@smitnayi',
                    prefix: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 0),
                      child: Text(
                        '@',
                        style: GoogleFonts.dmSans(
                          color: DhanWiserColors.textDisabled,
                          fontSize: 16,
                        ),
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
                const SizedBox(height: 4),
                Text(
                  'Others find you by this',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: DhanWiserColors.textDisabled,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Email ──
                _buildLabel('EMAIL'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.dmSans(
                      color: DhanWiserColors.textPrimary, fontSize: 16),
                  decoration: _inputDeco(hint: 'smit@example.com'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Password ──
                _buildLabel('PASSWORD'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.dmSans(
                      color: DhanWiserColors.textPrimary, fontSize: 16),
                  decoration: _inputDeco(
                    hint: '••••••••',
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: DhanWiserColors.textDisabled,
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
                const SizedBox(height: 16),

                // ── UPI ID (optional) — highlighted in amber ──
                Text(
                  'UPI ID (OPTIONAL)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DhanWiserColors.primary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _upiController,
                  style: GoogleFonts.dmSans(
                      color: DhanWiserColors.textPrimary, fontSize: 16),
                  decoration: _inputDeco(hint: 'name@okbank'),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add later in settings. We encrypt and never expose this.',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: DhanWiserColors.textDisabled,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Continue Button ──
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: auth.isLoading ? null : _signup,
                        style: FilledButton.styleFrom(
                          backgroundColor: DhanWiserColors.primary,
                          foregroundColor: DhanWiserColors.background,
                          disabledBackgroundColor:
                              DhanWiserColors.primary.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: DhanWiserColors.background,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Continue',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // ── Login link ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: GoogleFonts.dmSans(
                        color: DhanWiserColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: Text(
                        'Sign In',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: DhanWiserColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
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
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: DhanWiserColors.textSecondary,
        letterSpacing: 1,
      ),
    );
  }
}
