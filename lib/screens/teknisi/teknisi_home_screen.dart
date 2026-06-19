import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/story_provider.dart';
import '../../models/user_model.dart';
import '../story/create_story_screen.dart';
import '../story/create_post_screen.dart';
import '../story/create_reel_screen.dart';
import '../../widgets/stories_bar.dart';
import '../../widgets/reels_bar.dart';
import '../../widgets/post_card.dart';

class TeknisiHomeScreen extends StatefulWidget {
  final void Function(int)? onTabChange;
  const TeknisiHomeScreen({super.key, this.onTabChange});

  @override
  State<TeknisiHomeScreen> createState() => _TeknisiHomeScreenState();
}

class _TeknisiHomeScreenState extends State<TeknisiHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<StoryProvider>().fetchStories();
        context.read<StoryProvider>().fetchPosts();
      }
    });
  }

  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF4EBD0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Color(0xFF2C1810), width: 3),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'BUAT KONTEN BARU',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: const Color(0xFF2C1810),
                  letterSpacing: 1,
                ),
              ),
            ),
            const Divider(color: Color(0xFF2C1810), height: 1, thickness: 2),
            ListTile(
              leading: const Icon(Icons.slow_motion_video_rounded, color: Color(0xFF2C1810)),
              title: Text('UPLOAD STORY', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF2C1810))),
              onTap: () {
                final storyProvider = context.read<StoryProvider>();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateStoryScreen()),
                ).then((_) {
                  storyProvider.fetchStories();
                });
              },
            ),
            const Divider(color: Color(0xFF2C1810), height: 1),
            ListTile(
              leading: const Icon(Icons.grid_on_rounded, color: Color(0xFF2C1810)),
              title: Text('UPLOAD POST', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF2C1810))),
              onTap: () {
                final storyProvider = context.read<StoryProvider>();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                ).then((_) {
                  storyProvider.fetchPosts();
                });
              },
            ),
            const Divider(color: Color(0xFF2C1810), height: 1),
            ListTile(
              leading: const Icon(Icons.video_library_rounded, color: Color(0xFF2C1810)),
              title: Text('UPLOAD REELS', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF2C1810))),
              onTap: () {
                final storyProvider = context.read<StoryProvider>();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateReelScreen()),
                ).then((_) {
                  storyProvider.fetchPosts();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

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
                await Future.wait([
                  context.read<StoryProvider>().fetchStories(),
                  context.read<StoryProvider>().fetchPosts(),
                ]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppBar(user),
                    const SizedBox(height: 16),
                    _buildGreeting(userName),
                    const SizedBox(height: 24),
                    const StoriesBar(),
                    const SizedBox(height: 24),
                    const ReelsBar(),
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

  Widget _buildAppBar(UserModel? user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90D9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2C1810), width: 2),
              boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(3, 3))],
            ),
            child: Text('CARE U', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white, letterSpacing: 1)),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: _showCreateOptions,
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
                  color: const Color(0xFF4A90D9).withOpacity(0.15),
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
              const SizedBox(width: 12),
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
                            'https://ui-avatars.com/api/?name=${user?.name.replaceAll(' ', '+') ?? 'Teknisi'}&background=4A90D9&color=fff',
                          ) as ImageProvider,
                  ),
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
        Text('HELLO, ${name.toUpperCase()}!', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w900, height: 1.1, color: const Color(0xFF2C1810))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: const BoxDecoration(color: Color(0xFF4A90D9)),
          child: Text('MONITOR & MAINTAIN USER MOTORCYCLES.', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
        ),
      ],
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
              boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4))],
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.grid_off_rounded, size: 48, color: Color(0xFF2C1810)),
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
