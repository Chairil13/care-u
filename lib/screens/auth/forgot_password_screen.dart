import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _emailSent = false;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        backgroundColor:
            isError ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(
      email: _emailController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      setState(() => _emailSent = true);
      _showSnackbar('Kode reset password telah dikirim ke email Anda!');
    } else {
      setState(() {
        _errorMessage =
            authProvider.errorMessage ?? 'Gagal mengirim email reset password.';
      });
    }
  }

  Future<void> _handleVerifyCode() async {
    setState(() => _errorMessage = null);
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Kode verifikasi wajib diisi');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyResetCode(
      email: _emailController.text.trim(),
      token: code,
    );

    if (!mounted) return;

    if (success) {
      _showSnackbar('Kode berhasil diverifikasi!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
      );
    } else {
      setState(() {
        _errorMessage =
            authProvider.errorMessage ?? 'Kode verifikasi salah atau kedaluwarsa.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD0),
      body: SizedBox.expand(
        child: Stack(
          children: [
            // Background texture
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://www.transparenttextures.com/patterns/carbon-fibre.png'),
                    opacity: 0.1,
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            // Back button
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4EBD0),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFF2C1810),
                                          width: 3),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Color(0xFF2C1810),
                                            offset: Offset(4, 4))
                                      ],
                                    ),
                                    child: const Icon(Icons.arrow_back_rounded,
                                        color: Color(0xFF2C1810), size: 24),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Icon & Header
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: _emailSent
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFFE5A35C),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: const Color(0xFF2C1810),
                                          width: 4),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Color(0xFF2C1810),
                                            offset: Offset(6, 6))
                                      ],
                                    ),
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: Icon(
                                        _emailSent
                                            ? Icons.mark_email_read_rounded
                                            : Icons.lock_reset_rounded,
                                        color: const Color(0xFFF4EBD0),
                                        size: 50,
                                        key: ValueKey(_emailSent),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    _emailSent
                                        ? 'CEK EMAIL ANDA'
                                        : 'LUPA PASSWORD?',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF2C1810),
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    color: const Color(0xFFE5A35C),
                                    child: Text(
                                      _emailSent
                                          ? 'LINK RESET TELAH DIKIRIM'
                                          : 'RESET PASSWORD ANDA',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF2C1810),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            // Form / Success Card
                            SlideTransition(
                              position: _slideAnimation,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child:
                                    _emailSent ? _buildSuccessCard() : _buildFormCard(),
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EBD0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2C1810), width: 4),
        boxShadow: const [
          BoxShadow(color: Color(0xFF2C1810), offset: Offset(8, 8))
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE5A35C).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5A35C), width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Color(0xFF2C1810), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Masukkan email yang terdaftar. Kami akan mengirim link untuk mereset password Anda.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C1810),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildLabel('Email'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C1810)),
              decoration: InputDecoration(
                hintText: 'EMAIL ANDA',
                prefixIcon: const Icon(Icons.email_outlined,
                    color: Color(0xFF2C1810)),
                filled: true,
                fillColor: const Color(0xFFF4EBD0).withValues(alpha: 0.5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: Color(0xFF2C1810), width: 3)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: Color(0xFF2C1810), width: 3)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: Color(0xFFD9614C), width: 3)),
                errorStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD9614C)),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email wajib diisi';
                }
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEAEA),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: const Color(0xFFD9614C), width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Color(0xFFD9614C), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: const Color(0xFFD9614C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            // Submit button
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        auth.isLoading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD9614C),
                      foregroundColor: const Color(0xFFF4EBD0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFF4EBD0)))
                        : Text('KIRIM LINK RESET',
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1)),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Back to login
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'KEMBALI KE LOGIN',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2C1810),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EBD0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2C1810), width: 4),
        boxShadow: const [
          BoxShadow(color: Color(0xFF2C1810), offset: Offset(8, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2E7D32), width: 2),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32), size: 48),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Kode Terkirim!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2C1810),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Kami telah mengirim kode reset password ke:',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C1810).withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE5A35C).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5A35C), width: 2),
              ),
              child: Text(
                _emailController.text.trim(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2C1810),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildLabel('Kode Verifikasi'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.text,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2C1810)),
            decoration: InputDecoration(
              hintText: 'KODE RESET (OTP)',
              prefixIcon: const Icon(Icons.pin_rounded,
                  color: Color(0xFF2C1810)),
              filled: true,
              fillColor: const Color(0xFFF4EBD0).withValues(alpha: 0.5),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                      color: Color(0xFF2C1810), width: 3)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                      color: Color(0xFF2C1810), width: 3)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                      color: Color(0xFFD9614C), width: 3)),
              errorStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD9614C)),
            ),
          ),
          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEAEA),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color(0xFFD9614C), width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Color(0xFFD9614C), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: const Color(0xFFD9614C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          // Verify code button
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _handleVerifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9614C),
                    foregroundColor: const Color(0xFFF4EBD0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFF4EBD0)))
                      : Text('VERIFIKASI KODE',
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1)),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Resend / Change Email button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return ElevatedButton.icon(
                  onPressed: auth.isLoading
                      ? null
                      : () {
                          setState(() {
                            _emailSent = false;
                            _errorMessage = null;
                            _codeController.clear();
                          });
                        },
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text('KIRIM ULANG / UBAH EMAIL',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900, letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5A35C),
                    foregroundColor: const Color(0xFF2C1810),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C1810),
                foregroundColor: const Color(0xFFF4EBD0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text('KEMBALI KE LOGIN',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF2C1810),
        letterSpacing: 1,
      ),
    );
  }
}
