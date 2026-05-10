/// Register Screen — formulario completo con validación en tiempo real.
library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/neon_text_field.dart';
import '../../../core/widgets/neon_button.dart';
import '../../../core/widgets/neon_card.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _acceptedTerms = false;
  String _countryCode = '+34';

  // Real-time validation states
  bool? _nameValid;
  bool? _emailValid;
  bool? _phoneValid;
  bool? _passwordValid;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateName(String v) => setState(() => _nameValid = v.trim().length >= 2 ? true : (v.isEmpty ? null : false));
  void _validateEmail(String v) => setState(() {
    if (v.isEmpty) { _emailValid = null; return; }
    _emailValid = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(v.trim());
  });
  void _validatePhone(String v) => setState(() {
    if (v.isEmpty) { _phoneValid = null; return; }
    _phoneValid = RegExp(r'^\d{6,15}$').hasMatch(v.replaceAll(RegExp(r'\s'), ''));
  });
  void _validatePassword(String v) => setState(() {
    if (v.isEmpty) { _passwordValid = null; return; }
    _passwordValid = v.length >= 8;
  });

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Debes aceptar los términos'), backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
      phone: '$_countryCode${_phoneController.text.trim()}',
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Cuenta creada exitosamente'), backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      );
      // GoRouter will automatically redirect based on auth state, but we can explicitly go
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(children: [
              const SizedBox(height: 40),
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Column(children: [
                  Text(AppStrings.createAccount, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text(AppStrings.joinToday, style: GoogleFonts.inter(fontSize: 15, color: AppColors.textSecondary)),
                ]),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
                child: NeonCard(
                  padding: const EdgeInsets.all(24),
                  glowOpacity: 0.06,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    NeonTextField(
                      controller: _nameController, label: AppStrings.fullName, hint: AppStrings.fullNameHint,
                      textInputAction: TextInputAction.next, validator: Validators.required,
                      onChanged: _validateName, isValid: _nameValid,
                    ),
                    const SizedBox(height: 18),
                    NeonTextField(
                      controller: _emailController, label: AppStrings.email, hint: AppStrings.emailHint,
                      keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next,
                      validator: Validators.email, onChanged: _validateEmail, isValid: _emailValid,
                    ),
                    const SizedBox(height: 18),
                    // Phone with country code
                    Text(AppStrings.phone, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Container(
                        height: 56, width: 90,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _countryCode, isExpanded: true,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            icon: const Icon(Icons.arrow_drop_down, size: 20, color: AppColors.textTertiary),
                            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                            items: const [
                              DropdownMenuItem(value: '+34', child: Text('ES +34')),
                              DropdownMenuItem(value: '+1', child: Text('US +1')),
                              DropdownMenuItem(value: '+52', child: Text('MX +52')),
                              DropdownMenuItem(value: '+57', child: Text('CO +57')),
                            ],
                            onChanged: (v) { if (v != null) setState(() => _countryCode = v); },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: NeonTextField(
                          controller: _phoneController, hint: AppStrings.phoneHint,
                          keyboardType: TextInputType.phone, textInputAction: TextInputAction.next,
                          validator: Validators.phone, onChanged: _validatePhone, isValid: _phoneValid,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 18),
                    NeonTextField(
                      controller: _passwordController, label: AppStrings.password, hint: AppStrings.passwordHint,
                      obscureText: _obscurePassword, textInputAction: TextInputAction.done,
                      validator: Validators.password, onChanged: _validatePassword, isValid: _passwordValid,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textTertiary, size: 22),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(AppStrings.passwordMinChars, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              // Terms checkbox
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 400),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: RichText(
                        text: TextSpan(style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary), children: [
                          const TextSpan(text: 'He leído y acepto los '),
                          const TextSpan(text: AppStrings.termsLink, style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                          const TextSpan(text: ' y la '),
                          const TextSpan(text: AppStrings.privacyLink, style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                          const TextSpan(text: '.'),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 500),
                child: Consumer<AuthProvider>(
                  builder: (_, auth, _) => NeonButton(
                    text: AppStrings.createAccount, onPressed: _handleRegister, isLoading: auth.isLoading,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 600),
                child: Column(children: [
                  Text(AppStrings.orContinueWithAlt, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary)),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => context.read<AuthProvider>().signInWithGoogle(),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const FaIcon(FontAwesomeIcons.google, size: 20, color: Color(0xFF4285F4)),
                        const SizedBox(width: 12),
                        Text(AppStrings.registerWithGoogle, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                      ]),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 28),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 700),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(AppStrings.hasAccount, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(AppStrings.signIn, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                  ),
                ]),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ),
    );
  }
}
