import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../user/user_main_screen.dart';
import '../teknisi/teknisi_home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

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
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        backgroundColor: isError ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final user = authProvider.currentUser;
      final destination = user?.role == 'teknisi' 
        ? const TeknisiHomeScreen() 
        : const UserMainScreen();
      
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => destination));
    } else {
      _showSnackbar(authProvider.errorMessage ?? 'Login gagal', isError: true);
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
                    image: NetworkImage('https://www.transparenttextures.com/patterns/carbon-fibre.png'),
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
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const Spacer(),
                            const SizedBox(height: 40),
                            // Logo & Header
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD9614C),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFF2C1810), width: 4),
                                      boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(6, 6))],
                                    ),
                                    child: const Icon(Icons.motorcycle_rounded, color: Color(0xFFF4EBD0), size: 50),
                                  ),
                                  const SizedBox(height: 24),
                                  Text('CARE-U', style: GoogleFonts.plusJakartaSans(fontSize: 48, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810), letterSpacing: 2)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    color: const Color(0xFFE5A35C),
                                    child: Text('EST. 2024 • SERVICE & CARE', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF2C1810))),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 50),
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

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EBD0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2C1810), width: 4),
        boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(8, 8))],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Email'),
            const SizedBox(height: 8),
            _buildTextField(controller: _emailController, hint: 'Email Anda', icon: Icons.email_outlined),
            const SizedBox(height: 20),
            _buildLabel('Password'),
            const SizedBox(height: 8),
            _buildTextField(controller: _passwordController, hint: 'Password', icon: Icons.lock_outline, isPassword: true, obscureText: _obscurePassword, toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword)),
            const SizedBox(height: 32),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C1810),
                      foregroundColor: const Color(0xFFF4EBD0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: auth.isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF4EBD0)))
                      : Text('LOGIN NOW', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: Text('CREATE NEW ACCOUNT', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFFD9614C), decoration: TextDecoration.underline)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810), letterSpacing: 1));
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false, bool obscureText = false, VoidCallback? toggleObscure}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF2C1810)),
      decoration: InputDecoration(
        hintText: hint.toUpperCase(),
        prefixIcon: Icon(icon, color: const Color(0xFF2C1810)),
        suffixIcon: isPassword ? IconButton(icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF2C1810)), onPressed: toggleObscure) : null,
        filled: true,
        fillColor: const Color(0xFFF4EBD0).withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2C1810), width: 3)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2C1810), width: 3)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFD9614C), width: 3)),
      ),
    );
  }
}
