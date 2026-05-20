import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../models/message_model.dart';
import '../../providers/chat_provider.dart';

class ChatDetailScreen extends StatefulWidget {
  final UserModel partner;

  const ChatDetailScreen({super.key, required this.partner});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final String _currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

  late ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = context.read<ChatProvider>();
    _chatProvider.activeChatPartnerId = widget.partner.id;
  }

  @override
  void dispose() {
    _chatProvider.activeChatPartnerId = null;
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    final success = await context.read<ChatProvider>().sendMessage(
          widget.partner.id,
          text,
        );

    if (success) {
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } else {
      if (mounted) {
        final error = context.read<ChatProvider>().errorMessage ?? 'Gagal mengirim pesan';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
            backgroundColor: const Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    // Return time in HH:mm format, adjusted to local timezone
    final localTime = dateTime.toLocal();
    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _handlePickImage() async {
    final picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF4EBD0), // Vintage paper
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF2C1810), width: 4),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF2C1810),
                offset: Offset(8, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1810),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'PILIH SUMBER GAMBAR',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: const Color(0xFF2C1810),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 24),
              // Kamera Button
              InkWell(
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 70,
                  );
                  if (pickedFile != null && mounted) {
                    _showImagePreviewAndCaptionDialog(pickedFile);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5B94C), // Yellow
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2C1810), width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF2C1810),
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_rounded, color: Color(0xFF2C1810)),
                        const SizedBox(width: 8),
                        Text(
                          'AMBIL FOTO (KAMERA)',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2C1810),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Galeri Button
              InkWell(
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 70,
                  );
                  if (pickedFile != null && mounted) {
                    _showImagePreviewAndCaptionDialog(pickedFile);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90D9), // Blue
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2C1810), width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF2C1810),
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.photo_library_rounded, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'PILIH DARI GALERI',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontSize: 14,
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
      },
    );
  }

  Future<void> _processPickedImage(XFile pickedFile, String caption) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final chatProvider = context.read<ChatProvider>();

    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4EBD0),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2C1810), width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF2C1810),
                    offset: Offset(8, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C1810)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'MENGUNGGAH GAMBAR...',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: const Color(0xFF2C1810),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      final bytes = await pickedFile.readAsBytes();
      final name = pickedFile.name;
      
      final imageUrl = await chatProvider.uploadChatImage(bytes, name);
      
      // Close the loading dialog
      navigator.pop();

      if (imageUrl != null) {
        final success = await chatProvider.sendImageMessage(
          widget.partner.id,
          imageUrl,
          caption,
        );

        if (!success) {
          final error = chatProvider.errorMessage ?? 'Gagal mengirim gambar';
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                error,
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
              backgroundColor: const Color(0xFFD32F2F),
            ),
          );
        }
      } else {
        final error = chatProvider.errorMessage ?? 'Gagal mengunggah gambar';
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              error,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    } catch (e) {
      // Try to close dialog if still open
      try {
        navigator.pop();
      } catch (_) {}
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'Terjadi kesalahan: $e',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFFD32F2F),
        ),
      );
    }
  }

  void _showImagePreviewAndCaptionDialog(XFile pickedFile) {
    final captionController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: const Color(0xFFF4EBD0), // Vintage paper
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF2C1810), width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF2C1810),
                  offset: Offset(8, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'KIRIM GAMBAR',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: const Color(0xFF2C1810),
                          letterSpacing: 1,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF2C1810), size: 28),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Image Preview Container
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                      child: Image.file(
                        File(pickedFile.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Caption Input Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2C1810), width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF2C1810),
                          offset: Offset(4, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: captionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tulis keterangan gambar (opsional)...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C1810).withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2C1810),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Actions buttons
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF2C1810), width: 3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF2C1810),
                                  offset: Offset(4, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'BATAL',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF2C1810),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Send Button
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            final caption = captionController.text;
                            Navigator.of(context).pop();
                            _processPickedImage(pickedFile, caption);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: widget.partner.role == 'teknisi' 
                                  ? const Color(0xFF4A90D9) // Blue for User
                                  : const Color(0xFFE5B94C), // Yellow for Teknisi
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF2C1810), width: 3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF2C1810),
                                  offset: Offset(4, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'KIRIM',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w900,
                                  color: widget.partner.role == 'teknisi'
                                      ? Colors.white
                                      : const Color(0xFF2C1810),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMessageActions(BuildContext context, MessageModel message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF4EBD0), // Vintage paper
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF2C1810), width: 4),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF2C1810),
                offset: Offset(8, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1810),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'TINDAKAN PESAN',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: const Color(0xFF2C1810),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 24),
              // Edit Button
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  _showEditDialog(context, message);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90D9), // Blue
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2C1810), width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF2C1810),
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.edit_rounded, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'UBAH PESAN',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Delete Button
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmDialog(context, message);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9614C), // Red
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2C1810), width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF2C1810),
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_rounded, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'HAPUS PESAN',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontSize: 14,
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
      },
    );
  }

  void _showEditDialog(BuildContext context, MessageModel message) {
    final editController = TextEditingController(text: message.message);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4EBD0),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF2C1810), width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF2C1810),
                  offset: Offset(8, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UBAH PESAN',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: const Color(0xFF2C1810),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2C1810), width: 3),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: editController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Ketik pesan...',
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2C1810),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2C1810), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              'BATAL',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2C1810),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final text = editController.text.trim();
                          if (text.isEmpty) return;
                          Navigator.of(context).pop();
                          final success = await context.read<ChatProvider>().editMessage(message.id, text);
                          if (!context.mounted) return;
                          if (!success) {
                            final error = context.read<ChatProvider>().errorMessage ?? 'Gagal mengubah pesan';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  error,
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                                ),
                                backgroundColor: const Color(0xFFD32F2F),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A90D9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2C1810), width: 2),
                            boxShadow: const [
                              BoxShadow(color: Color(0xFF2C1810), offset: Offset(2, 2)),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'SIMPAN',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, MessageModel message) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4EBD0),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF2C1810), width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF2C1810),
                  offset: Offset(8, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HAPUS PESAN?',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: const Color(0xFF2C1810),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Apakah Anda yakin ingin menghapus pesan ini? Tindakan ini tidak dapat dibatalkan.',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C1810).withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2C1810), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              'BATAL',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2C1810),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          Navigator.of(context).pop();
                          final success = await context.read<ChatProvider>().deleteMessage(message.id);
                          if (!context.mounted) return;
                          if (!success) {
                            final error = context.read<ChatProvider>().errorMessage ?? 'Gagal menghapus pesan';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  error,
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                                ),
                                backgroundColor: const Color(0xFFD32F2F),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9614C),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2C1810), width: 2),
                            boxShadow: const [
                              BoxShadow(color: Color(0xFF2C1810), offset: Offset(2, 2)),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'HAPUS',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPartnerInfo() {
    final isPartnerTeknisi = widget.partner.role == 'teknisi';
    final themeColor = isPartnerTeknisi 
        ? const Color(0xFFD9614C) // Retro Red/Orange
        : const Color(0xFF4A90D9); // Blue

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF4EBD0), // Vintage paper
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF2C1810), width: 4),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF2C1810),
                offset: Offset(8, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handlebar
              Container(
                width: 40,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1810),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 24),
              // Header Title
              Text(
                isPartnerTeknisi ? 'INFORMASI TEKNISI' : 'INFORMASI USER',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: const Color(0xFF2C1810),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 24),
              // Large Profile Avatar
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // Close bottom sheet
                  final String imageUrl = widget.partner.avatarUrl ??
                      'https://ui-avatars.com/api/?name=${widget.partner.name.replaceAll(' ', '+')}&background=${isPartnerTeknisi ? "D9614C" : "4A90D9"}&color=fff&size=512';
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FullScreenImageViewer(imageUrl: imageUrl),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2C1810), width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF2C1810),
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: themeColor,
                    backgroundImage: widget.partner.avatarUrl != null
                        ? NetworkImage(widget.partner.avatarUrl!)
                        : NetworkImage(
                            'https://ui-avatars.com/api/?name=${widget.partner.name.replaceAll(' ', '+')}&background=${isPartnerTeknisi ? "D9614C" : "4A90D9"}&color=fff',
                          ) as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Name
              Text(
                widget.partner.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2C1810),
                ),
              ),
              const SizedBox(height: 6),
              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: themeColor, width: 2),
                ),
                child: Text(
                  widget.partner.role.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: themeColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Info detail container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2C1810), width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF2C1810),
                      offset: Offset(4, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Email row
                    _buildInfoRow(
                      icon: Icons.email_rounded,
                      label: 'EMAIL',
                      value: widget.partner.email,
                      iconColor: const Color(0xFF4A90D9),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: Color(0xFF2C1810), thickness: 1.5),
                    ),
                    // Phone row
                    _buildInfoRow(
                      icon: Icons.phone_rounded,
                      label: 'TELEPON / WA',
                      value: widget.partner.phone != null && widget.partner.phone!.isNotEmpty
                          ? widget.partner.phone!
                          : 'Belum diisi',
                      iconColor: const Color(0xFFE5B94C),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Close Button
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2C1810), width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF2C1810),
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'TUTUP',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2C1810),
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF2C1810), width: 2),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2C1810).withValues(alpha: 0.6),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2C1810),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use role-based colors to match the app style
    final isPartnerTeknisi = widget.partner.role == 'teknisi';
    final themeColor = isPartnerTeknisi 
        ? const Color(0xFFD9614C) // Retro Red/Orange for Mahasiswi chatting with Teknisi
        : const Color(0xFF4A90D9); // Teknisi Blue for Teknisi chatting with User

    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD0), // Vintage Paper
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4EBD0),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C1810)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                final String imageUrl = widget.partner.avatarUrl ??
                    'https://ui-avatars.com/api/?name=${widget.partner.name.replaceAll(' ', '+')}&background=${isPartnerTeknisi ? "D9614C" : "4A90D9"}&color=fff&size=512';
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FullScreenImageViewer(imageUrl: imageUrl),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1810),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2C1810), width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFF4EBD0),
                  backgroundImage: widget.partner.avatarUrl != null
                      ? NetworkImage(widget.partner.avatarUrl!)
                      : NetworkImage(
                          'https://ui-avatars.com/api/?name=${widget.partner.name.replaceAll(' ', '+')}&background=${isPartnerTeknisi ? "D9614C" : "4A90D9"}&color=fff',
                        ) as ImageProvider,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _showPartnerInfo,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.partner.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2C1810),
                      ),
                    ),
                    Text(
                      widget.partner.role.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: themeColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            color: const Color(0xFF2C1810),
            height: 4,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Texture
          Positioned.fill(
            child: Opacity(
              opacity: 0.04,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/carbon-fibre.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: StreamBuilder<List<MessageModel>>(
                  stream: context.read<ChatProvider>().getMessageStream(widget.partner.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2C1810),
                          strokeWidth: 4,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Terjadi kesalahan memuat pesan.',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2C1810),
                          ),
                        ),
                      );
                    }

                    final messages = snapshot.data ?? [];

                    // Scroll to bottom once data is loaded or when list updates
                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF2C1810), width: 3),
                                boxShadow: const [
                                  BoxShadow(color: Color(0xFF2C1810), offset: Offset(3, 3)),
                                ],
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 40,
                                color: themeColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'BELUM ADA PESAN',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2C1810),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kirim pesan pertama untuk memulai obrolan.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2C1810).withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == _currentUserId;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: GestureDetector(
                            onLongPress: isMe ? () => _showMessageActions(context, msg) : null,
                            child: _buildChatBubble(
                              msg.message,
                              isMe: isMe,
                              time: _formatTime(msg.createdAt),
                              bubbleColor: isMe 
                                  ? (isPartnerTeknisi ? const Color(0xFFE5B94C) : const Color(0xFF4A90D9)) 
                                  : Colors.white,
                              textColor: isMe && !isPartnerTeknisi ? Colors.white : const Color(0xFF2C1810),
                              imageUrl: msg.imageUrl,
                              onLongPress: isMe ? () => _showMessageActions(context, msg) : null,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Chat Input Bar
              _buildInputBar(themeColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(
    String text, {
    required bool isMe,
    required String time,
    required Color bubbleColor,
    required Color textColor,
    String? imageUrl,
    VoidCallback? onLongPress,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 20),
              ),
              border: Border.all(color: const Color(0xFF2C1810), width: 3),
              boxShadow: const [
                BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageUrl != null) ...[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageViewer(imageUrl: imageUrl),
                        ),
                      );
                    },
                    onLongPress: onLongPress,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF2C1810), width: 2),
                        ),
                        child: Image.network(
                          imageUrl,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 150,
                              width: 200,
                              color: const Color(0xFFF4EBD0),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C1810)),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 150,
                              width: 200,
                              color: const Color(0xFFF4EBD0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: Color(0xFFD9614C), size: 36),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Gagal memuat gambar',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: const Color(0xFF2C1810),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (text.isNotEmpty) const SizedBox(height: 12),
                ],
                if (text.isNotEmpty)
                  Text(
                    text,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              time,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2C1810).withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(Color themeColor) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF4EBD0),
        border: Border(top: BorderSide(color: Color(0xFF2C1810), width: 4)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2C1810), width: 4),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF2C1810),
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.add_photo_alternate_rounded,
                color: Color(0xFF2C1810),
                size: 26,
              ),
              onPressed: _handlePickImage,
            ),
            Container(
              width: 3,
              height: 28,
              color: const Color(0xFF2C1810),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _messageController,
                  onSubmitted: (_) => _handleSend(),
                  decoration: InputDecoration(
                    hintText: 'Ketik pesan...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2C1810).withValues(alpha: 0.4),
                    ),
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C1810),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF2C1810),
                  width: 2,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.send_rounded,
                  color: widget.partner.role == 'teknisi' 
                      ? const Color(0xFFF4EBD0) // Vintage Paper color
                      : Colors.white,
                ),
                onPressed: _handleSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1810), // Retro dark brown background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFF4EBD0)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF4EBD0)),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFD9614C), size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat gambar',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFF4EBD0),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
