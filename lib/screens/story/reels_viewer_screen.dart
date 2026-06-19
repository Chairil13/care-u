import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../models/story_model.dart';
import '../../models/comment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/story_provider.dart';
import '../story/story_view_screen.dart';

class ReelsViewerScreen extends StatefulWidget {
  final List<StoryModel> reels;
  final int initialIndex;

  const ReelsViewerScreen({
    super.key,
    required this.reels,
    this.initialIndex = 0,
  });

  @override
  State<ReelsViewerScreen> createState() => _ReelsViewerScreenState();
}

class _ReelsViewerScreenState extends State<ReelsViewerScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reels.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF2C1810),
        body: Center(
          child: Text(
            'Tidak ada Reels.',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: widget.reels.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final reel = widget.reels[index];
              return ReelPageItem(
                reel: reel,
                isCurrent: index == _currentIndex,
              );
            },
          ),
          // Close button at top left
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5B94C), // Gold
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2C1810), width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF2C1810),
                      offset: Offset(2.5, 2.5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF2C1810),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReelPageItem extends StatefulWidget {
  final StoryModel reel;
  final bool isCurrent;

  const ReelPageItem({
    super.key,
    required this.reel,
    required this.isCurrent,
  });

  @override
  State<ReelPageItem> createState() => _ReelPageItemState();
}

class _ReelPageItemState extends State<ReelPageItem> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;
  bool _showPlayIcon = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.reel.mediaUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
          });
          _controller.setLooping(true);
          if (widget.isCurrent) {
            _controller.play();
          }
        }
      }).catchError((error) {
        debugPrint('Error initializing video reel: $error');
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });
  }

  @override
  void didUpdateWidget(covariant ReelPageItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrent != oldWidget.isCurrent) {
      if (widget.isCurrent) {
        _controller.play();
      } else {
        _controller.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_initialized) return;
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _showPlayIcon = true;
      } else {
        _controller.play();
        _showPlayIcon = true;
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              _showPlayIcon = false;
            });
          }
        });
      }
    });
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReelCommentsSheet(
        storyId: widget.reel.id,
        postOwnerId: widget.reel.userId,
      ),
    );
  }

  void _showReelMenu() {
    final storyProvider = context.read<StoryProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF4EBD0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Color(0xFF2C1810), width: 3),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: Color(0xFF4A90D9)),
              title: Text('EDIT REEL', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
              onTap: () {
                Navigator.pop(ctx);
                _showEditReelDialog();
              },
            ),
            const Divider(color: Color(0xFF2C1810), height: 1),
            ListTile(
              leading: const Icon(Icons.delete_forever_rounded, color: Color(0xFFD9614C)),
              title: Text('HAPUS REEL', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: const Color(0xFFD9614C))),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteReelConfirmDialog(storyProvider);
              },
            ),
            const Divider(color: Color(0xFF2C1810), height: 1),
            ListTile(
              leading: const Icon(Icons.close_rounded, color: Color(0xFF2C1810)),
              title: Text('BATAL', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditReelDialog() {
    final controller = TextEditingController(text: widget.reel.caption ?? '');
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFFF4EBD0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF2C1810), width: 3)),
        title: Text('EDIT CAPTION REEL', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
        content: TextField(
          controller: controller,
          maxLines: 5,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF2C1810)),
          decoration: InputDecoration(
            hintText: 'Tulis caption baru...',
            hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF2C1810).withValues(alpha: 0.4)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2C1810), width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5B94C), width: 2)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text('BATAL', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE5B94C), foregroundColor: const Color(0xFF2C1810), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFF2C1810), width: 2))),
            onPressed: () async {
              final newCaption = controller.text.trim();
              Navigator.pop(dialogCtx);
              final success = await context.read<StoryProvider>().updatePostCaption(widget.reel.id, newCaption);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success ? 'Caption berhasil diubah!' : 'Gagal mengubah caption'),
                  backgroundColor: success ? const Color(0xFF4A90D9) : const Color(0xFFD9614C),
                ));
              }
            },
            child: Text('SIMPAN', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showDeleteReelConfirmDialog(StoryProvider storyProvider) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFFF4EBD0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF2C1810), width: 3)),
        title: Text('HAPUS REEL', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
        content: Text('Apakah Anda yakin ingin menghapus reel ini secara permanen?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF2C1810))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text('BATAL', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD9614C), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFF2C1810), width: 2))),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await storyProvider.deleteStory(widget.reel.id, widget.reel.mediaUrl);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success ? 'Reel berhasil dihapus' : storyProvider.errorMessage ?? 'Gagal menghapus reel'),
                  backgroundColor: success ? const Color(0xFF4A90D9) : const Color(0xFFD9614C),
                ));
                if (success) {
                  Navigator.pop(context);
                }
              }
            },
            child: Text('HAPUS', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildSideButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF4EBD0), // Vintage paper
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2C1810), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF2C1810),
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            shadows: [
              const Shadow(
                color: Color(0xFF2C1810),
                offset: Offset(1.5, 1.5),
                blurRadius: 2.0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();
    final currentUser = context.watch<AuthProvider>().currentUser;
    final isOwner = currentUser != null && currentUser.id == widget.reel.userId;
    final activeStories = storyProvider.stories.where((s) => s.userId == widget.reel.userId).toList();
    final allStoriesViewed = activeStories.isNotEmpty && activeStories.every((story) => storyProvider.viewedStoryIds.contains(story.id));
    final isLiked = storyProvider.isLikedByMe(widget.reel.id);
    final likeCount = storyProvider.getLikeCount(widget.reel.id);
    final commentCount = storyProvider.getCommentCount(widget.reel.id);
    final isBookmarked = storyProvider.isBookmarked(widget.reel.id);

    final String roleText;
    final Color roleBgColor;
    final String roleHex;
    if (widget.reel.userRole == 'admin') {
      roleText = 'ADMIN';
      roleBgColor = const Color(0xFFE5B94C); // Gold
      roleHex = 'E5B94C';
    } else if (widget.reel.userRole == 'teknisi') {
      roleText = 'TEKNISI';
      roleBgColor = const Color(0xFF4A90D9); // Blue
      roleHex = '4A90D9';
    } else {
      roleText = 'USER';
      roleBgColor = const Color(0xFFD9614C); // Coral
      roleHex = 'D9614C';
    }

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Video Player Core
          Positioned.fill(
            child: _hasError
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.broken_image_rounded, color: Color(0xFFD9614C), size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Gagal memuat video',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                : !_initialized
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFFE5B94C)),
                      )
                    : GestureDetector(
                        onTap: _togglePlay,
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      ),
          ),

          // Play icon indicator on tap
          if (_showPlayIcon && _initialized)
            Center(
              child: AnimatedOpacity(
                opacity: _showPlayIcon ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.black54,
                  child: Icon(
                    _controller.value.isPlaying
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),

          // Bottom vignette gradient shadow overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // Action Sidebar Buttons (Right Side)
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              spacing: 20,
              children: [
                _buildSideButton(
                  icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  iconColor: isLiked ? const Color(0xFFD9614C) : const Color(0xFF2C1810),
                  label: '$likeCount',
                  onTap: () => storyProvider.toggleLike(widget.reel.id),
                ),
                _buildSideButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  iconColor: const Color(0xFF2C1810),
                  label: '$commentCount',
                  onTap: _showComments,
                ),
                _buildSideButton(
                  icon: isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  iconColor: const Color(0xFF2C1810),
                  label: isBookmarked ? 'Simpan' : 'Simpan',
                  onTap: () => storyProvider.toggleBookmark(widget.reel.id),
                ),
              ],
            ),
          ),

          // Details Overlay (Creator & Caption Bottom Left)
          Positioned(
            left: 16,
            bottom: 32,
            right: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // User info row
                Row(
                  children: [
                    GestureDetector(
                      onTap: activeStories.isNotEmpty
                          ? () {
                              _controller.pause();
                              final provider = context.read<StoryProvider>();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StoryViewScreen(
                                    stories: activeStories.reversed.toList(),
                                    initialIndex: 0,
                                  ),
                                ),
                              ).then((_) {
                                provider.fetchStories();
                                if (widget.isCurrent) {
                                  _controller.play();
                                }
                              });
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: activeStories.isNotEmpty
                                ? (allStoriesViewed ? Colors.grey : const Color(0xFFE5B94C))
                                : const Color(0xFF2C1810),
                            width: activeStories.isNotEmpty ? 2.5 : 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFFF4EBD0),
                          backgroundImage: widget.reel.userAvatarUrl != null
                              ? NetworkImage(widget.reel.userAvatarUrl!)
                              : NetworkImage('https://ui-avatars.com/api/?name=${(widget.reel.userName ?? roleText).replaceAll(' ', '+')}&background=$roleHex&color=fff'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.reel.userName ?? 'Teknisi',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: Colors.white,
                                    shadows: [
                                      const Shadow(
                                        color: Color(0xFF2C1810),
                                        offset: Offset(1.5, 1.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: roleBgColor.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF2C1810), width: 1.5),
                                ),
                                child: Text(
                                  roleText,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Caption
                Text(
                  widget.reel.caption ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Colors.white,
                    shadows: [
                      const Shadow(
                        color: Color(0xFF2C1810),
                        offset: Offset(1.5, 1.5),
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu button at top right
          if (isOwner)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              right: 16,
              child: GestureDetector(
                onTap: _showReelMenu,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5B94C), // Gold
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2C1810), width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF2C1810),
                        offset: Offset(2.5, 2.5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.more_vert_rounded,
                    color: Color(0xFF2C1810),
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ===== Comments Bottom Sheet for Reels =====
class ReelCommentsSheet extends StatefulWidget {
  final String storyId;
  final String postOwnerId;

  const ReelCommentsSheet({
    super.key,
    required this.storyId,
    required this.postOwnerId,
  });

  @override
  State<ReelCommentsSheet> createState() => _ReelCommentsSheetState();
}

class _ReelCommentsSheetState extends State<ReelCommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<CommentModel>? _comments;
  bool _isSending = false;
  String? _replyToId;
  String? _replyToName;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final comments = await context.read<StoryProvider>().fetchComments(widget.storyId);
    if (mounted) setState(() => _comments = comments);
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSending = true);
    _commentController.clear();
    final success = await context.read<StoryProvider>().addComment(
          widget.storyId,
          text,
          parentId: _replyToId,
        );
    if (success) await _loadComments();
    if (mounted) {
      setState(() {
        _isSending = false;
        _replyToId = null;
        _replyToName = null;
      });
    }
  }

  void _setReplyTo(CommentModel comment) {
    setState(() {
      _replyToId = comment.parentId ?? comment.id;
      _replyToName = comment.userName ?? 'User';
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyToId = null;
      _replyToName = null;
    });
  }

  Future<void> _editComment(CommentModel comment) async {
    final controller = TextEditingController(text: comment.content);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF4EBD0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF2C1810), width: 3)),
        title: Text(
          'EDIT KOMENTAR',
          style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900, color: const Color(0xFF2C1810)),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700, color: const Color(0xFF2C1810)),
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2C1810), width: 2)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5B94C), width: 2)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('BATAL',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900, color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5B94C),
                foregroundColor: const Color(0xFF2C1810),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFF2C1810), width: 2))),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text('SIMPAN',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      if (mounted) {
        await context.read<StoryProvider>().editComment(comment.id, result);
        await _loadComments();
      }
    }
  }

  Future<void> _deleteComment(CommentModel comment) async {
    final childCount = _comments?.where((c) => c.parentId == comment.id).length ?? 0;
    final success = await context
        .read<StoryProvider>()
        .deleteComment(comment.id, widget.storyId, childCount: childCount);
    if (success) await _loadComments();
  }

  void _showCommentOptions(CommentModel comment, bool isMyComment) {
    final currentUserId = context.read<AuthProvider>().currentUser?.id;
    final isPostOwner = currentUserId != null && currentUserId == widget.postOwnerId;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF4EBD0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          side: BorderSide(color: Color(0xFF2C1810), width: 3)),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply_rounded, color: Color(0xFF4A90D9)),
              title: Text(
                'BALAS',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900, color: const Color(0xFF2C1810)),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _setReplyTo(comment);
              },
            ),
            if (isMyComment) ...[
              const Divider(color: Color(0xFF2C1810), height: 1),
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: Color(0xFFE5B94C)),
                title: Text(
                  'EDIT',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900, color: const Color(0xFF2C1810)),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _editComment(comment);
                },
              ),
            ],
            if (isMyComment || isPostOwner) ...[
              const Divider(color: Color(0xFF2C1810), height: 1),
              ListTile(
                leading: const Icon(Icons.delete_forever_rounded, color: Color(0xFFD9614C)),
                title: Text(
                  'HAPUS',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900, color: const Color(0xFFD9614C)),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteComment(comment);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}j';
    return '${diff.inDays}h';
  }

  Widget _buildCommentTile(CommentModel c, bool isReply) {
    final currentUserId = context.read<AuthProvider>().currentUser?.id;
    final isMyComment = currentUserId == c.userId;
    final isPostOwner = c.userId == widget.postOwnerId;
    final storyProvider = context.read<StoryProvider>();
    final activeStories = storyProvider.stories.where((s) => s.userId == c.userId).toList();
    final hasStories = activeStories.isNotEmpty;
    final allStoriesViewed =
        hasStories && activeStories.every((story) => storyProvider.viewedStoryIds.contains(story.id));

    return GestureDetector(
      onLongPress: () => _showCommentOptions(c, isMyComment),
      onTap: () => _setReplyTo(c),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.only(left: isReply ? 52.0 : 16.0, right: 16, top: 8, bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: hasStories
                  ? () {
                      final provider = context.read<StoryProvider>();
                      final orderedStories = activeStories.reversed.toList();
                      final initialIndex = orderedStories.indexWhere(
                        (story) => !provider.viewedStoryIds.contains(story.id),
                      );
                      final startIdx = initialIndex != -1 ? initialIndex : 0;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StoryViewScreen(
                            stories: orderedStories,
                            initialIndex: startIdx,
                          ),
                        ),
                      ).then((_) {
                        provider.fetchStories();
                      });
                    }
                  : null,
              child: Container(
                padding: EdgeInsets.all(hasStories ? 1.5 : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: hasStories
                      ? Border.all(
                          color: allStoriesViewed ? Colors.grey : const Color(0xFFE5B94C), width: 2)
                      : null,
                ),
                child: CircleAvatar(
                  radius: isReply ? 14 : 18,
                  backgroundColor: const Color(0xFFE5B94C),
                  backgroundImage: c.userAvatarUrl != null ? NetworkImage(c.userAvatarUrl!) : null,
                  child: c.userAvatarUrl == null
                      ? Text(
                          c.userName?.isNotEmpty == true ? c.userName![0].toUpperCase() : '?',
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              fontSize: isReply ? 10 : 12,
                              color: const Color(0xFF2C1810)),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(c.userName ?? 'User',
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: const Color(0xFF2C1810))),
                      if (isPostOwner) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                              color: const Color(0xFFE5B94C),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF2C1810), width: 1)),
                          child: Text('PEMBUAT',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF2C1810))),
                        ),
                      ],
                      const SizedBox(width: 6),
                      Text(_formatTime(c.createdAt),
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2C1810).withValues(alpha: 0.4))),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(c.content,
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                          color: const Color(0xFF2C1810))),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _setReplyTo(c),
                    child: Text('Balas',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            color: const Color(0xFF2C1810).withValues(alpha: 0.5))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<StoryProvider>();

    final roots = _comments?.where((c) => c.parentId == null).toList() ?? [];
    final replies = _comments?.where((c) => c.parentId != null).toList() ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF4EBD0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Color(0xFF2C1810), width: 3),
            left: BorderSide(color: Color(0xFF2C1810), width: 3),
            right: BorderSide(color: Color(0xFF2C1810), width: 3),
          ),
        ),
        child: Column(
          children: [
            Center(
                child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 4),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                        color: const Color(0xFF2C1810).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2)))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_rounded, color: Color(0xFF2C1810), size: 22),
                  const SizedBox(width: 10),
                  Text('KOMENTAR REELS',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF2C1810))),
                ],
              ),
            ),
            const Divider(color: Color(0xFF2C1810), thickness: 3, height: 3),
            Expanded(
              child: _comments == null
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF2C1810)))
                  : _comments!.isEmpty
                      ? Center(
                          child: Text('Belum ada komentar',
                              style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF2C1810).withValues(alpha: 0.5))))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: roots.length,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (context, index) {
                            final root = roots[index];
                            final children = replies.where((r) => r.parentId == root.id).toList();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCommentTile(root, false),
                                ...children.map((child) => _buildCommentTile(child, true)),
                              ],
                            );
                          },
                        ),
            ),
            if (_replyToName != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: const Color(0xFF2C1810).withValues(alpha: 0.08),
                child: Row(
                  children: [
                    Text('Membalas ',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2C1810).withValues(alpha: 0.6))),
                    Text(_replyToName!,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2C1810))),
                    const Spacer(),
                    GestureDetector(
                        onTap: _cancelReply,
                        child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF2C1810))),
                  ],
                ),
              ),
            Container(
              padding: EdgeInsets.only(
                  left: 16,
                  right: 8,
                  top: 8,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 8),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFF2C1810), width: 2))),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        focusNode: _focusNode,
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: const Color(0xFF2C1810)),
                        decoration: InputDecoration(
                          hintText:
                              _replyToName != null ? 'Balas $_replyToName...' : 'Tulis komentar...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF2C1810).withValues(alpha: 0.4),
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _submitComment(),
                      ),
                    ),
                    _isSending
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Color(0xFF2C1810))))
                        : IconButton(
                            icon: const Icon(Icons.send_rounded, color: Color(0xFFE5B94C)),
                            onPressed: _submitComment),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
