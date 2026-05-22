import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/motorcycle_model.dart';
import '../../models/monitoring_model.dart';
import '../../models/checklist_model.dart';
import '../../providers/teknisi_provider.dart';
import '../../providers/checklist_provider.dart';

class UserDetailScreen extends StatefulWidget {
  final UserModel user;
  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<TeknisiProvider>().fetchMonitoringForUser(widget.user.id);
        context.read<ChecklistProvider>().fetchResults(isTeknisi: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TeknisiProvider>();
    final cp = context.watch<ChecklistProvider>();
    final motors = tp.getMotorcyclesForUser(widget.user.id);
    
    final monitoringList = tp.monitoringList;
    final checklistResults = cp.results.where((r) => r.userId == widget.user.id).toList();

    final combinedHistory = <dynamic>[...monitoringList, ...checklistResults];
    combinedHistory.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD0),
      body: Stack(
        children: [
          Positioned.fill(child: Opacity(opacity: 0.05, child: Image.network('https://www.transparenttextures.com/patterns/carbon-fibre.png', repeat: ImageRepeat.repeat))),
          SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2C1810), width: 3), boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(3, 3))]),
                        child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2C1810)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(color: const Color(0xFF4A90D9), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2C1810), width: 3), boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4))]),
                        child: Text('DETAIL USER', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 1)),
                      ),
                    ),
                  ]),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildProfileCard(),
                      const SizedBox(height: 24),
                      _buildMotorcyclesSection(motors),
                      const SizedBox(height: 24),
                      _buildMonitoringSection(combinedHistory, motors),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final u = widget.user;
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2C1810), width: 3), boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(4, 4))]),
      child: Column(children: [
        Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(color: Color(0xFF2C1810), borderRadius: BorderRadius.only(topLeft: Radius.circular(17), topRight: Radius.circular(17))),
          child: Row(children: [
            GestureDetector(
              onTap: () {
                final url = u.avatarUrl ??
                    'https://ui-avatars.com/api/?name=${u.name.replaceAll(' ', '+')}&background=E5B94C&color=2C1810&size=512';
                _showFullScreenImage(context, url, u.name);
              },
              child: CircleAvatar(
                radius: 28, backgroundColor: const Color(0xFFE5B94C),
                backgroundImage: u.avatarUrl != null ? NetworkImage(u.avatarUrl!) : null,
                child: u.avatarUrl == null ? Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : '?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 22, color: const Color(0xFF2C1810))) : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(u.name.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFFF4EBD0))),
              Text(u.email, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFF4EBD0).withValues(alpha: 0.7))),
            ])),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            _infoChip(Icons.phone_rounded, u.phone ?? '-'),
            const SizedBox(width: 12),
            _infoChip(Icons.calendar_today_rounded, u.createdAt != null ? '${u.createdAt!.day}/${u.createdAt!.month}/${u.createdAt!.year}' : '-'),
          ]),
        ),
      ]),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF4EBD0), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF2C1810), width: 2)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: const Color(0xFF2C1810)),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF2C1810))),
      ]),
    );
  }

  Widget _buildMotorcyclesSection(List<MotorcycleModel> motors) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('MOTOR USER', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810), letterSpacing: 0.5)),
      const SizedBox(height: 12),
      if (motors.isEmpty)
        Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2C1810), width: 2)),
          child: Text('Belum ada motor terdaftar', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF2C1810).withValues(alpha: 0.5))),
        )
      else
        ...motors.map((m) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2C1810), width: 3), boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(3, 3))]),
          child: Row(children: [
            GestureDetector(
              onTap: m.imageUrl != null ? () => _showFullScreenImage(context, m.imageUrl!, '${m.brand} ${m.model}') : null,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5B94C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2C1810), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: m.imageUrl != null
                      ? Image.network(
                          m.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Icon(Icons.two_wheeler_rounded, color: Color(0xFF2C1810), size: 24),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${m.brand} ${m.model}'.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
              Row(children: [
                Text(m.plateNumber, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF2C1810).withValues(alpha: 0.6))),
                if (m.year != null) ...[
                  Text(' • ', style: TextStyle(color: const Color(0xFF2C1810).withValues(alpha: 0.4))),
                  Text('${m.year}', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF2C1810).withValues(alpha: 0.6))),
                ],
              ]),
            ])),
          ]),
        )),
    ]);
  }

  Widget _buildMonitoringSection(List<dynamic> list, List<MotorcycleModel> motors) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('RIWAYAT MONITORING', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810), letterSpacing: 0.5)),
      const SizedBox(height: 12),
      if (list.isEmpty)
        Container(
          width: double.infinity, padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2C1810), width: 2)),
          child: Column(children: [
            const Icon(Icons.assignment_outlined, size: 40, color: Color(0xFF2C1810)),
            const SizedBox(height: 8),
            Text('Belum ada catatan monitoring', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF2C1810).withValues(alpha: 0.5))),
          ]),
        )
      else
        ...list.map((item) {
          if (item is MonitoringModel) {
            return _buildMonitoringCard(item);
          } else if (item is ChecklistResultModel) {
            return _buildChecklistResultCard(item);
          }
          return const SizedBox();
        }),
    ]);
  }

  Widget _buildMonitoringCard(MonitoringModel m) {
    Color statusColor;
    switch (m.status) {
      case 'kritis': statusColor = const Color(0xFFFF5A5F); break;
      case 'perlu_perhatian': statusColor = const Color(0xFFE5B94C); break;
      default: statusColor = const Color(0xFF81C995); break;
    }
    final dateStr = m.createdAt != null ? '${m.createdAt!.day}/${m.createdAt!.month}/${m.createdAt!.year}' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2C1810), width: 3), boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(3, 3))]),
      child: Column(children: [
        // Header
        Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: statusColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(m.statusLabel.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
            Text(dateStr, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF2C1810).withValues(alpha: 0.7))),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (m.motorcycleName != null && m.motorcycleName!.isNotEmpty) ...[
              Row(children: [
                const Icon(Icons.two_wheeler_rounded, size: 14, color: Color(0xFF4A90D9)),
                const SizedBox(width: 6),
                Text(m.motorcycleName!.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF4A90D9))),
              ]),
              const SizedBox(height: 12),
            ],
            if (m.catatan != null && m.catatan!.isNotEmpty) ...[
              Text('CATATAN', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810).withValues(alpha: 0.5))),
              const SizedBox(height: 4),
              Text(m.catatan!, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF2C1810))),
              const SizedBox(height: 12),
            ],
            if (m.rekomendasi != null && m.rekomendasi!.isNotEmpty) ...[
              Text('REKOMENDASI', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810).withValues(alpha: 0.5))),
              const SizedBox(height: 4),
              Container(
                width: double.infinity, padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF4A90D9).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF4A90D9), width: 1.5)),
                child: Text(m.rekomendasi!, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF2C1810))),
              ),
            ],
          ]),
        ),
      ]),
    );
  }

  Widget _buildChecklistResultCard(ChecklistResultModel r) {
    final hasFeedback = r.feedback != null && r.feedback!.isNotEmpty;
    final dateStr = r.createdAt != null ? '${r.createdAt!.day}/${r.createdAt!.month}/${r.createdAt!.year}' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C1810), width: 3),
        boxShadow: const [BoxShadow(color: Color(0xFF2C1810), offset: Offset(3, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: hasFeedback ? const Color(0xFF2C1810) : const Color(0xFF4A90D9),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'CHECKLIST: ${(r.formJudul ?? "Pengecekan").toUpperCase()}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  dateStr,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.7),
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
                // Checklist Status Header
                Text(
                  'STATUS JAWABAN USER',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2C1810).withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 6),
                // Render jawaban map
                ...r.jawaban.entries.map((entry) {
                  final itemName = entry.key;
                  final itemData = entry.value;
                  String status = '-';
                  String? catatan;
                  
                  if (itemData is Map) {
                    status = itemData['status']?.toString() ?? '-';
                    catatan = itemData['catatan']?.toString();
                  } else {
                    status = itemData?.toString() ?? '-';
                  }

                  // Determine status icon and color
                  IconData statusIcon = Icons.help_outline_rounded;
                  Color statusColor = const Color(0xFF2C1810);
                  if (status.toLowerCase().contains('baik')) {
                    statusIcon = Icons.check_circle_rounded;
                    statusColor = const Color(0xFF81C995);
                  } else if (status.toLowerCase().contains('perhatian')) {
                    statusIcon = Icons.warning_rounded;
                    statusColor = const Color(0xFFE5B94C);
                  } else if (status.toLowerCase().contains('rusak') || status.toLowerCase().contains('kritis') || status.toLowerCase().contains('perbaikan')) {
                    statusIcon = Icons.cancel_rounded;
                    statusColor = const Color(0xFFFF5A5F);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF2C1810),
                              ),
                              children: [
                                TextSpan(
                                  text: '${itemName.toUpperCase()}: ',
                                  style: const TextStyle(fontWeight: FontWeight.w900),
                                ),
                                TextSpan(
                                  text: status,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: statusColor,
                                  ),
                                ),
                                if (catatan != null && catatan.isNotEmpty)
                                  TextSpan(
                                    text: ' ($catatan)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2C1810).withValues(alpha: 0.6),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                
                const SizedBox(height: 12),
                
                // Feedback section
                Text(
                  'FEEDBACK TEKNISI',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2C1810).withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 6),
                if (hasFeedback)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C1810).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF2C1810), width: 1.5),
                    ),
                    child: Text(
                      r.feedback!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2C1810),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5A5F).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFF5A5F), width: 1.5),
                    ),
                    child: Text(
                      'Belum ada feedback dari Anda.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFF5A5F),
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

  void _showFullScreenImage(BuildContext context, String imageUrl, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
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
          ),
        ),
      ),
    );
  }
}
