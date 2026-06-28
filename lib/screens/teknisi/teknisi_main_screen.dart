import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/checklist_provider.dart';
import '../../models/user_model.dart';
import '../chat/chat_detail_screen.dart';
import 'teknisi_home_screen.dart';
import 'teknisi_profile_screen.dart';
import 'teknisi_checklist_screen.dart';

class TeknisiMainScreen extends StatefulWidget {
  const TeknisiMainScreen({super.key});

  @override
  State<TeknisiMainScreen> createState() => _TeknisiMainScreenState();
}

class _TeknisiMainScreenState extends State<TeknisiMainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      TeknisiHomeScreen(onTabChange: (index) {
        setState(() {
          _selectedIndex = index;
        });
      }),
      const TeknisiChecklistScreen(),
      const _ChatPlaceholder(),
      const TeknisiProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD0),
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
          IndexedStack(index: _selectedIndex, children: _screens),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final hasBadge = context.watch<ChecklistProvider>().hasNewChecklist;
    final chatHasBadge = context.watch<ChatProvider>().hasUnreadMessages;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF4EBD0),
        border: Border(top: BorderSide(color: Color(0xFF2C1810), width: 4)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, 'Home', Icons.home_rounded, _selectedIndex == 0),
          _buildNavItem(
            1,
            'Checklist',
            Icons.fact_check_rounded,
            _selectedIndex == 1,
            showBadge: hasBadge,
          ),
          _buildNavItem(
            2,
            'Chat',
            Icons.chat_bubble_rounded,
            _selectedIndex == 2,
            showBadge: chatHasBadge,
          ),
          _buildNavItem(
            3,
            'Profile',
            Icons.person_rounded,
            _selectedIndex == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon, bool isActive, {bool showBadge = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        if (index == 1) {
          context.read<ChecklistProvider>().clearNewChecklistIndicator();
        } else if (index == 2) {
          context.read<ChatProvider>().clearUnreadIndicator();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: const Color(0xFF4A90D9), // Teknisi Blue accent
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2C1810), width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF2C1810), offset: Offset(2, 2)),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : const Color(0xFF2C1810),
                  size: 24,
                ),
                if (showBadge)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9614C), // Retro Red
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF2C1810), width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                color: isActive ? Colors.white : const Color(0xFF2C1810),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ── Chat Placeholder ──
class _ChatPlaceholder extends StatefulWidget {
  const _ChatPlaceholder();

  @override
  State<_ChatPlaceholder> createState() => _ChatPlaceholderState();
}

class _ChatPlaceholderState extends State<_ChatPlaceholder> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ChatProvider>().fetchUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90D9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2C1810), width: 4),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF2C1810),
                      offset: Offset(8, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Center(
                  child: Text(
                    'CHAT DENGAN USER',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2C1810),
                        strokeWidth: 4,
                      ),
                    );
                  }

                  if (provider.errorMessage != null && provider.users.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2C1810),
                          ),
                        ),
                      ),
                    );
                  }

                  final users = provider.users;

                  if (users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF2C1810), width: 3),
                              boxShadow: const [
                                BoxShadow(color: Color(0xFF2C1810), offset: Offset(3, 3)),
                              ],
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 40,
                              color: Color(0xFF4A90D9),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'BELUM ADA USER',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF2C1810),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Belum ada user yang terdaftar.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2C1810).withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final UserModel user = users[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF2C1810), width: 3),
                          boxShadow: const [
                            BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4)),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C1810),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF2C1810), width: 1.5),
                              ),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFFF4EBD0),
                                backgroundImage: user.avatarUrl != null
                                    ? NetworkImage(user.avatarUrl!)
                                    : NetworkImage(
                                        'https://ui-avatars.com/api/?name=${user.name.replaceAll(' ', '+')}&background=4A90D9&color=fff',
                                      ) as ImageProvider,
                              ),
                            ),
                            title: Text(
                              user.name.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: const Color(0xFF2C1810),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.email_outlined, size: 12, color: Color(0xFF2C1810)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        user.email,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                          color: const Color(0xFF2C1810).withValues(alpha: 0.6),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (user.phone != null && user.phone!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone_outlined, size: 12, color: Color(0xFF2C1810)),
                                      const SizedBox(width: 4),
                                      Text(
                                        user.phone!,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                          color: const Color(0xFF2C1810).withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            trailing: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A90D9), // Teknisi Blue
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF2C1810), width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFF2C1810),
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
                                onPressed: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ChatDetailScreen(partner: user),
                                    ),
                                  );
                                  // Refresh list setelah kembali dari chat
                                  if (context.mounted) {
                                    context.read<ChatProvider>().fetchUsers();
                                  }
                                },
                              ),
                            ),
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatDetailScreen(partner: user),
                                ),
                              );
                              if (context.mounted) {
                                context.read<ChatProvider>().fetchUsers();
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
