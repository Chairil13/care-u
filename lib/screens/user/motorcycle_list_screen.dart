import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/motorcycle_provider.dart';
import 'add_edit_motorcycle_screen.dart';

class MotorcycleListScreen extends StatefulWidget {
  const MotorcycleListScreen({super.key});

  @override
  State<MotorcycleListScreen> createState() => _MotorcycleListScreenState();
}

class _MotorcycleListScreenState extends State<MotorcycleListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      context.read<MotorcycleProvider>().fetchMotorcycles()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD0), // Vintage Paper
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
          SafeArea(
            child: Column(
              children: [
                // Custom Branded AppBar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9614C), // Retro Red
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF2C1810), width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF2C1810),
                          offset: Offset(8, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFF4EBD0)),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              'MY MOTORCYCLES',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: const Color(0xFFF4EBD0),
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Consumer<MotorcycleProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading && provider.motorcycles.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2C1810),
                            strokeWidth: 4,
                          ),
                        );
                      }

                      if (provider.motorcycles.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                        physics: const BouncingScrollPhysics(),
                        itemCount: provider.motorcycles.length,
                        itemBuilder: (context, index) {
                          final bike = provider.motorcycles[index];
                          return _buildMotorcycleItem(bike);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditMotorcycleScreen()),
        ),
        backgroundColor: const Color(0xFFE5B94C), // Mustard
        foregroundColor: const Color(0xFF2C1810),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2C1810), width: 3),
        ),
        label: Row(
          children: [
            const Icon(Icons.add_rounded, weight: 900),
            const SizedBox(width: 8),
            Text(
              'ADD MOTOR',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotorcycleItem(dynamic bike) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C1810), width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF2C1810),
            offset: Offset(8, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF2C1810),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'REGISTERED MACHINE',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFF4EBD0),
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                const Icon(Icons.verified_rounded, color: Color(0xFFE5B94C), size: 16),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4EBD0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2C1810), width: 2),
                  ),
                  child: const Icon(Icons.two_wheeler_rounded, color: Color(0xFF2C1810), size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${bike.brand} ${bike.model}'.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: const Color(0xFF2C1810),
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: const BoxDecoration(color: Color(0xFFE5B94C)),
                        child: Text(
                          bike.plateNumber.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: const Color(0xFF2C1810),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF2C1810)),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditMotorcycleScreen(motorcycle: bike),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFD9614C)),
                      onPressed: () => _confirmDelete(context, bike.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF4EBD0),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2C1810), width: 4),
              boxShadow: const [
                BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4)),
              ],
            ),
            child: const Icon(Icons.motorcycle_rounded, size: 64, color: Color(0xFF2C1810)),
          ),
          const SizedBox(height: 32),
          Text(
            'NO MACHINES FOUND',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2C1810),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your ride to get started!',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2C1810).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF4EBD0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2C1810), width: 4),
        ),
        title: Text(
          'DELETE MOTOR?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900),
        ),
        content: Text(
          'This action cannot be undone. Are you sure you want to remove this machine?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2C1810),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8, bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFD9614C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2C1810), width: 2),
            ),
            child: TextButton(
              onPressed: () {
                context.read<MotorcycleProvider>().deleteMotorcycle(id);
                Navigator.pop(ctx);
              },
              child: Text(
                'DELETE',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFF4EBD0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
