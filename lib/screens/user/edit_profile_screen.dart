import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Color(0xFF00685E),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Failed to update profile',
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
                              'EDIT PROFILE',
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
                                  'PERSONAL INFO',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF2C1810),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Keep your details up to date for a better experience.',
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

                          // Full Name
                          _buildTextField(
                            controller: _nameController,
                            label: 'FULL NAME',
                            icon: Icons.person_outline_rounded,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Email
                          _buildTextField(
                            controller: _emailController,
                            label: 'EMAIL ADDRESS',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!value.contains('@')) {
                                return 'Invalid email format';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Phone
                          _buildTextField(
                            controller: _phoneController,
                            label: 'PHONE NUMBER',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Phone number is required';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 40),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _saveProfile,
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
                                        'SAVE CHANGES',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
            keyboardType: keyboardType,
            validator: validator,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C1810),
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF2C1810)),
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

