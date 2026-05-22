import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/story_model.dart';
import '../models/comment_model.dart';
import '../providers/auth_provider.dart';
import '../providers/story_provider.dart';
import '../screens/story/story_view_screen.dart';

class PostCard extends StatefulWidget {
  final StoryModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showHeartOverlay = false;
  double _aspectRatio = 1.0;

  @override
  void initState() {
    super.initState();
    _loadFirstImageAspectRatio();
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id) {
      _loadFirstImageAspectRatio();
    }
  }

  void _loadFirstImageAspectRatio() {
    final images = widget.post.postImages;
    if (images.isEmpty) return;
    
    final imageUrl = images.first;
    final Image image = Image.network(imageUrl);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          if (mounted) {
            setState(() {
              _aspectRatio = info.image.width / info.image.height;
              if (_aspectRatio < 0.8) _aspectRatio = 0.8;
              if (_aspectRatio > 1.91) _aspectRatio = 1.91;
            });
          }
        },
        onError: (exception, stackTrace) {
          // ignore or keep default 1.0
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    final storyProvider = context.read<StoryProvider>();
    if (!storyProvider.isLikedByMe(widget.post.id)) {
      storyProvider.toggleLike(widget.post.id);
    }
    setState(() => _showHeartOverlay = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showHeartOverlay = false);
    });
  }

  void _toggleLike() {
    context.read<StoryProvider>().toggleLike(widget.post.id);
  }

  void _showPostMenu() {
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
              title: Text('EDIT POSTINGAN', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
              onTap: () {
                Navigator.pop(ctx);
                _showEditDialog();
              },
            ),
            const Divider(color: Color(0xFF2C1810), height: 1),
            ListTile(
              leading: const Icon(Icons.delete_forever_rounded, color: Color(0xFFD9614C)),
              title: Text('HAPUS POSTINGAN', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: const Color(0xFFD9614C))),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteConfirmDialog(storyProvider);
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

  void _showEditDialog() {
    final controller = TextEditingController(text: widget.post.caption ?? '');
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFFF4EBD0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF2C1810), width: 3)),
        title: Text('EDIT DESKRIPSI', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
        content: TextField(
          controller: controller,
          maxLines: 5,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF2C1810)),
          decoration: InputDecoration(
            hintText: 'Tulis deskripsi baru...',
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
              final success = await context.read<StoryProvider>().updatePostCaption(widget.post.id, newCaption);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success ? 'Deskripsi berhasil diubah!' : 'Gagal mengubah deskripsi'),
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

  void _showDeleteConfirmDialog(StoryProvider storyProvider) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFFF4EBD0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF2C1810), width: 3)),
        title: Text('HAPUS POSTINGAN', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
        content: Text('Apakah Anda yakin ingin menghapus postingan ini secara permanen?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF2C1810))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text('BATAL', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD9614C), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFF2C1810), width: 2))),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await storyProvider.deleteStory(widget.post.id, widget.post.mediaUrl);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success ? 'Postingan berhasil dihapus' : storyProvider.errorMessage ?? 'Gagal menghapus postingan'),
                  backgroundColor: success ? const Color(0xFF4A90D9) : const Color(0xFFD9614C),
                ));
              }
            },
            child: Text('HAPUS', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showCommentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CommentsSheet(storyId: widget.post.id, postOwnerId: widget.post.userId),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime.toLocal());
    if (difference.inMinutes < 60) return '${difference.inMinutes} menit lalu';
    if (difference.inHours < 24) return '${difference.inHours} jam lalu';
    return '${difference.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.post.postImages;
    final currentUser = context.watch<AuthProvider>().currentUser;
    final isOwner = currentUser != null && currentUser.id == widget.post.userId;
    final timeAgo = _formatTimeAgo(widget.post.createdAt);
    final storyProvider = context.watch<StoryProvider>();
    final activeStories = storyProvider.stories.where((s) => s.userId == widget.post.userId).toList();
    final allStoriesViewed = activeStories.isNotEmpty && activeStories.every((story) => storyProvider.viewedStoryIds.contains(story.id));
    final likeCount = storyProvider.getLikeCount(widget.post.id);
    final isLiked = storyProvider.isLikedByMe(widget.post.id);
    final commentCount = storyProvider.getCommentCount(widget.post.id);
    final isBookmarked = storyProvider.isBookmarked(widget.post.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2C1810), width: 3),
        boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: activeStories.isNotEmpty
                      ? () {
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
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFF4EBD0),
                      backgroundImage: widget.post.userAvatarUrl != null
                          ? NetworkImage(widget.post.userAvatarUrl!)
                          : NetworkImage('https://ui-avatars.com/api/?name=${(widget.post.userName ?? 'Teknisi').replaceAll(' ', '+')}&background=4A90D9&color=fff'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(child: Text(widget.post.userName ?? 'Teknisi', overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 13, color: const Color(0xFF2C1810)))),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFF4A90D9).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF4A90D9), width: 1)),
                          child: Text('TEKNISI', style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.w900, color: const Color(0xFF4A90D9))),
                        ),
                      ]),
                      const SizedBox(height: 2),
                      Text(timeAgo, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF2C1810).withValues(alpha: 0.5))),
                    ],
                  ),
                ),
                if (isOwner)
                  IconButton(
                    onPressed: _showPostMenu,
                    icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF2C1810)),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),

          // Image Carousel with double-tap
          if (images.isNotEmpty)
            GestureDetector(
              onDoubleTap: _onDoubleTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _aspectRatio,
                    child: Container(
                      decoration: const BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: Color(0xFF2C1810), width: 3))),
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        onPageChanged: (page) => setState(() => _currentPage = page),
                        itemBuilder: (context, index) {
                          return Image.network(
                            images[index],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(color: const Color(0xFFF4EBD0), child: const Center(child: CircularProgressIndicator(color: Color(0xFF2C1810))));
                            },
                            errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFFF4EBD0), child: const Center(child: Icon(Icons.broken_image_rounded, color: Color(0xFF2C1810), size: 48))),
                          );
                        },
                      ),
                    ),
                  ),
                  if (images.length > 1)
                    Positioned(
                      top: 12, right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(12)),
                        child: Text('${_currentPage + 1}/${images.length}', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  // Heart overlay animation
                  if (_showHeartOverlay)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.5, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) => Opacity(
                        opacity: value > 0.9 ? 2.0 - value * 1.1 : 1.0,
                        child: Transform.scale(scale: value, child: child),
                      ),
                      child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 80, shadows: [Shadow(color: Colors.black54, blurRadius: 20)]),
                    ),
                ],
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _toggleLike,
                  child: Row(children: [
                    Icon(isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: isLiked ? const Color(0xFFD9614C) : const Color(0xFF2C1810), size: 24),
                    const SizedBox(width: 4),
                    Text('$likeCount', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF2C1810))),
                  ]),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _showCommentsSheet,
                  child: Row(children: [
                    const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF2C1810), size: 22),
                    const SizedBox(width: 4),
                    Text('$commentCount', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF2C1810))),
                  ]),
                ),
                const Spacer(),
                if (images.length > 1) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(images.length, (index) => Container(
                      width: 6, height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: _currentPage == index ? const Color(0xFFE5B94C) : const Color(0xFF2C1810).withValues(alpha: 0.2)),
                    )),
                  ),
                  const SizedBox(width: 12),
                ],
                GestureDetector(
                  onTap: () {
                    context.read<StoryProvider>().toggleBookmark(widget.post.id);
                  },
                  child: Icon(
                    isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: const Color(0xFF2C1810),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Caption
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF2C1810)),
                children: [
                  TextSpan(text: '${widget.post.userName ?? 'Teknisi'}  ', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
                  TextSpan(text: widget.post.caption ?? '', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Comments Bottom Sheet =====
class _CommentsSheet extends StatefulWidget {
  final String storyId;
  final String postOwnerId;
  const _CommentsSheet({required this.storyId, required this.postOwnerId});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
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
      widget.storyId, text, parentId: _replyToId,
    );
    if (success) await _loadComments();
    if (mounted) setState(() { _isSending = false; _replyToId = null; _replyToName = null; });
  }

  void _setReplyTo(CommentModel comment) {
    setState(() {
      // Always reply to root parent for flat threading
      _replyToId = comment.parentId ?? comment.id;
      _replyToName = comment.userName ?? 'User';
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() { _replyToId = null; _replyToName = null; });
  }

  Future<void> _editComment(CommentModel comment) async {
    final controller = TextEditingController(text: comment.content);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF4EBD0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF2C1810), width: 3)),
        title: Text('EDIT KOMENTAR', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
        content: TextField(
          controller: controller, autofocus: true, maxLines: 4,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF2C1810)),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2C1810), width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5B94C), width: 2)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('BATAL', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE5B94C), foregroundColor: const Color(0xFF2C1810), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFF2C1810), width: 2))),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text('SIMPAN', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
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
    final success = await context.read<StoryProvider>().deleteComment(comment.id, widget.storyId, childCount: childCount);
    if (success) await _loadComments();
  }

  void _showCommentOptions(CommentModel comment, bool isMyComment) {
    final currentUserId = context.read<AuthProvider>().currentUser?.id;
    final isPostOwner = currentUserId != null && currentUserId == widget.postOwnerId;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF4EBD0),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20)), side: BorderSide(color: Color(0xFF2C1810), width: 3)),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.reply_rounded, color: Color(0xFF4A90D9)),
            title: Text('BALAS', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
            onTap: () { Navigator.pop(ctx); _setReplyTo(comment); },
          ),
          if (isMyComment) ...[
            const Divider(color: Color(0xFF2C1810), height: 1),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: Color(0xFFE5B94C)),
              title: Text('EDIT', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
              onTap: () { Navigator.pop(ctx); _editComment(comment); },
            ),
          ],
          if (isMyComment || isPostOwner) ...[
            const Divider(color: Color(0xFF2C1810), height: 1),
            ListTile(
              leading: const Icon(Icons.delete_forever_rounded, color: Color(0xFFD9614C)),
              title: Text('HAPUS', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: const Color(0xFFD9614C))),
              onTap: () { Navigator.pop(ctx); _deleteComment(comment); },
            ),
          ],
        ]),
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
    final allStoriesViewed = hasStories && activeStories.every((story) => storyProvider.viewedStoryIds.contains(story.id));

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
                      ? Border.all(color: allStoriesViewed ? Colors.grey : const Color(0xFFE5B94C), width: 2)
                      : null,
                ),
                child: CircleAvatar(
                  radius: isReply ? 14 : 18,
                  backgroundColor: const Color(0xFFE5B94C),
                  backgroundImage: c.userAvatarUrl != null ? NetworkImage(c.userAvatarUrl!) : null,
                  child: c.userAvatarUrl == null
                      ? Text(c.userName?.isNotEmpty == true ? c.userName![0].toUpperCase() : '?',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: isReply ? 10 : 12, color: const Color(0xFF2C1810)))
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(c.userName ?? 'User', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 12, color: const Color(0xFF2C1810))),
                    if (isPostOwner) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: const Color(0xFFE5B94C), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFF2C1810), width: 1)),
                        child: Text('PEMBUAT', style: GoogleFonts.plusJakartaSans(fontSize: 7, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
                      ),
                    ],
                    const SizedBox(width: 6),
                    Text(_formatTime(c.createdAt), style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF2C1810).withValues(alpha: 0.4))),
                  ]),
                  const SizedBox(height: 3),
                  Text(c.content, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 12.5, color: const Color(0xFF2C1810))),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _setReplyTo(c),
                    child: Text('Balas', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 11, color: const Color(0xFF2C1810).withValues(alpha: 0.5))),
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
    // Watch StoryProvider to trigger rebuild when viewed story status changes
    context.watch<StoryProvider>();

    // Group: root comments then their replies
    final roots = _comments?.where((c) => c.parentId == null).toList() ?? [];
    final replies = _comments?.where((c) => c.parentId != null).toList() ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
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
            // Handle bar
            Center(child: Container(margin: const EdgeInsets.only(top: 10, bottom: 4), width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFF2C1810).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(children: [
                const Icon(Icons.chat_bubble_rounded, color: Color(0xFF2C1810), size: 22),
                const SizedBox(width: 10),
                Text('KOMENTAR', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
              ]),
            ),
            const Divider(color: Color(0xFF2C1810), thickness: 3, height: 3),
            // Comments list
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigator.pop(context);
                },
                child: _comments == null
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF2C1810)))
                    : _comments!.isEmpty
                        ? Center(child: Text('Belum ada komentar', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF2C1810).withValues(alpha: 0.5))))
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
            ),
            // Reply indicator
            if (_replyToName != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: const Color(0xFF2C1810).withValues(alpha: 0.08),
                child: Row(children: [
                  Text('Membalas ', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF2C1810).withValues(alpha: 0.6))),
                  Text(_replyToName!, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
                  const Spacer(),
                  GestureDetector(onTap: _cancelReply, child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF2C1810))),
                ]),
              ),
            // Input
            Container(
              padding: EdgeInsets.only(left: 16, right: 8, top: 8, bottom: MediaQuery.of(context).viewInsets.bottom + 8),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF2C1810), width: 2))),
              child: SafeArea(
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _focusNode,
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF2C1810)),
                      decoration: InputDecoration(
                        hintText: _replyToName != null ? 'Balas $_replyToName...' : 'Tulis komentar...',
                        hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF2C1810).withValues(alpha: 0.4), fontWeight: FontWeight.w600, fontSize: 13),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  _isSending
                      ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2C1810))))
                      : IconButton(icon: const Icon(Icons.send_rounded, color: Color(0xFFE5B94C)), onPressed: _submitComment),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

