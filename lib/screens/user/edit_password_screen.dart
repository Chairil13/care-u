import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class EditPasswordScreen extends StatefulWidget {
  const EditPasswordScreen({super.key});

  @override
  State<EditPasswordScreen> createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.updatePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully. Please login again.'),
          backgroundColor: Color(0xFF00685E),
        ),
      );
      await authProvider.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Failed to update password',
          ),
          backgroundColor: const Color(0xFF93000A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD0), // Vintage Paper
      body: Stack(
        children: [
          // Background Texture
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/carbon-fibre.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Custom Branded AppBar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9614C), // Retro Red
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF2C1810), width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF2C1810),
                          offset: Offset(8, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFF4EBD0)),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              'SECURITY',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: const Color(0xFFF4EBD0),
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48), // Placeholder for balance
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF2C1810), width: 4),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF2C1810),
                                  offset: Offset(8, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CHANGE PASSWORD',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF2C1810),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Your new password must be at least 6 characters long.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF2C1810).withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Current Password
                          _buildPasswordField(
                            controller: _currentPasswordController,
                            label: 'CURRENT PASSWORD',
                            obscureText: _obscureCurrent,
                            onToggleVisibility: () {
                              setState(() {
                                _obscureCurrent = !_obscureCurrent;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your current password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // New Password
                          _buildPasswordField(
                            controller: _newPasswordController,
                            label: 'NEW PASSWORD',
                            obscureText: _obscureNew,
                            onToggleVisibility: () {
                              setState(() {
                                _obscureNew = !_obscureNew;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a new password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Confirm Password
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            label: 'CONFIRM NEW PASSWORD',
                            obscureText: _obscureConfirm,
                            onToggleVisibility: () {
                              setState(() {
                                _obscureConfirm = !_obscureConfirm;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your new password';
                              }
                              if (value != _newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 40),

                          // Update Button
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _updatePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD9614C), // Retro Red
                                foregroundColor: const Color(0xFFF4EBD0),
                                disabledBackgroundColor: const Color(0xFFD9614C).withValues(alpha: 0.6),
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Color(0xFF2C1810), width: 4),
                                ),
                              ).copyWith(
                                shadowColor: WidgetStateProperty.all(Colors.transparent),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xFF2C1810),
                                      offset: Offset(8, 8),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: Color(0xFFF4EBD0),
                                        ),
                                      )
                                    : Text(
                                        'UPDATE PASSWORD',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2C1810),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF2C1810),
                offset: Offset(4, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C1810),
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF2C1810)),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: const Color(0xFF2C1810),
                ),
                onPressed: onToggleVisibility,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF2C1810), width: 4),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF2C1810), width: 4),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFD9614C), width: 4),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 4),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 4),
              ),
              errorStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

