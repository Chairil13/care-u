import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/story_provider.dart';
import '../../widgets/post_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();
    final bookmarked = storyProvider.bookmarkedPosts;

    return Scaffold(
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
                'https://www.transparenttextures.com/patterns/carbon-fibre.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          RefreshIndicator(
            color: const Color(0xFF2C1810),
            backgroundColor: const Color(0xFFE5B94C),
            onRefresh: () => context.read<StoryProvider>().fetchBookmarkedPosts(),
            child: storyProvider.isLoading && bookmarked.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2C1810),
                      strokeWidth: 4,
                    ),
                  )
                : bookmarked.isEmpty
                    ? Center(
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
                                child: const Icon(
                                  Icons.bookmark_border_rounded,
                                  size: 48,
                                  color: Color(0xFF2C1810),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'BELUM ADA POSTINGAN TERSIMPAN',
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
                                  'Postingan yang Anda simpan akan muncul di sini agar mudah dibaca kembali.',
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
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: bookmarked.length,
                        itemBuilder: (context, index) {
                          return PostCard(post: bookmarked[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
