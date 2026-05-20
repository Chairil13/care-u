import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'edit_password_screen.dart';
import 'motorcycle_list_screen.dart';
import '../../providers/motorcycle_provider.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final fullName = user?.name ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD0), // Vintage Paper
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4EBD0),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: null,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE5B94C), // Retro Mustard
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2C1810), width: 3),
            boxShadow: const [
              BoxShadow(color: Color(0xFF2C1810), offset: Offset(2, 2)),
            ],
          ),
          child: Text(
            'PROFILE',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: const Color(0xFF2C1810),
              letterSpacing: 1,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: const Color(0xFF2C1810), height: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        child: Column(
          children: [
            _buildIdentityHero(context, fullName, user?.avatarUrl),
            const SizedBox(height: 32),

            // Account Settings Bento
            _buildAccountSettings(context),
            const SizedBox(height: 32),

            // My Motorcycle Section
            _buildMotorcycleSection(context),
            const SizedBox(height: 32),

            // Logout Button
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(
    BuildContext context,
    String imageUrl,
    String fullName,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              fullName,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: Color(0xFF00685E),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: Color(0xFF00685E),
              ),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null && context.mounted) {
        final authProvider = context.read<AuthProvider>();
        final success = await authProvider.uploadAvatar(File(pickedFile.path));

        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture updated successfully'),
                backgroundColor: Color(0xFF00685E),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  authProvider.errorMessage ?? 'Failed to upload photo',
                ),
                backgroundColor: const Color(0xFF93000A),
              ),
            );
          }
        }
      }
    }
  }

  Widget _buildIdentityHero(
    BuildContext context,
    String fullName,
    String? avatarUrl,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(70),
                border: Border.all(color: const Color(0xFF2C1810), width: 3),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF2C1810), offset: Offset(6, 6)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(70),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final url =
                          avatarUrl ??
                          'https://ui-avatars.com/api/?name=${fullName.replaceAll(' ', '+')}&background=E5B94C&color=2C1810&size=512';
                      _showFullScreenImage(context, url, fullName);
                    },
                    child: avatarUrl != null
                        ? Image.network(avatarUrl, fit: BoxFit.cover)
                        : Image.network(
                            'https://ui-avatars.com/api/?name=${fullName.replaceAll(' ', '+')}&background=E5B94C&color=2C1810&size=256',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return GestureDetector(
                  onTap: () => _pickImage(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5B94C),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2C1810),
                        width: 2,
                      ),
                    ),
                    child: auth.isUploadingAvatar
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF2C1810),
                            ),
                          )
                        : const Icon(
                            Icons.photo_camera_rounded,
                            color: Color(0xFF2C1810),
                            size: 18,
                          ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          fullName.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF2C1810),
            letterSpacing: 1,
          ),
        ),
        Consumer<MotorcycleProvider>(
          builder: (context, provider, child) {
            final bike = provider.motorcycles.isNotEmpty
                ? provider.motorcycles.first
                : null;
            final bikeName = bike != null
                ? '${bike.brand} ${bike.model}'
                : 'NO MOTORCYLE';

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFA4F0E9), // tertiary-fixed
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF89D4CD),
                ), // tertiary-fixed-dim
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.two_wheeler_rounded,
                    size: 16,
                    color: Color(0xFF00504B),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    bikeName,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      color: const Color(0xFF00504B),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAccountSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCOUNT SETTINGS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF2C1810),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        _buildRetroMenuItem(
          context,
          'PROFILE INFO',
          'MANAGE YOUR PERSONAL DETAILS',
          Icons.person_rounded,
          const Color(0xFFE5B94C),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildRetroMenuItem(
                context,
                'SECURITY',
                'PASSWORDS',
                Icons.lock_rounded,
                const Color(0xFFF28B82),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditPasswordScreen()),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildRetroMenuItem(
                context,
                'ALERTS',
                'NOTIFS',
                Icons.notifications_active_rounded,
                const Color(0xFF81C995),
                () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRetroMenuItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2C1810), width: 3),
          boxShadow: const [
            BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2C1810), width: 2),
              ),
              child: Icon(icon, color: const Color(0xFF2C1810), size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2C1810),
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2C1810).withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotorcycleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MY MOTORCYCLE',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF2C1810),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF4EBD0), // Vintage Paper
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF2C1810), width: 3),
            boxShadow: const [
              BoxShadow(color: Color(0xFF2C1810), offset: Offset(6, 6)),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF2C1810), width: 3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.two_wheeler_rounded,
                      color: Color(0xFF2C1810),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'GARAGE STATUS',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: const Color(0xFF2C1810),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Consumer<MotorcycleProvider>(
                  builder: (context, provider, child) {
                    final bike = provider.motorcycles.isNotEmpty
                        ? provider.motorcycles.first
                        : null;
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bike != null
                                    ? '${bike.brand} ${bike.model}'
                                          .toUpperCase()
                                    : 'NO MOTORCYCLES',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF2C1810),
                                ),
                              ),
                              Text(
                                bike != null
                                    ? 'YEAR: ${bike.year}'
                                    : 'ADD YOUR FIRST MOTOR',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(
                                    0xFF2C1810,
                                  ).withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MotorcycleListScreen(),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFF2C1810),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Color(0xFF2C1810),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final authProvider = context.read<AuthProvider>();
        await authProvider.signOut();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFF5A5F), // Retro Red
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2C1810), width: 3),
          boxShadow: const [
            BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Color(0xFF2C1810)),
            const SizedBox(width: 8),
            Text(
              'LOG OUT',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2C1810),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
