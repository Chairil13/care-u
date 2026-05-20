import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/teknisi_provider.dart';
import 'user_list_screen.dart';

class TeknisiHomeScreen extends StatefulWidget {
  const TeknisiHomeScreen({super.key});

  @override
  State<TeknisiHomeScreen> createState() => _TeknisiHomeScreenState();
}

class _TeknisiHomeScreenState extends State<TeknisiHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<TeknisiProvider>().fetchAllUsersWithMotorcycles(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final tp = context.watch<TeknisiProvider>();
    final userName = user?.name.split(' ').first ?? 'Teknisi';

    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD0),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/pinstriped-suit.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(),
                  const SizedBox(height: 16),
                  _buildGreeting(userName),
                  const SizedBox(height: 32),
                  _buildStatsRow(tp),
                  const SizedBox(height: 32),
                  _buildQuickActions(context),
                  const SizedBox(height: 32),
                  _buildRecentUsers(tp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90D9),
              border: Border.all(color: const Color(0xFF2C1810), width: 2),
              boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4))],
            ),
            child: Text('CARE U', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: 1)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90D9).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF4A90D9), width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.engineering_rounded, size: 16, color: Color(0xFF4A90D9)),
                const SizedBox(width: 4),
                Text('TEKNISI', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF4A90D9))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('HELLO, ${name.toUpperCase()}!', style: GoogleFonts.plusJakartaSans(fontSize: 40, fontWeight: FontWeight.w900, height: 1, color: const Color(0xFF2C1810))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: const BoxDecoration(color: Color(0xFF4A90D9)),
          child: Text('MONITOR & MAINTAIN USER MOTORCYCLES.', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildStatsRow(TeknisiProvider tp) {
    return Row(
      children: [
        Expanded(child: _statCard('TOTAL USER', tp.totalUsers.toString(), Icons.people_alt_rounded, const Color(0xFFE5B94C))),
        const SizedBox(width: 16),
        Expanded(child: _statCard('TOTAL MOTOR', tp.totalMotorcycles.toString(), Icons.two_wheeler_rounded, Colors.white)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2C1810), width: 3), boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2C1810), size: 28),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF2C1810), letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('QUICK ACTIONS', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserListScreen())),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF2C1810), width: 3), boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(6, 6))]),
            child: Row(
              children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF4A90D9), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2C1810), width: 2)), child: const Icon(Icons.people_alt_rounded, color: Colors.white)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DAFTAR USER', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
                      Text('Lihat semua user dan data motor', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF2C1810).withValues(alpha: 0.6))),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Color(0xFF2C1810)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _smallAction('CHECKLIST', 'Buat Form', Icons.fact_check_rounded, const Color(0xFFD9614C))),
            const SizedBox(width: 16),
            Expanded(child: _smallAction('EDUKASI', 'Buat Postingan', Icons.school_rounded, const Color(0xFFE5B94C))),
          ],
        ),
      ],
    );
  }

  Widget _smallAction(String title, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2C1810), width: 3), boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2C1810), width: 2)), child: Icon(icon, color: const Color(0xFF2C1810), size: 20)),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
          Text(sub, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, color: const Color(0xFF2C1810).withValues(alpha: 0.6))),
        ],
      ),
    );
  }

  Widget _buildRecentUsers(TeknisiProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('USERS TERBARU', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
        const SizedBox(height: 16),
        if (provider.users.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2C1810), width: 3), boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4))]),
            child: Column(children: [
              const Icon(Icons.inbox_rounded, size: 40, color: Color(0xFF2C1810)),
              const SizedBox(height: 8),
              Text('Belum ada user terdaftar', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF2C1810).withValues(alpha: 0.6))),
            ]),
          )
        else
          ...provider.users.take(3).map((user) {
            final motors = provider.getMotorcyclesForUser(user.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2C1810), width: 2), boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(3, 3))]),
                child: Row(children: [
                  CircleAvatar(
                    radius: 20, backgroundColor: const Color(0xFFE5B94C),
                    backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                    child: user.avatarUrl == null ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user.name.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
                    Text('${motors.length} motor', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF2C1810).withValues(alpha: 0.6))),
                  ])),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: const Color(0xFF4A90D9).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF4A90D9)),
                  ),
                ]),
              ),
            );
          }),
      ],
    );
  }
}
