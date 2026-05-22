import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/story_provider.dart';
import '../user/edit_profile_screen.dart';
import '../user/edit_password_screen.dart';
import 'user_list_screen.dart';

class TeknisiProfileScreen extends StatelessWidget {
  const TeknisiProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD0),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.network('https://www.transparenttextures.com/patterns/pinstriped-suit.png', repeat: ImageRepeat.repeat),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90D9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF2C1810), width: 4),
                      boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(8, 8))],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('PROFIL TEKNISI', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 32),

                  // Profile Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF2C1810), width: 3),
                      boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(6, 6))],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        // Avatar
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF2C1810), width: 4),
                                boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4))],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(48),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      final fullName = user?.name ?? 'Teknisi';
                                      final url = user?.avatarUrl ??
                                          'https://ui-avatars.com/api/?name=${fullName.replaceAll(' ', '+')}&background=4A90D9&color=fff&size=512';
                                      _showFullScreenImage(context, url, fullName);
                                    },
                                    child: CircleAvatar(
                                      radius: 48,
                                      backgroundColor: const Color(0xFF4A90D9),
                                      backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                                      child: user?.avatarUrl == null
                                          ? Text(
                                              user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                                              style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white),
                                            )
                                          : null,
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
                                    padding: const EdgeInsets.all(6),
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
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFF2C1810),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.photo_camera_rounded,
                                            color: Color(0xFF2C1810),
                                            size: 14,
                                          ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(user?.name.toUpperCase() ?? 'TEKNISI', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A90D9).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF4A90D9), width: 1.5),
                          ),
                          child: Text('TEKNISI', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF4A90D9))),
                        ),
                        const SizedBox(height: 8),
                        Text(user?.email ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF2C1810).withValues(alpha: 0.6))),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Menu Items
                  _buildMenuItem(context, 'EDIT PROFIL', 'Ubah nama, foto, dan info', Icons.edit_rounded, const Color(0xFF4A90D9), () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                  }),
                  const SizedBox(height: 16),
                  _buildMenuItem(context, 'DAFTAR USER', 'Lihat semua user dan data motor', Icons.people_alt_rounded, const Color(0xFFE5B94C), () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const UserListScreen()));
                  }),
                  const SizedBox(height: 16),
                  _buildMenuItem(context, 'SECURITY', 'Ubah password akun', Icons.lock_rounded, const Color(0xFFF28B82), () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EditPasswordScreen()));
                  }),
                  const SizedBox(height: 16),
                  _buildMenuItem(context, 'KELUAR', 'Logout dari akun', Icons.logout_rounded, const Color(0xFFD9614C), () => _handleLogout(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, String subtitle, IconData icon, Color iconBg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2C1810), width: 3),
          boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4))],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2C1810), width: 2)),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
            Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF2C1810).withValues(alpha: 0.6))),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF2C1810)),
        ]),
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

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF4EBD0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF2C1810), width: 4)),
        title: Text('LOGOUT?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
        content: Text('Apakah Anda yakin ingin keluar?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('BATAL', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF2C1810)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD9614C), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF2C1810), width: 2))),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('KELUAR', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final navigator = Navigator.of(context);
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const PopScope(
          canPop: false,
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF2C1810)),
          ),
        ),
      );

      if (context.mounted) {
        context.read<StoryProvider>().clearData();
      }
      await context.read<AuthProvider>().signOut();
      
      try {
        navigator.pop(); // Dismiss loading dialog
      } catch (e) {
        debugPrint('Error popping loading dialog: $e');
      }
    }
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
                color: Color(0xFF4A90D9),
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: Color(0xFF4A90D9),
              ),
              title: const Text('Ambil Foto'),
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
                content: Text('Foto profil berhasil diperbarui!'),
                backgroundColor: Color(0xFF4A90D9),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  authProvider.errorMessage ?? 'Gagal memperbarui foto profil',
                ),
                backgroundColor: const Color(0xFFD9614C),
              ),
            );
          }
        }
      }
    }
  }
}
