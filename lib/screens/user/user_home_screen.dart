import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/motorcycle_provider.dart';

class UserHomeScreen extends StatefulWidget {
  final void Function(int)? onTabChange;
  const UserHomeScreen({super.key, this.onTabChange});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<MotorcycleProvider>().fetchMotorcycles(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final userName = user?.name.split(' ').first ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD0), // Vintage paper color
      body: Stack(
        children: [
          // Background Texture
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
                  // Custom Retro AppBar
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4EBD0),
                            border: Border.all(
                              color: const Color(0xFF2C1810),
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF2C1810),
                                offset: Offset(4, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            'CARE U',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: const Color(0xFF2C1810),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C1810),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF2C1810),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFFF4EBD0),
                            backgroundImage: user?.avatarUrl != null
                                ? NetworkImage(user!.avatarUrl!)
                                : NetworkImage(
                                    'https://ui-avatars.com/api/?name=${user?.name.replaceAll(' ', '+') ?? 'User'}&background=D9614C&color=fff',
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Greeting Section
                  Text(
                    'HELLO, ${userName.toUpperCase()}!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      color: const Color(0xFF2C1810),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5B94C), // Mustard color
                    ),
                    child: Text(
                      "LET'S KEEP YOUR RIDE IN TOP SHAPE.",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2C1810),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Motorcycle Summary Card
                  _buildMotorcycleCard(),
                  const SizedBox(height: 32),

                  // Quick Actions Grid
                  Text(
                    'QUICK ACTIONS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2C1810),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          'CHECKLIST',
                          'Inspection',
                          Icons.fact_check_rounded,
                          const Color(0xFFD9614C),
                          onTap: () => widget.onTabChange?.call(1),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          'CHAT TECH',
                          'Expert Advice',
                          Icons.chat_bubble_rounded,
                          const Color(0xFFE5B94C),
                          onTap: () => widget.onTabChange?.call(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFullWidthActionCard(),
                  const SizedBox(height: 32),

                  // Recent Status
                  _buildNotificationCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotorcycleCard() {
    return Consumer<MotorcycleProvider>(
      builder: (context, provider, child) {
        final bike = provider.motorcycles.isNotEmpty
            ? provider.motorcycles.first
            : null;
        final displayName = bike != null
            ? '${bike.brand} ${bike.model}'
            : 'NO MOTORCYCLE';

        return Container(
          width: double.infinity,
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
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF2C1810),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(17),
                    topRight: Radius.circular(17),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ACTIVE MACHINE',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFF4EBD0),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const Icon(
                      Icons.bolt_rounded,
                      color: Color(0xFFE5B94C),
                      size: 18,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2C1810),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            'MILEAGE',
                            '4,520 KM',
                            Icons.speed_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoItem(
                            'HEALTH',
                            '92%',
                            Icons.favorite_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EBD0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C1810), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF2C1810)),
              const SizedBox(width: 6),
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
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2C1810),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color primaryColor, {
    VoidCallback? onTap,
  }) {
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor,
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
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2C1810).withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullWidthActionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EBD0), // Vintage Paper
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2C1810), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0xFF2C1810), offset: Offset(6, 6)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5B94C),
                  border: Border.all(color: const Color(0xFF2C1810), width: 2),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Color(0xFF2C1810),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VIEW EDUCATION',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2C1810),
                    ),
                  ),
                  Text(
                    'LEARN DIY MAINTENANCE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2C1810).withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.arrow_forward_rounded, color: Color(0xFF2C1810)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0E0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C1810), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0xFFD9614C), offset: Offset(4, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.notification_important_rounded,
            color: Color(0xFF2C1810),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SERVICE DUE SOON',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2C1810),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'YOUR SCHEDULED OIL CHANGE IS DUE IN 5 DAYS. TAP TO BOOK.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C1810),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
