import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/story_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final List<Uint8List> _selectedImagesBytes = [];
  final List<String> _selectedFileNames = [];
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final FocusNode _descriptionFocusNode = FocusNode();

  @override
  void dispose() {
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        for (var file in pickedFiles) {
          final bytes = await file.readAsBytes();
          setState(() {
            _selectedFileNames.add(file.name);
            _selectedImagesBytes.add(bytes);
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
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

  void _removeImage(int index) {
    setState(() {
      _selectedImagesBytes.removeAt(index);
      _selectedFileNames.removeAt(index);
    });
  }

  Future<void> _submitPost() async {
    if (_selectedImagesBytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih minimal 1 gambar terlebih dahulu!'),
          backgroundColor: Color(0xFFD9614C),
        ),
      );
      return;
    }

    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan tulis deskripsi postingan terlebih dahulu!'),
          backgroundColor: Color(0xFFD9614C),
        ),
      );
      return;
    }

    final storyProvider = context.read<StoryProvider>();
    final success = await storyProvider.uploadPost(
      imagesBytes: _selectedImagesBytes,
      fileNames: _selectedFileNames,
      description: description,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Postingan berhasil diunggah!'),
            backgroundColor: Color(0xFF4A90D9),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(storyProvider.errorMessage ?? 'Gagal mengunggah postingan'),
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
          'BUAT POSTINGAN',
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
                // Horizontal image picker / list area
                GestureDetector(
                  onTap: _selectedImagesBytes.isEmpty ? _pickImages : null,
                  child: Container(
                    height: 240,
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
                      child: _selectedImagesBytes.isNotEmpty
                          ? Stack(
                              children: [
                                ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _selectedImagesBytes.length + 1,
                                  padding: const EdgeInsets.all(12),
                                  itemBuilder: (context, index) {
                                    if (index == _selectedImagesBytes.length) {
                                      // Add More Button
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                        child: Center(
                                          child: InkWell(
                                            onTap: _pickImages,
                                            borderRadius: BorderRadius.circular(16),
                                            child: Container(
                                              width: 120,
                                              height: 180,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF4EBD0),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(color: const Color(0xFF2C1810), width: 2),
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF2C1810), size: 36),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'TAMBAH',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 12,
                                                      color: const Color(0xFF2C1810),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    // Image card
                                    return Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Container(
                                            width: 160,
                                            height: 200,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: const Color(0xFF2C1810), width: 2),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(14),
                                              child: Image.memory(
                                                _selectedImagesBytes[index],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 14,
                                          child: GestureDetector(
                                            onTap: () => _removeImage(index),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFD9614C), // Red
                                                shape: BoxShape.circle,
                                                border: Border.all(color: const Color(0xFF2C1810), width: 2),
                                              ),
                                              child: const Icon(
                                                Icons.close_rounded,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 12,
                                          left: 14,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.7),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${index + 1}/${_selectedImagesBytes.length}',
                                              style: GoogleFonts.plusJakartaSans(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
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
                                  'PILIH GAMBAR POSTINGAN',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: const Color(0xFF2C1810),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Bisa memilih beberapa gambar sekaligus',
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

                // Description Field Label
                Text(
                  'DESKRIPSI / CAPTION',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: const Color(0xFF2C1810),
                  ),
                ),
                const SizedBox(height: 8),

                // Description Input Field
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
                    controller: _descriptionController,
                    focusNode: _descriptionFocusNode,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF2C1810),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Tulis deskripsi postingan di sini...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF2C1810).withValues(alpha: 0.4),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Submit Button
                GestureDetector(
                  onTap: storyProvider.isUploading ? null : _submitPost,
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
                        'POSTING SEKARANG',
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
                        'MENGUNGGAH POSTINGAN...',
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
