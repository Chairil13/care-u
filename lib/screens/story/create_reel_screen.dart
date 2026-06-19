import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../providers/story_provider.dart';

class CreateReelScreen extends StatefulWidget {
   const CreateReelScreen({super.key});

   @override
   State<CreateReelScreen> createState() => _CreateReelScreenState();
}

class _TeknisiVideoPreview extends StatefulWidget {
  final File file;
  const _TeknisiVideoPreview({required this.file});

  @override
  State<_TeknisiVideoPreview> createState() => _TeknisiVideoPreviewState();
}

class _TeknisiVideoPreviewState extends State<_TeknisiVideoPreview> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2C1810)),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: CircleAvatar(
            backgroundColor: Colors.black26,
            radius: 28,
            child: Icon(
              _controller.value.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
      ],
    );
  }
}

class _CreateReelScreenState extends State<CreateReelScreen> {
  File? _selectedVideoFile;
  String? _selectedFileName;
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final FocusNode _captionFocusNode = FocusNode();

  @override
  void dispose() {
    _captionController.dispose();
    _captionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 1),
      );

      if (pickedFile != null) {
        setState(() {
          _selectedVideoFile = File(pickedFile.path);
          _selectedFileName = pickedFile.name;
        });
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih video: $e'),
            backgroundColor: const Color(0xFFD9614C),
          ),
        );
      }
    }
  }

  Future<void> _submitReel() async {
    if (_selectedVideoFile == null || _selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih video terlebih dahulu!'),
          backgroundColor: Color(0xFFD9614C),
        ),
      );
      return;
    }

    final caption = _captionController.text.trim();
    if (caption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan tulis caption reels terlebih dahulu!'),
          backgroundColor: Color(0xFFD9614C),
        ),
      );
      return;
    }

    final storyProvider = context.read<StoryProvider>();
    final bytes = await _selectedVideoFile!.readAsBytes();

    final success = await storyProvider.uploadReel(
      videoBytes: bytes,
      fileName: _selectedFileName!,
      caption: caption,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reels berhasil diunggah!'),
            backgroundColor: Color(0xFF4A90D9),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(storyProvider.errorMessage ?? 'Gagal mengunggah reels'),
            backgroundColor: const Color(0xFFD9614C),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4EBD0),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C1810)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'BUAT REELS',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: const Color(0xFF2C1810),
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: const Color(0xFF2C1810), height: 2),
        ),
      ),
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _selectedVideoFile == null ? _pickVideo : null,
                  child: Container(
                    height: 320,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF2C1810), width: 3),
                      boxShadow: const [
                        BoxShadow(color: Color(0xFF2C1810), offset: Offset(6, 6)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _selectedVideoFile != null
                          ? Stack(
                              children: [
                                Positioned.fill(
                                  child: _TeknisiVideoPreview(file: _selectedVideoFile!),
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedVideoFile = null;
                                        _selectedFileName = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD9614C),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFF2C1810), width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.video_call_rounded,
                                  size: 64,
                                  color: Color(0xFF2C1810),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'PILIH VIDEO REELS',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: const Color(0xFF2C1810),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pilih video berdurasi maksimal 1 menit',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: const Color(0xFF2C1810).withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'DESKRIPSI / CAPTION REELS',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: const Color(0xFF2C1810),
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2C1810), width: 3),
                    boxShadow: const [
                      BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4)),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _captionController,
                    focusNode: _captionFocusNode,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF2C1810),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 4,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Tulis caption reels di sini...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF2C1810).withValues(alpha: 0.4),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                GestureDetector(
                  onTap: storyProvider.isUploading ? null : _submitReel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5B94C),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF2C1810), width: 3),
                      boxShadow: const [
                        BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4)),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'UNGGAH REELS',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: const Color(0xFF2C1810),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (storyProvider.isUploading)
            Container(
              color: Colors.black45,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4EBD0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2C1810), width: 3),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF2C1810)),
                      const SizedBox(height: 16),
                      Text(
                        'MENGUNGGAH REELS...',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF2C1810),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
