import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/story_model.dart';
import '../../models/user_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/story_provider.dart';

class StoryViewScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;

  const StoryViewScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  int _currentIndex = 0;
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();
  DateTime? _pressStartTime;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _animController = AnimationController(vsync: this);

    _showStory();

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.stop();
        _animController.reset();
        if (_currentIndex + 1 < widget.stories.length) {
          setState(() {
            _currentIndex++;
            _pageController.animateToPage(
              _currentIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
          _showStory();
        } else {
          // Last story completed, exit screen
          Navigator.pop(context);
        }
      }
    });

    _replyFocusNode.addListener(() {
      if (_replyFocusNode.hasFocus) {
        _animController.stop();
      } else {
        if (mounted && !_animController.isAnimating) {
          _animController.forward();
        }
      }
    });
  }

  void _showStory() {
    _animController.duration = const Duration(seconds: 5);
    _animController.forward();

    // Register view for all stories viewed (including our own, so the border turns grey)
    final currentStory = widget.stories[_currentIndex];
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId != null) {
      context.read<StoryProvider>().markStoryAsViewed(currentStory.id);
    }
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    final story = widget.stories[_currentIndex];
    
    // Hide keyboard and clear text input
    _replyFocusNode.unfocus();
    _replyController.clear();

    try {
      final chatProvider = context.read<ChatProvider>();
      
      // Send the reply message to story creator (story.userId)
      // Send as image message (the story itself) with caption to match Instagram's behavior
      final success = await chatProvider.sendImageMessage(
        story.userId,
        story.mediaUrl,
        'Membalas story: "$text"',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Balasan terkirim ke chat!' : 'Gagal mengirim balasan'),
            backgroundColor: success ? const Color(0xFF4A90D9) : const Color(0xFFD9614C),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sending story reply: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: const Color(0xFFD9614C),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showStoryOptions(BuildContext context, StoryModel story) {
    _animController.stop();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF4EBD0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Color(0xFF2C1810), width: 3),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_forever_rounded, color: Color(0xFFD9614C)),
              title: Text(
                'HAPUS STORY',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFD9614C),
                ),
              ),
              onTap: () async {
                Navigator.pop(bottomSheetContext); // close bottom sheet
                _showDeleteConfirmation(context, story);
              },
            ),
            const Divider(color: Color(0xFF2C1810), height: 1),
            ListTile(
              leading: const Icon(Icons.close_rounded, color: Color(0xFF2C1810)),
              title: Text(
                'BATAL',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
              ),
              onTap: () {
                Navigator.pop(bottomSheetContext);
              },
            ),
          ],
        ),
      ),
    ).then((_) {
      if (mounted && !_replyFocusNode.hasFocus) {
        _animController.forward();
      }
    });
  }

  void _showDeleteConfirmation(BuildContext parentContext, StoryModel story) {
    showDialog<bool>(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFF4EBD0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2C1810), width: 3),
        ),
        title: Text(
          'HAPUS STORY?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: const Color(0xFF2C1810)),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus story ini secara permanen?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF2C1810)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'BATAL',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF2C1810)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD9614C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF2C1810), width: 2),
              ),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'HAPUS',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    ).then((shouldDelete) async {
      if (shouldDelete == true) {
        if (parentContext.mounted) {
          final storyProvider = parentContext.read<StoryProvider>();
          final messenger = ScaffoldMessenger.of(parentContext);
          
          Navigator.pop(parentContext); // close StoryViewScreen cleanly
          
          final success = await storyProvider.deleteStory(story.id, story.mediaUrl);

          messenger.showSnackBar(
            SnackBar(
              content: Text(success ? 'Story berhasil dihapus!' : 'Gagal menghapus story'),
              backgroundColor: success ? const Color(0xFF4A90D9) : const Color(0xFFD9614C),
            ),
          );
        }
      } else {
        if (mounted) {
          _animController.forward();
        }
      }
    });
  }

  Widget _buildViewerListButton(StoryModel story) {
    return FutureBuilder<List<UserModel>>(
      future: context.read<StoryProvider>().fetchStoryViews(story.id),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.length : 0;
        return Center(
          child: GestureDetector(
            onTap: () => _showViewerListBottomSheet(story),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5B94C).withValues(alpha: 0.5), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.visibility_rounded, color: Color(0xFFE5B94C), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$count Penonton',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showViewerListBottomSheet(StoryModel story) {
    _animController.stop();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF4EBD0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Color(0xFF2C1810), width: 3),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 4),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C1810).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.visibility_rounded, color: Color(0xFF2C1810), size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'DILIHAT OLEH',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF2C1810),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFF2C1810), thickness: 3),
                Flexible(
                  child: FutureBuilder<List<UserModel>>(
                    future: context.read<StoryProvider>().fetchStoryViews(story.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 120,
                          child: Center(
                            child: CircularProgressIndicator(color: Color(0xFF2C1810)),
                          ),
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return SizedBox(
                          height: 120,
                          child: Center(
                            child: Text(
                              'Belum ada penonton',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2C1810).withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        );
                      }

                      final viewers = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: viewers.length,
                        itemBuilder: (context, index) {
                          final viewer = viewers[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            leading: Container(
                              padding: const EdgeInsets.all(1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C1810),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF2C1810), width: 1.5),
                              ),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFFE5B94C),
                                backgroundImage: viewer.avatarUrl != null
                                    ? NetworkImage(viewer.avatarUrl!)
                                    : null,
                                child: viewer.avatarUrl == null
                                    ? Text(
                                        viewer.name.isNotEmpty ? viewer.name[0].toUpperCase() : '?',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF2C1810),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            title: Text(
                              viewer.name.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2C1810),
                              ),
                            ),
                            subtitle: Text(
                              viewer.role.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                color: const Color(0xFF4A90D9),
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
      },
    ).then((_) {
      if (mounted) {
        _animController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  String _getRelativeTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime.toLocal());
    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else {
      return '${difference.inHours}j';
    }
  }

  void _onTapUp(TapUpDetails details, StoryModel story) {
    if (_pressStartTime == null) return;
    final difference = DateTime.now().difference(_pressStartTime!);
    _pressStartTime = null;

    if (difference.inMilliseconds < 300) {
      // Quick tap -> navigate next/prev
      final screenWidth = MediaQuery.of(context).size.width;
      final dx = details.globalPosition.dx;

      if (dx < screenWidth / 3) {
        // Tap left: Go to previous
        if (_currentIndex > 0) {
          _animController.stop();
          _animController.reset();
          setState(() {
            _currentIndex--;
            _pageController.animateToPage(
              _currentIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
          _showStory();
        } else {
          // Close if first story and tap left
          Navigator.pop(context);
        }
      } else {
        // Tap right: Go to next
        _animController.stop();
        _animController.reset();
        if (_currentIndex + 1 < widget.stories.length) {
          setState(() {
            _currentIndex++;
            _pageController.animateToPage(
              _currentIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
          _showStory();
        } else {
          // Close if last story
          Navigator.pop(context);
        }
      }
    } else {
      // Long press release -> resume
      if (mounted && !_replyFocusNode.hasFocus) {
        _animController.forward();
      }
    }
  }

  void _onTapCancel() {
    _pressStartTime = null;
    if (mounted && !_replyFocusNode.hasFocus) {
      _animController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final showReplyInput = story.userId != currentUserId;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTapDown: (details) {
          _pressStartTime = DateTime.now();
          _animController.stop();
        },
        onTapUp: (details) => _onTapUp(details, story),
        onTapCancel: _onTapCancel,
        child: SizedBox.expand(
          child: Stack(
            children: [
              // Story Media (Image)
              Positioned.fill(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.stories.length,
                  itemBuilder: (context, idx) {
                    final s = widget.stories[idx];
                    return Container(
                      color: Colors.black,
                      child: Center(
                        child: Image.network(
                          s.mediaUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(
                              Icons.error_outline_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Top Gradient overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 140,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black54, Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // Bottom Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 180,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black87],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // Header UI (Avatar, Name, Time, Progress indicators)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Story Progress Bars
                      Row(
                        children: List.generate(
                          widget.stories.length,
                          (idx) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: AnimatedBuilder(
                                animation: _animController,
                                builder: (context, child) {
                                  double val = 0.0;
                                  if (idx < _currentIndex) {
                                    val = 1.0;
                                  } else if (idx == _currentIndex) {
                                    val = _animController.value;
                                  }
                                  return LinearProgressIndicator(
                                    value: val,
                                    backgroundColor: Colors.white30,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                    minHeight: 3,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // User Info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFFE5B94C),
                            backgroundImage: story.userAvatarUrl != null
                                ? NetworkImage(story.userAvatarUrl!)
                                : null,
                            child: story.userAvatarUrl == null
                                ? Text(
                                    story.userName?.isNotEmpty == true
                                        ? story.userName![0].toUpperCase()
                                        : 'T',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: const Color(0xFF2C1810),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            story.userName ?? 'Teknisi',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getRelativeTime(story.createdAt),
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (story.userId == currentUserId)
                            IconButton(
                              icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 24),
                              onPressed: () => _showStoryOptions(context, story),
                            ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Caption & Reply Input
              Positioned(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 20,
                right: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (story.caption != null && story.caption!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: Text(
                          story.caption!,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (showReplyInput)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white30, width: 1.5),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: _replyController,
                                focusNode: _replyFocusNode,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Balas story...',
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    color: Colors.white54,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _sendReply,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE5B94C),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.send_rounded,
                                color: Color(0xFF2C1810),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      _buildViewerListButton(story),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
