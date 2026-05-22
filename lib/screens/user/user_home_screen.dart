import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/motorcycle_provider.dart';
import '../../providers/story_provider.dart';
import '../../widgets/stories_bar.dart';
import '../../widgets/post_card.dart';

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
    Future.microtask(() {
      if (mounted) {
        context.read<MotorcycleProvider>().fetchMotorcycles();
        context.read<StoryProvider>().fetchStories();
        context.read<StoryProvider>().fetchPosts();
      }
    });
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
            child: RefreshIndicator(
              color: const Color(0xFF2C1810),
              backgroundColor: const Color(0xFFF4EBD0),
              onRefresh: () async {
                await Future.wait([
                  context.read<StoryProvider>().fetchStories(),
                  context.read<StoryProvider>().fetchPosts(),
                  context.read<MotorcycleProvider>().fetchMotorcycles(),
                ]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4EBD0),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF2C1810),
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF2C1810),
                                  offset: Offset(3, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              'CARE U',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: const Color(0xFF2C1810),
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => widget.onTabChange?.call(3),
                            child: Container(
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
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Greeting Section
                    Text(
                      'HELLO, ${userName.toUpperCase()}!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
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

                    const SizedBox(height: 24),
                    const StoriesBar(),
                    const SizedBox(height: 24),
                    _buildPostsSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsSection() {
    final storyProvider = context.watch<StoryProvider>();
    final posts = storyProvider.posts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'FEED POSTS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2C1810),
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (posts.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2C1810), width: 3),
              boxShadow: const [
                BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4)),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.grid_off_rounded,
                    size: 48,
                    color: Color(0xFF2C1810),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada postingan feed.',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2C1810),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostCard(post: posts[index]);
            },
          ),
      ],
    );
  }
}
