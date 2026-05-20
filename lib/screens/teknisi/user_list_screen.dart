import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/teknisi_provider.dart';
import '../../models/user_model.dart';
import 'user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TeknisiProvider>().fetchAllUsersWithMotorcycles());
  }

  List<UserModel> get _filteredUsers {
    final users = context.read<TeknisiProvider>().users;
    if (_searchQuery.isEmpty) return users;
    return users.where((u) =>
      u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      u.email.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TeknisiProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD0),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.network('https://www.transparenttextures.com/patterns/carbon-fibre.png', repeat: ImageRepeat.repeat),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2C1810), width: 3),
                            boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(3, 3))],
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2C1810)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A90D9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF2C1810), width: 3),
                            boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4))],
                          ),
                          child: Text('DAFTAR USER', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 1)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2C1810), width: 3),
                      boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(3, 3))],
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF2C1810)),
                      decoration: InputDecoration(
                        hintText: 'Cari user...',
                        hintStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF2C1810).withValues(alpha: 0.4)),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2C1810)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // User Count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFE5B94C), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF2C1810), width: 2)),
                        child: Text('${_filteredUsers.length} USER', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // User List
                Expanded(
                  child: tp.isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF2C1810)))
                      : _filteredUsers.isEmpty
                          ? Center(child: Text('Tidak ada user ditemukan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF2C1810).withValues(alpha: 0.5))))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filteredUsers.length,
                              itemBuilder: (context, index) => _buildUserCard(_filteredUsers[index], tp),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user, TeknisiProvider tp) {
    final motors = tp.getMotorcyclesForUser(user.id);
    final motorText = motors.isNotEmpty ? motors.map((m) => '${m.brand} ${m.model}').join(', ') : 'Belum ada motor';

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserDetailScreen(user: user))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2C1810), width: 3),
          boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4))],
        ),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF2C1810),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(17), topRight: Radius.circular(17)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFE5B94C),
                    backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                    child: user.avatarUrl == null
                        ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 14, color: const Color(0xFF2C1810)))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFFF4EBD0))),
                        Text(user.email, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFF4EBD0).withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFF4EBD0), size: 16),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90D9).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.two_wheeler_rounded, size: 20, color: Color(0xFF4A90D9)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MOTOR', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810).withValues(alpha: 0.5))),
                        Text(motorText.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF2C1810))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5B94C),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2C1810), width: 1.5),
                    ),
                    child: Text('${motors.length}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
