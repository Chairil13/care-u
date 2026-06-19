import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../screens/story/reels_viewer_screen.dart';
import 'video_thumbnail_widget.dart';

class ReelsBar extends StatelessWidget {
  const ReelsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();
    final reels = storyProvider.reels;

    if (reels.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'LATEST REELS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2C1810),
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
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
                    provider.fetchPosts();
                  });
                },
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 14, bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5B94C), // Gold base
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2C1810), width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF2C1810),
                        offset: Offset(3, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // Video Thumbnail in background
                        Positioned.fill(
                          child: VideoThumbnailWidget(videoUrl: reel.mediaUrl),
                        ),
                        // Texture overlay
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.15,
                            child: Image.network(
                              'https://www.transparenttextures.com/patterns/pinstriped-suit.png',
                              repeat: ImageRepeat.repeat,
                            ),
                          ),
                        ),
                        // Bottom shadow gradient for readability
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
                        // Play Icon
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
                        // Avatar Top Left
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF2C1810), width: 1.5),
                            ),
                            child: CircleAvatar(
                              radius: 12,
                              backgroundImage: reel.userAvatarUrl != null
                                  ? NetworkImage(reel.userAvatarUrl!)
                                  : NetworkImage('https://ui-avatars.com/api/?name=${(reel.userName ?? 'Teknisi').replaceAll(' ', '+')}&background=4A90D9&color=fff') as ImageProvider,
                            ),
                          ),
                        ),
                        // Creator Details Bottom Left
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
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                reel.caption ?? '',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 8.5,
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
        const SizedBox(height: 16),
      ],
    );
  }
}
