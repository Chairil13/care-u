import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/story_provider.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  Uint8List? _webImageBytes;
  String? _fileName;
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final FocusNode _captionFocusNode = FocusNode();

  @override
  void dispose() {
    _captionController.dispose();
    _captionFocusNode.dispose();
    super.dispose();
  }

  void _showImagePickerOptions() {
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
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF2C1810)),
              title: Text('PILIH DARI GALERI', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const Divider(color: Color(0xFF2C1810), height: 1),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF2C1810)),
              title: Text('AMBIL FOTO', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _fileName = pickedFile.name;
          _webImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: const Color(0xFFD9614C),
          ),
        );
      }
    }
  }

  Future<void> _submitStory() async {
    if (_webImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih gambar terlebih dahulu!'),
          backgroundColor: Color(0xFFD9614C),
        ),
      );
      return;
    }

    final storyProvider = context.read<StoryProvider>();
    final success = await storyProvider.uploadStory(
      mediaBytes: _webImageBytes!,
      fileName: _fileName ?? 'story_image.jpg',
      caption: _captionController.text.trim().isEmpty ? null : _captionController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Story berhasil diposting!'),
            backgroundColor: Color(0xFF4A90D9),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(storyProvider.errorMessage ?? 'Gagal memposting story'),
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
          'BUAT STORY',
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Preview Area
                GestureDetector(
                  onTap: () {
                    if (_webImageBytes == null) {
                      _showImagePickerOptions();
                    } else {
                      _captionFocusNode.requestFocus();
                    }
                  },
                  child: Container(
                    height: 480, // Slightly taller for better aspect ratio
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
                      child: _webImageBytes != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(_webImageBytes!, fit: BoxFit.cover),
                                // Semi-transparent overlay caption input at the bottom of the image container
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  right: 16,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white30, width: 2),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    child: TextField(
                                      controller: _captionController,
                                      focusNode: _captionFocusNode,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Tulis caption story...',
                                        hintStyle: GoogleFonts.plusJakartaSans(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Edit Photo indicator on top right
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: _showImagePickerOptions,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE5B94C),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFF2C1810), width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.edit_rounded,
                                        color: Color(0xFF2C1810),
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
                                  Icons.add_photo_alternate_rounded,
                                  size: 64,
                                  color: Color(0xFF2C1810),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'PILIH GAMBAR STORY',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: const Color(0xFF2C1810),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap untuk membuka galeri / kamera',
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
                const SizedBox(height: 32),

                const SizedBox(height: 16),

                // Submit Button
                GestureDetector(
                  onTap: storyProvider.isUploading ? null : _submitStory,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5B94C), // Gold
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF2C1810), width: 3),
                      boxShadow: const [
                        BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4)),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'POSTING STORY',
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
                        'MENGUNGGAH STORY...',
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
