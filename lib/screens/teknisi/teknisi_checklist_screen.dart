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

class TeknisiChecklistScreen extends StatefulWidget {
  const TeknisiChecklistScreen({super.key});

  @override
  State<TeknisiChecklistScreen> createState() => _TeknisiChecklistScreenState();
}

class _TeknisiChecklistScreenState extends State<TeknisiChecklistScreen> {
  int _activeTab = 0; // 0 = Form Checklist, 1 = Hasil User

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ChecklistProvider>().fetchForms();
        context.read<ChecklistProvider>().fetchResults(isTeknisi: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Texture in MainScreen
      body: SafeArea(
        child: Column(
          children: [
            // Branded Retro AppBar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90D9), // Teknisi Blue
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
                  'CHECKLIST MONITORING',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            // Tab Toggles
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
                          color: _activeTab == 0 ? const Color(0xFF4A90D9) : Colors.white,
                          border: Border.all(color: const Color(0xFF2C1810), width: 3),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'KELOLA FORM',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: _activeTab == 0 ? Colors.white : const Color(0xFF2C1810),
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
                          color: _activeTab == 1 ? const Color(0xFF4A90D9) : Colors.white,
                          border: Border.all(color: const Color(0xFF2C1810), width: 3),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'HASIL USER',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: _activeTab == 1 ? Colors.white : const Color(0xFF2C1810),
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

            // Main Content Area
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF2C1810),
                backgroundColor: const Color(0xFFF4EBD0),
                onRefresh: () async {
                  await context.read<ChecklistProvider>().fetchForms();
                  await context.read<ChecklistProvider>().fetchResults(isTeknisi: true);
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
                      return _buildFormsSection(provider.forms);
                    } else {
                      return _buildResultsSection(provider.results);
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

  Widget _buildFormsSection(List<FormChecklistModel> forms) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: _openCreateFormPage,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFE5B94C), // Retro Gold/Mustard
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2C1810), width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF2C1810),
                    offset: Offset(4, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_box_rounded, color: Color(0xFF2C1810)),
                  const SizedBox(width: 8),
                  Text(
                    'BUAT FORM CHECKLIST BARU',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF2C1810),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: forms.isEmpty
              ? _buildEmptyState('BELUM ADA FORM', 'Ketuk tombol di atas untuk membuat checklist pengecekan mingguan pertama Anda.')
              : ListView.builder(
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2C1810),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'FORM MINGGUAN',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFFF4EBD0),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _confirmDeleteForm(form.id),
                                  child: const Icon(
                                    Icons.delete_forever_rounded,
                                    color: Color(0xFFD9614C), // Retro Red
                                    size: 20,
                                  ),
                                ),
                              ],
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
                                  form.deskripsi ?? 'Pengecekan rutin parameter motor.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: const Color(0xFF2C1810).withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: form.items.map((item) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4EBD0),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFF2C1810), width: 1.5),
                                      ),
                                      child: Text(
                                        item.itemName.toUpperCase(),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 9,
                                          color: const Color(0xFF2C1810),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildResultsSection(List<ChecklistResultModel> results) {
    if (results.isEmpty) {
      return _buildEmptyState('BELUM ADA TANGGAPAN', 'Belum ada user yang mengirimkan checklist mereka.');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        final formattedDate = result.createdAt != null
            ? _formatDate(result.createdAt!.toLocal())
            : 'Hari ini';

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
                  color: hasFeedback ? const Color(0xFF2C1810) : const Color(0xFF4A90D9),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hasFeedback ? 'SUDAH DIBERI SARAN' : 'PERLU EVALUASI',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C1810),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF2C1810), width: 1.5),
                          ),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFFF4EBD0),
                            backgroundImage: NetworkImage(
                              'https://ui-avatars.com/api/?name=${result.userName?.replaceAll(' ', '+') ?? 'User'}&background=D9614C&color=fff',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (result.userName ?? 'MAHASISWI').toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: const Color(0xFF2C1810),
                                ),
                              ),
                              Text(
                                'Dikirim: $formattedDate',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  color: const Color(0xFF2C1810).withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'TIPE FORM: ${result.formJudul?.toUpperCase() ?? 'CHECKLIST'}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2C1810).withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Answers preview
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: result.jawaban.entries.map((entry) {
                        final String item = entry.key;
                        final Map<String, dynamic> detail = Map<String, dynamic>.from(entry.value as Map);
                        final String status = detail['status'] as String? ?? 'Baik';

                        Color statusColor = const Color(0xFF5AB974);
                        if (status == 'Perlu Servis') statusColor = const Color(0xFFE5B94C);
                        if (status == 'Kritis') statusColor = const Color(0xFFD9614C);

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: statusColor, width: 1.5),
                          ),
                          child: Text(
                            '$item: $status',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                              color: statusColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    if (hasFeedback) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4EBD0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2C1810), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SARAN ANDA:',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                fontSize: 9,
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
                    ],
                    InkWell(
                      onTap: () => _openEvaluateScreen(result),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: hasFeedback ? Colors.white : const Color(0xFFE5B94C),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2C1810), width: 2.5),
                        ),
                        child: Center(
                          child: Text(
                            hasFeedback ? 'LIHAT DETAIL JAWABAN' : 'BERI SARAN / FEEDBACK',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF2C1810),
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
              Icons.checklist_rounded,
              size: 48,
              color: Color(0xFF4A90D9),
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

  void _openCreateFormPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateChecklistFormScreen(),
      ),
    );
  }

  void _confirmDeleteForm(String formId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF4EBD0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2C1810), width: 4),
        ),
        title: Text(
          'HAPUS FORM?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: const Color(0xFF2C1810)),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus form checklist ini? Seluruh data riwayat checklist user yang terkait juga akan dihapus.',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF2C1810)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'BATAL',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: const Color(0xFF2C1810)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD9614C),
              side: const BorderSide(color: Color(0xFF2C1810), width: 2),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await context.read<ChecklistProvider>().deleteForm(formId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF5AB974),
                    content: Text(
                      'Form berhasil dihapus!',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                );
              }
            },
            child: Text(
              'HAPUS',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _openEvaluateScreen(ChecklistResultModel result) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EvaluateChecklistScreen(result: result),
      ),
    );
  }
}

class CreateChecklistFormScreen extends StatefulWidget {
  const CreateChecklistFormScreen({super.key});

  @override
  State<CreateChecklistFormScreen> createState() => _CreateChecklistFormScreenState();
}

class _CreateChecklistFormScreenState extends State<CreateChecklistFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final List<TextEditingController> _itemControllers = [
    TextEditingController(text: 'Oli Mesin'),
    TextEditingController(text: 'Rem'),
    TextEditingController(text: 'Ban'),
    TextEditingController(text: 'Lampu & Kelistrikan'),
  ];

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    for (var ctrl in _itemControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD0),
      body: Stack(
        children: [
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // App Bar Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90D9),
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
                            child: Text(
                              'BUAT FORM CHECKLIST',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Judul
                          Text(
                            'JUDUL CHECKLIST',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              color: const Color(0xFF2C1810),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _judulController,
                            validator: (val) => val == null || val.isEmpty ? 'Judul wajib diisi' : null,
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14),
                            decoration: _inputDecoration('Contoh: Pengecekan Rutin Mingguan'),
                          ),
                          const SizedBox(height: 20),

                          // Deskripsi
                          Text(
                            'DESKRIPSI / PETUNJUK PENGISIAN',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              color: const Color(0xFF2C1810),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _deskripsiController,
                            maxLines: 2,
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14),
                            decoration: _inputDecoration('Petunjuk pengisian untuk mahasiswi...'),
                          ),
                          const SizedBox(height: 24),

                          // Parameters/Items
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'PARAMETER PENGECEKAN',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  color: const Color(0xFF2C1810),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _itemControllers.add(TextEditingController());
                                  });
                                },
                                icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF4A90D9), size: 18),
                                label: Text(
                                  'TAMBAH',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF4A90D9),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _itemControllers.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _itemControllers[index],
                                        validator: (val) => val == null || val.isEmpty ? 'Parameter wajib diisi' : null,
                                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14),
                                        decoration: _inputDecoration('Nama parameter, misal: Tekanan Ban'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _itemControllers[index].dispose();
                                          _itemControllers.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD9614C),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFF2C1810), width: 2.5),
                                        ),
                                        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Submit button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: InkWell(
                      onTap: _submitForm,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90D9),
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
                            'SIMPAN DAN SEBARKAN',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
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
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        color: const Color(0xFF2C1810).withValues(alpha: 0.4),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2C1810), width: 2.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2C1810), width: 3),
      ),
    );
  }

  void _submitForm() async {
    if (_itemControllers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFD9614C),
          content: Text(
            'Form harus memiliki minimal 1 parameter pengecekan!',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

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

    final itemNames = _itemControllers.map((ctrl) => ctrl.text.trim()).where((t) => t.isNotEmpty).toList();

    final success = await provider.createForm(
      judul: _judulController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      itemNames: itemNames,
    );

    if (mounted) {
      Navigator.of(context).pop(); // pop progress
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF5AB974),
            content: Text(
              'Form checklist berhasil dipublikasikan!',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFD9614C),
            content: Text(
              provider.errorMessage ?? 'Gagal membuat form.',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        );
      }
    }
  }
}

class EvaluateChecklistScreen extends StatefulWidget {
  final ChecklistResultModel result;

  const EvaluateChecklistScreen({super.key, required this.result});

  @override
  State<EvaluateChecklistScreen> createState() => _EvaluateChecklistScreenState();
}

class _EvaluateChecklistScreenState extends State<EvaluateChecklistScreen> {
  final _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.result.feedback != null) {
      _feedbackController.text = widget.result.feedback!;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFeedback = widget.result.feedback != null && widget.result.feedback!.isNotEmpty;
    final formattedDate = widget.result.createdAt != null
        ? _formatDate(widget.result.createdAt!.toLocal())
        : 'Hari ini';

    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD0),
      body: Stack(
        children: [
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
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90D9),
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
                          child: Text(
                            'DETAIL JAWABAN',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF2C1810), width: 3),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFFF4EBD0),
                                backgroundImage: NetworkImage(
                                  'https://ui-avatars.com/api/?name=${widget.result.userName?.replaceAll(' ', '+') ?? 'User'}&background=D9614C&color=fff',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (widget.result.userName ?? 'MAHASISWI').toUpperCase(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                        color: const Color(0xFF2C1810),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Form: ${widget.result.formJudul ?? 'Checklist'}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: const Color(0xFF2C1810).withValues(alpha: 0.7),
                                      ),
                                    ),
                                    Text(
                                      'Dikirim: $formattedDate',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                        color: const Color(0xFF2C1810).withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          'PARAMETER & STATUS PENGECEKAN',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            color: const Color(0xFF2C1810),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // List answers
                        ...widget.result.jawaban.entries.map((entry) {
                          final item = entry.key;
                          final detail = Map<String, dynamic>.from(entry.value as Map);
                          final status = detail['status'] as String? ?? 'Baik';
                          final catatan = detail['catatan'] as String? ?? '';

                          Color badgeColor = const Color(0xFF5AB974);
                          if (status == 'Perlu Servis') badgeColor = const Color(0xFFE5B94C);
                          if (status == 'Kritis') badgeColor = const Color(0xFFD9614C);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF2C1810), width: 2.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.toUpperCase(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                        color: const Color(0xFF2C1810),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                                if (catatan.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Catatan User:',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      color: const Color(0xFF2C1810).withValues(alpha: 0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    catatan,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: const Color(0xFF2C1810),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 16),

                        // Feedback Form
                        Text(
                          'SARAN / REKOMENDASI TEKNISI',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            color: const Color(0xFF2C1810),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _feedbackController,
                          maxLines: 4,
                          enabled: !hasFeedback,
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Tulis saran, instruksi servis, atau instruksi tindak lanjut...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: const Color(0xFF2C1810).withValues(alpha: 0.4),
                            ),
                            filled: true,
                            fillColor: hasFeedback ? Colors.grey.shade200 : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF2C1810), width: 2.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF2C1810), width: 3),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Action Button
                if (!hasFeedback)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: InkWell(
                      onTap: _submitFeedback,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5B94C),
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
                            'KIRIM REKOMENDASI KE USER',
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

  void _submitFeedback() async {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFD9614C),
          content: Text(
            'Saran feedback tidak boleh kosong.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
      );
      return;
    }

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

    final success = await provider.submitFeedback(
      resultId: widget.result.id,
      feedback: _feedbackController.text.trim(),
    );

    if (mounted) {
      Navigator.of(context).pop(); // Pop loading
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF5AB974),
            content: Text(
              'Rekomendasi berhasil dikirim ke user!',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFD9614C),
            content: Text(
              provider.errorMessage ?? 'Gagal mengirim rekomendasi.',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        );
      }
    }
  }
}
