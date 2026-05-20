import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/motorcycle_model.dart';
import '../../models/monitoring_model.dart';
import '../../providers/teknisi_provider.dart';

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
    Future.microtask(() => context.read<TeknisiProvider>().fetchMonitoringForUser(widget.user.id));
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TeknisiProvider>();
    final motors = tp.getMotorcyclesForUser(widget.user.id);
    final monitoringList = tp.monitoringList;

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
                      _buildMonitoringSection(monitoringList, motors),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildAddMonitoringFAB(motors),
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
            CircleAvatar(
              radius: 28, backgroundColor: const Color(0xFFE5B94C),
              backgroundImage: u.avatarUrl != null ? NetworkImage(u.avatarUrl!) : null,
              child: u.avatarUrl == null ? Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : '?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 22, color: const Color(0xFF2C1810))) : null,
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFE5B94C), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2C1810), width: 2)),
              child: const Icon(Icons.two_wheeler_rounded, color: Color(0xFF2C1810), size: 24),
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

  Widget _buildMonitoringSection(List<MonitoringModel> list, List<MotorcycleModel> motors) {
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
        ...list.map((m) => _buildMonitoringCard(m)),
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

  Widget _buildAddMonitoringFAB(List<MotorcycleModel> motors) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddMonitoringDialog(motors),
      backgroundColor: const Color(0xFF4A90D9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF2C1810), width: 3)),
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text('MONITORING', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, color: Colors.white)),
    );
  }

  void _showAddMonitoringDialog(List<MotorcycleModel> motors) {
    String? selectedMotorcycleId = motors.isNotEmpty ? motors.first.id : null;
    String selectedStatus = 'baik';
    final catatanCtrl = TextEditingController();
    final rekomendasiCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF4EBD0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF2C1810), width: 4)),
          title: Text('TAMBAH MONITORING', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 16, color: const Color(0xFF2C1810))),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Motor Dropdown
            if (motors.isNotEmpty) ...[
              Text('MOTOR', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810).withValues(alpha: 0.6))),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2C1810), width: 2)),
                child: DropdownButton<String>(
                  value: selectedMotorcycleId, isExpanded: true, underline: const SizedBox(),
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF2C1810)),
                  items: motors.map((m) => DropdownMenuItem(value: m.id, child: Text('${m.brand} ${m.model}'))).toList(),
                  onChanged: (v) => setDialogState(() => selectedMotorcycleId = v),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Status
            Text('STATUS MOTOR', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810).withValues(alpha: 0.6))),
            const SizedBox(height: 6),
            Row(children: [
              _statusChip('baik', 'Baik', const Color(0xFF81C995), selectedStatus, (v) => setDialogState(() => selectedStatus = v)),
              const SizedBox(width: 8),
              _statusChip('perlu_perhatian', 'Perhatian', const Color(0xFFE5B94C), selectedStatus, (v) => setDialogState(() => selectedStatus = v)),
              const SizedBox(width: 8),
              _statusChip('kritis', 'Kritis', const Color(0xFFFF5A5F), selectedStatus, (v) => setDialogState(() => selectedStatus = v)),
            ]),
            const SizedBox(height: 16),

            // Catatan
            Text('CATATAN', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810).withValues(alpha: 0.6))),
            const SizedBox(height: 6),
            _dialogTextField(catatanCtrl, 'Tulis catatan...', maxLines: 3),
            const SizedBox(height: 16),

            // Rekomendasi
            Text('REKOMENDASI SERVIS', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810).withValues(alpha: 0.6))),
            const SizedBox(height: 6),
            _dialogTextField(rekomendasiCtrl, 'Tulis rekomendasi...', maxLines: 3),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('BATAL', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF2C1810)))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A90D9), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF2C1810), width: 2))),
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await context.read<TeknisiProvider>().addMonitoring(
                  userId: widget.user.id,
                  motorcycleId: selectedMotorcycleId,
                  catatan: catatanCtrl.text.isNotEmpty ? catatanCtrl.text : null,
                  rekomendasi: rekomendasiCtrl.text.isNotEmpty ? rekomendasiCtrl.text : null,
                  status: selectedStatus,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(success ? 'Monitoring berhasil ditambahkan!' : 'Gagal menambah monitoring'),
                    backgroundColor: success ? const Color(0xFF4A90D9) : const Color(0xFFFF5A5F),
                  ));
                }
              },
              child: Text('SIMPAN', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      }),
    );
  }

  Widget _statusChip(String value, String label, Color color, String current, Function(String) onTap) {
    final isSelected = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2C1810), width: isSelected ? 2.5 : 1.5),
        ),
        child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF2C1810))),
      ),
    );
  }

  Widget _dialogTextField(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2C1810), width: 2)),
      child: TextField(
        controller: ctrl, maxLines: maxLines,
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: const Color(0xFF2C1810)),
        decoration: InputDecoration(
          hintText: hint, hintStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: const Color(0xFF2C1810).withValues(alpha: 0.4)),
          border: InputBorder.none, contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}
