import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../user/edit_profile_screen.dart';

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
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF2C1810), width: 4),
                            boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4))],
                          ),
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
                  _buildMenuItem(context, 'BANTUAN', 'FAQ dan panduan aplikasi', Icons.help_outline_rounded, const Color(0xFFE5B94C), () {}),
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
      await context.read<AuthProvider>().signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
      }
    }
  }
}
