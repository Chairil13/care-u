import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/story_provider.dart';
import '../story/create_story_screen.dart';
import '../../widgets/stories_bar.dart';

class TeknisiHomeScreen extends StatefulWidget {
  const TeknisiHomeScreen({super.key});

  @override
  State<TeknisiHomeScreen> createState() => _TeknisiHomeScreenState();
}

class _TeknisiHomeScreenState extends State<TeknisiHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
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
            child: RefreshIndicator(
              color: const Color(0xFF4A90D9), // Teknisi Blue
              backgroundColor: const Color(0xFFF4EBD0),
              onRefresh: () async {
                await context.read<StoryProvider>().fetchStories();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppBar(),
                    const SizedBox(height: 16),
                    _buildGreeting(userName),
                    const SizedBox(height: 24),
                    const StoriesBar(),
                  ],
                ),
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
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateStoryScreen()),
                  ).then((_) {
                    if (!mounted) return;
                    context.read<StoryProvider>().fetchStories();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5B94C),
                    border: Border.all(color: const Color(0xFF2C1810), width: 2),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF2C1810),
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Color(0xFF2C1810),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
}
