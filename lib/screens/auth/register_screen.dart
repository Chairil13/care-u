import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../user/user_main_screen.dart';
import '../teknisi/teknisi_home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _selectedRole = 'user';

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
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        backgroundColor: isError
            ? const Color(0xFFD32F2F)
            : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackbar('Password tidak cocok', isError: true);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      role: _selectedRole,
    );

    if (!mounted) return;

    if (success) {
      _showSnackbar('Registrasi berhasil!');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => _selectedRole == 'teknisi'
              ? const TeknisiHomeScreen()
              : const UserMainScreen(),
        ),
        (route) => false,
      );
    } else {
      _showSnackbar(authProvider.errorMessage ?? 'Gagal daftar', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD0),
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://www.transparenttextures.com/patterns/carbon-fibre.png',
                    ),
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
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            // Header
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: _buildIconButton(
                                      Icons.arrow_back_ios_new_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'NEW ACCOUNT',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF2C1810),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        color: const Color(0xFFE5A35C),
                                        child: Text(
                                          'JOIN THE SERVICE CREW',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF2C1810),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(height: 20),
                            // Form
                            SlideTransition(
                              position: _slideAnimation,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: _buildFormCard(),
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

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD9614C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C1810), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4)),
        ],
      ),
      child: Icon(icon, color: const Color(0xFFF4EBD0), size: 16),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EBD0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2C1810), width: 4),
        boxShadow: const [
          BoxShadow(color: Color(0xFF2C1810), offset: Offset(8, 8)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Daftar Sebagai'),
            const SizedBox(height: 12),
            _buildRoleSelector(),
            const SizedBox(height: 24),
            _buildLabel('Nama Lengkap'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: 'Nama Anda',
              icon: Icons.person_outline,
              validator: (v) => v!.isEmpty ? 'NAMA TIDAK BOLEH KOSONG' : null,
            ),
            const SizedBox(height: 16),
            _buildLabel('Email'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              hint: 'Email Anda',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v!.isEmpty) return 'EMAIL TIDAK BOLEH KOSONG';
                if (!v.contains('@')) return 'EMAIL TIDAK VALID';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildLabel('Password'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _passwordController,
              hint: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              obscureText: _obscurePassword,
              toggleObscure: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              validator: (v) => v!.length < 6 ? 'MINIMAL 6 KARAKTER' : null,
            ),
            const SizedBox(height: 16),
            _buildLabel('Konfirmasi Password'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _confirmPasswordController,
              hint: 'Ulangi Password',
              icon: Icons.lock_clock_outlined,
              isPassword: true,
              obscureText: _obscureConfirm,
              toggleObscure: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              validator: (v) => v!.isEmpty ? 'KONFIRMASI PASSWORD' : null,
            ),
            const SizedBox(height: 32),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C1810),
                      foregroundColor: const Color(0xFFF4EBD0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFF4EBD0),
                            ),
                          )
                        : Text(
                            'CONFIRM REGISTRATION',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleObscure,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF2C1810),
      ),
      decoration: InputDecoration(
        hintText: hint.toUpperCase(),
        prefixIcon: Icon(icon, color: const Color(0xFF2C1810)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF2C1810),
                ),
                onPressed: toggleObscure,
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF4EBD0).withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2C1810), width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2C1810), width: 3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD9614C), width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 3),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 3),
        ),
        errorStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          fontSize: 10,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Row(
      children: [
        _roleButton('user', 'USER', Icons.person_rounded),
        const SizedBox(width: 12),
        _roleButton('teknisi', 'TEKNISI', Icons.build_rounded),
      ],
    );
  }

  Widget _roleButton(String role, String label, IconData icon) {
    bool isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFE5B94C)
                : const Color(0xFFF4EBD0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2C1810), width: 3),
            boxShadow: isSelected
                ? const [
                    BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4)),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF2C1810), size: 24),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2C1810),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
