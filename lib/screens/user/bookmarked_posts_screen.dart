import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/story_provider.dart';
import '../../widgets/post_card.dart';
import '../../widgets/video_thumbnail_widget.dart';
import '../story/reels_viewer_screen.dart';

class BookmarkedPostsScreen extends StatefulWidget {
  const BookmarkedPostsScreen({super.key});

  @override
  State<BookmarkedPostsScreen> createState() => _BookmarkedPostsScreenState();
}

class _BookmarkedPostsScreenState extends State<BookmarkedPostsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<StoryProvider>().fetchBookmarkedPosts();
      }
    });
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2C1810), width: 3),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF2C1810), offset: Offset(3, 3)),
                ],
              ),
              child: Icon(
                icon,
                size: 48,
                color: const Color(0xFF2C1810),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2C1810),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C1810).withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();
    final bookmarked = storyProvider.bookmarkedPosts;

    final posts = bookmarked.where((s) => s.isPost && !s.isReel).toList();
    final reels = bookmarked.where((s) => s.isReel).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4EBD0), // Vintage Paper
        appBar: AppBar(
          backgroundColor: const Color(0xFFF4EBD0),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF2C1810)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'POSTINGAN TERSIMPAN',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: const Color(0xFF2C1810),
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Column(
              children: [
                Container(color: const Color(0xFF2C1810), height: 2),
                TabBar(
                  labelColor: const Color(0xFF2C1810),
                  unselectedLabelColor: const Color(0xFF2C1810).withValues(alpha: 0.5),
                  indicatorColor: const Color(0xFFE5B94C), // Gold indicator
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 4,
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                  unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                  tabs: const [
                    Tab(text: 'POSTS'),
                    Tab(text: 'REELS'),
                  ],
                ),
                Container(color: const Color(0xFF2C1810), height: 2),
              ],
            ),
          ),
        ),
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
            TabBarView(
              children: [
                // TAB 1: POSTS
                RefreshIndicator(
                  color: const Color(0xFF2C1810),
                  backgroundColor: const Color(0xFFE5B94C),
                  onRefresh: () => context.read<StoryProvider>().fetchBookmarkedPosts(),
                  child: storyProvider.isLoading && posts.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2C1810),
                            strokeWidth: 4,
                          ),
                        )
                      : posts.isEmpty
                          ? _buildEmptyState(
                              icon: Icons.bookmark_border_rounded,
                              title: 'BELUM ADA POSTINGAN TERSIMPAN',
                              subtitle: 'Postingan yang Anda simpan akan muncul di sini agar mudah dibaca kembali.',
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(24),
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                return PostCard(post: posts[index]);
                              },
                            ),
                ),

                // TAB 2: REELS
                RefreshIndicator(
                  color: const Color(0xFF2C1810),
                  backgroundColor: const Color(0xFFE5B94C),
                  onRefresh: () => context.read<StoryProvider>().fetchBookmarkedPosts(),
                  child: storyProvider.isLoading && reels.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2C1810),
                            strokeWidth: 4,
                          ),
                        )
                      : reels.isEmpty
                          ? _buildEmptyState(
                              icon: Icons.video_library_outlined,
                              title: 'BELUM ADA REELS TERSIMPAN',
                              subtitle: 'Video reels yang Anda simpan akan muncul di sini agar mudah ditonton kembali.',
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(24),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: reels.length,
                              itemBuilder: (context, index) {
                                final reel = reels[index];
                                return GestureDetector(
                                  onTap: () {
                                    final provider = context.read<StoryProvider>();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ReelsViewerScreen(
                                          reels: reels,
                                          initialIndex: index,
                                        ),
                                      ),
                                    ).then((_) {
                                      if (mounted) {
                                        provider.fetchBookmarkedPosts();
                                      }
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5B94C), // Gold
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFF2C1810), width: 3),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0xFF2C1810),
                                          offset: Offset(4, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: VideoThumbnailWidget(videoUrl: reel.mediaUrl),
                                          ),
                                          Positioned.fill(
                                            child: Opacity(
                                              opacity: 0.15,
                                              child: Image.network(
                                                'https://www.transparenttextures.com/patterns/pinstriped-suit.png',
                                                repeat: ImageRepeat.repeat,
                                              ),
                                            ),
                                          ),
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black.withValues(alpha: 0.6),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Center(
                                            child: CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Color(0xFFF4EBD0),
                                              child: Icon(
                                                Icons.play_arrow_rounded,
                                                color: Color(0xFF2C1810),
                                                size: 28,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF4EBD0),
                                                shape: BoxShape.circle,
                                                border: Border.all(color: const Color(0xFF2C1810), width: 1.5),
                                              ),
                                              child: const Icon(
                                                Icons.bookmark_rounded,
                                                size: 14,
                                                color: Color(0xFF2C1810),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 8,
                                            left: 8,
                                            right: 8,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  reel.userName ?? 'Teknisi',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  reel.caption ?? '',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.white.withValues(alpha: 0.9),
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
