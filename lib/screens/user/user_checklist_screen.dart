import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/checklist_provider.dart';
import '../../models/checklist_model.dart';

String _formatDate(DateTime dt) {
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  final day = dt.day.toString().padLeft(2, '0');
  final month = months[dt.month - 1];
  final year = dt.year;
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$day $month $year, $hour:$minute';
}

class UserChecklistScreen extends StatefulWidget {
  const UserChecklistScreen({super.key});

  @override
  State<UserChecklistScreen> createState() => _UserChecklistScreenState();
}

class _UserChecklistScreenState extends State<UserChecklistScreen> {
  int _activeTab = 0; // 0 = Isi Checklist, 1 = Riwayat
  String _selectedHistoryKategori = 'Semua';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ChecklistProvider>().fetchForms();
        context.read<ChecklistProvider>().fetchResults(isTeknisi: false);
        context.read<ChecklistProvider>().clearNewChecklistIndicator();
      }
    });
  }

  Future<void> _deleteChecklistResult(ChecklistResultModel result) async {
    final provider = context.read<ChecklistProvider>();
    
    // Show confirmation dialog before deleting
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF4EBD0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2C1810), width: 3),
        ),
        title: Text(
          'HAPUS JAWABAN?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF2C1810),
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus hasil checklist ini?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2C1810),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'BATAL',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2C1810),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD9614C),
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF2C1810), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'HAPUS',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2C1810),
            strokeWidth: 4,
          ),
        ),
      );

      final success = await provider.deleteResult(result.id);
      
      if (mounted) {
        Navigator.of(context).pop(); // Hide loading
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF5AB974),
              content: Text(
                'Hasil checklist berhasil dihapus!',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFD9614C),
              content: Text(
                provider.errorMessage ?? 'Gagal menghapus checklist.',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Background texture managed by main screen
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'WEEKLY MOTOR CHECKLIST',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: const Color(0xFFF4EBD0),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            // Tab toggles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _activeTab == 0 ? const Color(0xFFE5B94C) : Colors.white,
                          border: Border.all(color: const Color(0xFF2C1810), width: 3),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'ISI CHECKLIST',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: const Color(0xFF2C1810),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _activeTab == 1 ? const Color(0xFFE5B94C) : Colors.white,
                          border: Border.all(color: const Color(0xFF2C1810), width: 3),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'RIWAYAT',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: const Color(0xFF2C1810),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab Content
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF2C1810),
                backgroundColor: const Color(0xFFF4EBD0),
                onRefresh: () async {
                  await context.read<ChecklistProvider>().fetchForms();
                  await context.read<ChecklistProvider>().fetchResults(isTeknisi: false);
                },
                child: Consumer<ChecklistProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2C1810),
                          strokeWidth: 4,
                        ),
                      );
                    }

                    if (_activeTab == 0) {
                      final filledFormIds = provider.results.map((r) => r.formId).toSet();
                      final unfilledForms = provider.forms.where((f) => !filledFormIds.contains(f.id)).toList();
                      return _buildFormsList(unfilledForms);
                    } else {
                      final filteredResults = _selectedHistoryKategori == 'Semua'
                          ? provider.results
                          : provider.results.where((r) => (r.formKategori ?? 'Harian') == _selectedHistoryKategori).toList();
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: ['Semua', 'Harian', 'Mingguan', 'Bulanan'].map((cat) {
                                  final isSelected = _selectedHistoryKategori == cat;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedHistoryKategori = cat;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFFE5B94C) : Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFF2C1810), width: 2),
                                          boxShadow: isSelected
                                              ? null
                                              : const [
                                                  BoxShadow(
                                                    color: Color(0xFF2C1810),
                                                    offset: Offset(2, 2),
                                                  ),
                                                ],
                                        ),
                                        child: Text(
                                          cat.toUpperCase(),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 10,
                                            color: const Color(0xFF2C1810),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          Expanded(
                            child: _buildResultsList(filteredResults),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormsList(List<FormChecklistModel> forms) {
    if (forms.isEmpty) {
      return _buildEmptyState('BELUM ADA CHECKLIST', 'Teknisi belum merilis form checklist pengecekan.');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: forms.length,
      itemBuilder: (context, index) {
        final form = forms[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF2C1810),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  'CHECKLIST ${form.kategori.toUpperCase()}',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFF4EBD0),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      form.judul.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: const Color(0xFF2C1810),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      form.deskripsi ?? 'Silahkan isi checklist rutin untuk motor Anda.',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: const Color(0xFF2C1810).withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.list_alt_rounded, size: 16, color: Color(0xFF2C1810)),
                        const SizedBox(width: 6),
                        Text(
                          '${form.items.length} Parameter Pengecekan',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            color: const Color(0xFF2C1810),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _openFillFormScreen(form),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9614C), // Retro Red
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2C1810), width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF2C1810),
                              offset: Offset(3, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'MULAI PENGECEKAN',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultsList(List<ChecklistResultModel> results) {
    if (results.isEmpty) {
      return _buildEmptyState('BELUM ADA RIWAYAT', 'Anda belum pernah mengirim hasil checklist pengecekan.');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        final formattedDate = result.createdAt != null
            ? _formatDate(result.createdAt!.toLocal())
            : 'Sore/Pagi ini';

        final hasFeedback = result.feedback != null && result.feedback!.isNotEmpty;

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hasFeedback ? const Color(0xFFE5B94C) : const Color(0xFF2C1810),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(result.formKategori ?? 'Harian').toUpperCase()} • ${hasFeedback ? 'FEEDBACK TERSEDIA' : 'SELESAI'}',
                      style: GoogleFonts.plusJakartaSans(
                        color: hasFeedback ? const Color(0xFF2C1810) : const Color(0xFFF4EBD0),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    Icon(
                      hasFeedback ? Icons.notifications_active_rounded : Icons.check_circle_rounded,
                      size: 14,
                      color: hasFeedback ? const Color(0xFF2C1810) : const Color(0xFFF4EBD0),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (result.formJudul ?? 'Pengecekan Motor').toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: const Color(0xFF2C1810),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dikirim pada: $formattedDate',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: const Color(0xFF2C1810).withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Answers preview tag list
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: result.jawaban.entries.map((entry) {
                        final String item = entry.key;
                        final Map<String, dynamic> detail = Map<String, dynamic>.from(entry.value as Map);
                        final String status = detail['status'] as String? ?? 'Baik';
                        
                        Color statusColor = const Color(0xFF5AB974); // Green
                        if (status == 'Perlu Servis') {
                          statusColor = const Color(0xFFE5B94C); // Mustard
                        } else if (status == 'Kritis') {
                          statusColor = const Color(0xFFD9614C); // Red
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: statusColor, width: 1.5),
                          ),
                          child: Text(
                            '$item: $status',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              color: statusColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Feedback box if available
                    if (hasFeedback) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4EBD0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5B94C), width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SARAN TEKNISI:',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                color: const Color(0xFF2C1810),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              result.feedback!,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: const Color(0xFF2C1810),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C1810).withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2C1810).withValues(alpha: 0.2), width: 2),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.hourglass_empty_rounded,
                              size: 16,
                              color: const Color(0xFF2C1810).withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Menunggu feedback teknisi...',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: const Color(0xFF2C1810).withValues(alpha: 0.6),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _openResultDetail(result),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF2C1810), width: 2.5),
                              ),
                              child: Center(
                                child: Text(
                                  'LIHAT DETAIL JAWABAN',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF2C1810),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _deleteChecklistResult(result),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9614C), // Retro Red
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF2C1810), width: 2.5),
                            ),
                            child: const Icon(
                              Icons.delete_forever_rounded,
                              color: Colors.white,
                              size: 18,
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
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2C1810), width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF2C1810),
                  offset: Offset(4, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.assignment_turned_in_rounded,
              size: 48,
              color: Color(0xFFE5B94C),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2C1810),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              subtitle,
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
    );
  }

  void _openFillFormScreen(FormChecklistModel form) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FillChecklistScreen(form: form),
      ),
    );
  }

  void _openResultDetail(ChecklistResultModel result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(24),
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
                'HASIL DETAIL CHECKLIST',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: const Color(0xFF2C1810),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                result.formJudul ?? 'Checklist Mingguan',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: const Color(0xFF2C1810).withValues(alpha: 0.7),
                ),
              ),
              if (result.formDeskripsi != null && result.formDeskripsi!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90D9).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF4A90D9).withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF4A90D9)),
                          const SizedBox(width: 6),
                          Text(
                            'CARA PENGECEKAN:',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              color: const Color(0xFF4A90D9),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        result.formDeskripsi!,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: const Color(0xFF2C1810),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: result.jawaban.entries.map((entry) {
                      final item = entry.key;
                      final detail = Map<String, dynamic>.from(entry.value as Map);
                      final status = detail['status'] as String? ?? 'Baik';
                      final catatan = detail['catatan'] as String? ?? '';

                      Color badgeColor = const Color(0xFF5AB974);
                      if (status == 'Perlu Servis') badgeColor = const Color(0xFFE5B94C);
                      if (status == 'Kritis') badgeColor = const Color(0xFFD9614C);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF2C1810), width: 2),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.toUpperCase(),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      color: const Color(0xFF2C1810),
                                    ),
                                  ),
                                  if (catatan.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Catatan: $catatan',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                        color: const Color(0xFF2C1810).withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF2C1810), width: 1.5),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 9,
                                  color: status == 'Perlu Servis' ? const Color(0xFF2C1810) : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // EDIT JAWABAN button
              InkWell(
                onTap: () {
                  Navigator.of(context).pop(); // Close sheet
                  final provider = context.read<ChecklistProvider>();
                  final form = provider.forms.firstWhere(
                    (f) => f.id == result.formId,
                    orElse: () => FormChecklistModel(
                      id: result.formId,
                      teknisiId: '',
                      judul: result.formJudul ?? 'Pengecekan Motor',
                      items: [],
                    ),
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FillChecklistScreen(
                        form: form,
                        result: result,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5B94C), // Retro Gold/Mustard
                    borderRadius: BorderRadius.circular(12),
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
                      'EDIT JAWABAN',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2C1810),
                      ),
                    ),
                  ),
                ),
               ),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                      ),
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
}

class FillChecklistScreen extends StatefulWidget {
  final FormChecklistModel form;
  final ChecklistResultModel? result; // Edit mode if not null

  const FillChecklistScreen({
    super.key,
    required this.form,
    this.result,
  });

  @override
  State<FillChecklistScreen> createState() => _FillChecklistScreenState();
}

class _FillChecklistScreenState extends State<FillChecklistScreen> {
  // Map of item name -> { 'status': 'Baik'/'Perlu Servis'/'Kritis', 'catatan': '' }
  final Map<String, Map<String, String>> _answers = {};
  final List<TextEditingController> _controllers = [];

  List<ChecklistItemModel> get _displayItems {
    if (widget.form.items.isNotEmpty) {
      return widget.form.items;
    }
    if (widget.result != null) {
      return widget.result!.jawaban.keys
          .map((key) => ChecklistItemModel(id: '', formId: widget.form.id, itemName: key))
          .toList();
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    final items = _displayItems;
    for (var item in items) {
      final existingDetail = widget.result?.jawaban[item.itemName];
      final String existingStatus = (existingDetail is Map) ? (existingDetail['status'] as String? ?? 'Baik') : 'Baik';
      final String existingCatatan = (existingDetail is Map) ? (existingDetail['catatan'] as String? ?? '') : '';

      _answers[item.itemName] = {
        'status': existingStatus,
        'catatan': existingCatatan,
      };
      _controllers.add(TextEditingController(text: existingCatatan));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD0),
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
          SafeArea(
            child: Column(
              children: [
                // Custom Retro AppBar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9614C),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF2C1810), width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF2C1810),
                          offset: Offset(8, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                (widget.result != null
                                    ? 'EDIT: ${widget.form.judul}'
                                    : widget.form.judul).toUpperCase(),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5B94C),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF2C1810), width: 1.5),
                                ),
                                child: Text(
                                  'KATEGORI: ${widget.form.kategori.toUpperCase()}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 9,
                                    color: const Color(0xFF2C1810),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48), // Spacer to balance back button
                      ],
                    ),
                  ),
                ),

                // Deskripsi / Cara Pengecekan
                if (widget.form.deskripsi != null && widget.form.deskripsi!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90D9).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF4A90D9).withValues(alpha: 0.3), width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF4A90D9)),
                              const SizedBox(width: 8),
                              Text(
                                'CARA PENGECEKAN:',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  color: const Color(0xFF4A90D9),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.form.deskripsi!,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: const Color(0xFF2C1810),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _displayItems.length,
                    itemBuilder: (context, index) {
                      final item = _displayItems[index];
                      final itemName = item.itemName;
                      final currentStatus = _answers[itemName]?['status'] ?? 'Baik';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ${itemName.toUpperCase()}',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: const Color(0xFF2C1810),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Status selector row
                            Row(
                              children: [
                                _buildStatusButton(itemName, 'Baik', const Color(0xFF5AB974), currentStatus == 'Baik'),
                                const SizedBox(width: 8),
                                _buildStatusButton(itemName, 'Perlu Servis', const Color(0xFFE5B94C), currentStatus == 'Perlu Servis'),
                                const SizedBox(width: 8),
                                _buildStatusButton(itemName, 'Kritis', const Color(0xFFD9614C), currentStatus == 'Kritis'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Note input
                            TextField(
                              controller: _controllers[index],
                              onChanged: (val) {
                                _answers[itemName]?['catatan'] = val;
                              },
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: const Color(0xFF2C1810),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Tambahkan catatan jika perlu...',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: const Color(0xFF2C1810).withValues(alpha: 0.4),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF4EBD0).withValues(alpha: 0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF2C1810), width: 2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF2C1810), width: 2.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Submit Button Area
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: InkWell(
                    onTap: _submitChecklist,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5B94C), // Retro Gold/Mustard
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2C1810), width: 4),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF2C1810),
                            offset: Offset(4, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.result != null ? 'PERBARUI HASIL PENGECEKAN' : 'KIRIM HASIL PENGECEKAN',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF2C1810),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String itemName, String status, Color color, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _answers[itemName]?['status'] = status;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF2C1810), width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            status.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              fontSize: 10,
              color: isSelected && status != 'Perlu Servis' ? Colors.white : const Color(0xFF2C1810),
            ),
          ),
        ),
      ),
    );
  }

  void _submitChecklist() async {
    final provider = context.read<ChecklistProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2C1810),
          strokeWidth: 4,
        ),
      ),
    );

    final success = widget.result != null
        ? await provider.updateResult(
            resultId: widget.result!.id,
            jawaban: _answers,
          )
        : await provider.submitResult(
            formId: widget.form.id,
            jawaban: _answers,
          );

    if (mounted) {
      Navigator.of(context).pop(); // Dismiss loading
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF5AB974),
            content: Text(
              widget.result != null
                  ? 'Hasil checklist berhasil diperbarui!'
                  : 'Hasil checklist berhasil dikirim!',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        );
        Navigator.of(context).pop(); // Back to main screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFD9614C),
            content: Text(
              provider.errorMessage ?? 'Gagal memproses checklist.',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        );
      }
    }
  }
}
