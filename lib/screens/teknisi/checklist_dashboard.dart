import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/checklist_model.dart';

class ChecklistDashboard extends StatefulWidget {
  final List<ChecklistResultModel> results;
  final List<FormChecklistModel> forms;
  final Function(ChecklistResultModel) onEvaluate;

  const ChecklistDashboard({
    super.key,
    required this.results,
    required this.forms,
    required this.onEvaluate,
  });

  @override
  State<ChecklistDashboard> createState() => _ChecklistDashboardState();
}

class _ChecklistDashboardState extends State<ChecklistDashboard> {
  String _selectedKategori = 'all'; // 'all', 'Harian', 'Mingguan', 'Bulanan'

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    // 1. Filter results based on selected category
    final filteredResults = widget.results.where((r) {
      if (_selectedKategori != 'all' && (r.formKategori ?? 'Harian') != _selectedKategori) return false;
      return true;
    }).toList();

    // 2. Count overall statuses
    int totalSubmissions = filteredResults.length;
    int countBaik = 0;
    int countPerluServis = 0;
    int countKritis = 0;

    for (var result in filteredResults) {
      for (var val in result.jawaban.values) {
        if (val is Map) {
          final status = val['status'] as String?;
          if (status == 'Baik') {
            countBaik++;
          } else if (status == 'Perlu Servis') {
            countPerluServis++;
          } else if (status == 'Kritis') {
            countKritis++;
          }
        }
      }
    }

    // 3. Aggregate statistics per parameter
    final Map<String, Map<String, int>> parameterStats = {};
    for (var result in filteredResults) {
      for (var entry in result.jawaban.entries) {
        final paramName = entry.key;
        final val = entry.value;
        if (val is Map) {
          final status = val['status'] as String? ?? 'Baik';
          parameterStats.putIfAbsent(paramName, () => {'Baik': 0, 'Perlu Servis': 0, 'Kritis': 0});
          parameterStats[paramName]![status] = (parameterStats[paramName]![status] ?? 0) + 1;
        }
      }
    }



    // 4. Identify results needing follow-up (monitoring)
    // Filter results that contain at least one 'Kritis' or 'Perlu Servis'
    final followUpResults = filteredResults.where((result) {
      for (var val in result.jawaban.values) {
        if (val is Map) {
          final status = val['status'] as String?;
          if (status == 'Kritis' || status == 'Perlu Servis') {
            return true;
          }
        }
      }
      return false;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['all', 'Harian', 'Mingguan', 'Bulanan'].map((cat) {
                final isSelected = _selectedKategori == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedKategori = cat;
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
                        cat == 'all' ? 'SEMUA KATEGORI' : cat.toUpperCase(),
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
          const SizedBox(height: 16),

          // KPI Summary Cards
          _buildKPISummary(
            totalSubmissions: totalSubmissions,
            countBaik: countBaik,
            countPerluServis: countPerluServis,
            countKritis: countKritis,
          ),
          const SizedBox(height: 24),

          // Section 1: Parameter-based Statistics
          Text(
            'STATISTIK KONDISI PARAMETER',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: const Color(0xFF2C1810),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildParameterStats(parameterStats),
          const SizedBox(height: 24),

          // Section 2: Monitoring & Alerts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MONITORING TINDAK LANJUT',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: const Color(0xFF2C1810),
                  letterSpacing: 0.5,
                ),
              ),
              if (followUpResults.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9614C),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2C1810), width: 1.5),
                  ),
                  child: Text(
                    '${followUpResults.length} ISU',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900,
                      fontSize: 8,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildFollowUpList(followUpResults),
        ],
      ),
    );
  }



  Widget _buildKPISummary({
    required int totalSubmissions,
    required int countBaik,
    required int countPerluServis,
    required int countKritis,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildKPICard(
                title: 'TANGGAPAN',
                value: totalSubmissions.toString(),
                color: const Color(0xFF4A90D9), // Blue
                textColor: Colors.white,
              ),
              const SizedBox(height: 8),
              _buildKPICard(
                title: 'PERLU SERVIS',
                value: countPerluServis.toString(),
                color: const Color(0xFFE5B94C), // Yellow
                textColor: const Color(0xFF2C1810),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              _buildKPICard(
                title: 'KONDISI BAIK',
                value: countBaik.toString(),
                color: const Color(0xFF5AB974), // Green
                textColor: Colors.white,
              ),
              const SizedBox(height: 8),
              _buildKPICard(
                title: 'KRITIS',
                value: countKritis.toString(),
                color: const Color(0xFFD9614C), // Red
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              fontSize: 10,
              color: textColor.withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterStats(Map<String, Map<String, int>> stats) {
    if (stats.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2C1810), width: 3),
        ),
        child: Center(
          child: Text(
            'Belum ada data parameter untuk form ini.',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: const Color(0xFF2C1810).withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: stats.entries.map((entry) {
          final paramName = entry.key;
          final itemStats = entry.value;
          final baik = itemStats['Baik'] ?? 0;
          final perluServis = itemStats['Perlu Servis'] ?? 0;
          final kritis = itemStats['Kritis'] ?? 0;
          final total = baik + perluServis + kritis;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      paramName.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: const Color(0xFF2C1810),
                      ),
                    ),
                    Text(
                      '$total Tanggapan',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        color: const Color(0xFF2C1810).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ChecklistProgressBar(
                  baikCount: baik,
                  perluServisCount: perluServis,
                  kritisCount: kritis,
                ),
                const SizedBox(height: 4),
                // Legend with counts and percentages
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLegendItem('Baik', baik, total, const Color(0xFF5AB974)),
                    _buildLegendItem('Perlu Servis', perluServis, total, const Color(0xFFE5B94C)),
                    _buildLegendItem('Kritis', kritis, total, const Color(0xFFD9614C)),
                  ],
                ),
                if (entry.key != stats.keys.last) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF2C1810), thickness: 1.5),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, int total, Color color) {
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF2C1810), width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $count ($pct%)',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 9,
            color: const Color(0xFF2C1810).withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFollowUpList(List<ChecklistResultModel> results) {
    if (results.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
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
            const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF5AB974), size: 40),
            const SizedBox(height: 12),
            Text(
              'SEMUA AMAN!',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: const Color(0xFF2C1810),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tidak ada tanggapan user dengan kondisi Kritis atau Perlu Servis saat ini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: const Color(0xFF2C1810).withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        final formattedDate = result.createdAt != null ? _formatDate(result.createdAt!.toLocal()) : 'Baru saja';
        final hasFeedback = result.feedback != null && result.feedback!.isNotEmpty;

        // Find which parameters are not 'Baik'
        final List<MapEntry<String, String>> issues = [];
        for (var entry in result.jawaban.entries) {
          final detail = Map<String, dynamic>.from(entry.value as Map);
          final status = detail['status'] as String? ?? 'Baik';
          if (status != 'Baik') {
            issues.add(MapEntry(entry.key, status));
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
              // Header status badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: hasFeedback ? const Color(0xFF2C1810) : const Color(0xFFD9614C),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hasFeedback ? 'SUDAH DITINDAKLANJUTI' : 'BUTUH SARAN / TINDAKAN',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Icon(
                      hasFeedback ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
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
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFFF4EBD0),
                          backgroundImage: NetworkImage(
                            'https://ui-avatars.com/api/?name=${result.userName?.replaceAll(' ', '+') ?? 'User'}&background=D9614C&color=fff',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (result.userName ?? 'MAHASISWI').toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  color: const Color(0xFF2C1810),
                                ),
                              ),
                              Text(
                                '$formattedDate • ${result.formJudul ?? 'Checklist'}',
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
                    const SizedBox(height: 12),

                    Text(
                      'PARAMETER BERMASALAH:',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                        color: const Color(0xFF2C1810).withValues(alpha: 0.7),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Issues wrap
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: issues.map((issue) {
                        final isKritis = issue.value == 'Kritis';
                        final color = isKritis ? const Color(0xFFD9614C) : const Color(0xFFE5B94C);

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: color, width: 1.5),
                          ),
                          child: Text(
                            '${issue.key}: ${issue.value}',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                              color: color,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    if (hasFeedback) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4EBD0),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF2C1810), width: 1.5),
                        ),
                        child: Text(
                          'SARAN: ${result.feedback}',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: const Color(0xFF2C1810),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Evaluate action button
                    InkWell(
                      onTap: () => widget.onEvaluate(result),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: hasFeedback ? Colors.white : const Color(0xFFE5B94C),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2C1810), width: 2.5),
                        ),
                        child: Center(
                          child: Text(
                            hasFeedback ? 'LIHAT DETAIL / UBAH SARAN' : 'BERI SARAN SEKARANG',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF2C1810),
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
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
}

class ChecklistProgressBar extends StatelessWidget {
  final int baikCount;
  final int perluServisCount;
  final int kritisCount;

  const ChecklistProgressBar({
    super.key,
    required this.baikCount,
    required this.perluServisCount,
    required this.kritisCount,
  });

  @override
  Widget build(BuildContext context) {
    final total = baikCount + perluServisCount + kritisCount;
    if (total == 0) {
      return Container(
        height: 18,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF4EBD0).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF2C1810), width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          'BELUM ADA DATA',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            fontSize: 8,
            color: const Color(0xFF2C1810).withValues(alpha: 0.4),
          ),
        ),
      );
    }

    return Container(
      height: 18,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF2C1810), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          if (baikCount > 0)
            Expanded(
              flex: baikCount,
              child: Container(
                color: const Color(0xFF5AB974), // Green
              ),
            ),
          if (perluServisCount > 0)
            Expanded(
              flex: perluServisCount,
              child: Container(
                color: const Color(0xFFE5B94C), // Yellow
              ),
            ),
          if (kritisCount > 0)
            Expanded(
              flex: kritisCount,
              child: Container(
                color: const Color(0xFFD9614C), // Red
              ),
            ),
        ],
      ),
    );
  }
}
