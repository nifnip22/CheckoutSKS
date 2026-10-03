import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';

class SuccessScreen extends StatelessWidget {
  final int totalMk;
  final int totalSks;
  final String kelas;
  final String nomorPengajuan;

  const SuccessScreen({
    super.key,
    required this.totalMk,
    required this.totalSks,
    required this.kelas,
    required this.nomorPengajuan,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBackground,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // Decorative Confetti & Success Badge Area
                      SizedBox(
                        height: 140,
                        width: double.infinity,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Confetti elements
                            ..._buildConfettiList(),

                            // Outer halo
                            Container(
                              width: 104,
                              height: 104,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.tintMaroon.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),

                            // Main circle with checkmark
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primaryMaroon,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: AppTheme.surfaceWhite,
                                size: 44,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Title & Subtitle
                      const Text(
                        'KRS Berhasil Diajukan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Menunggu persetujuan Dosen\nPembimbing Akademik',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Summary Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(
                            AppTheme.cardRadius,
                          ),
                          border: Border.all(color: AppTheme.borderColor),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow(
                              'No. Pengajuan',
                              nomorPengajuan,
                              isBoldValue: true,
                            ),
                            const SizedBox(height: 14),
                            _buildSummaryRow(
                              'Total Mata Kuliah',
                              '$totalMk',
                              isBoldValue: true,
                            ),
                            const SizedBox(height: 14),
                            _buildSummaryRow(
                              'Total SKS',
                              '$totalSks SKS',
                              valueColor: AppTheme.primaryMaroon,
                              isBoldValue: true,
                            ),
                            const SizedBox(height: 14),
                            _buildSummaryRow(
                              'Kelas Paralel',
                              kelas.replaceFirst('Kelas ', ''),
                              isBoldValue: true,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Status',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.statusAmberLight,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time_filled_rounded,
                                        size: 14,
                                        color: Color(0xFFD97706),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'Menunggu Persetujuan',
                                        style: TextStyle(
                                          color: Color(0xFFB45309),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Dotted / dashed line separator
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final boxWidth = constraints.constrainWidth();
                                const dashWidth = 5.0;
                                const dashSpace = 4.0;
                                final dashCount =
                                    (boxWidth / (dashWidth + dashSpace))
                                        .floor();
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: List.generate(dashCount, (_) {
                                    return const SizedBox(
                                      width: dashWidth,
                                      height: 1,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: AppTheme.borderColor,
                                        ),
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                            const SizedBox(height: 18),

                            // Academic Advisor Row
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.tintMaroon,
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: AppTheme.primaryMaroon,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Dosen Pembimbing Akademik',
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        advisor.nama,
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Info Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.tintMaroon.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(
                            AppTheme.cardRadius,
                          ),
                          border: Border.all(
                            color: AppTheme.primaryMaroon.withValues(
                              alpha: 0.15,
                            ),
                          ),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_rounded,
                              color: AppTheme.primaryMaroon,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Notifikasi akan dikirimkan setelah status pengajuan ditinjau oleh dosen pembimbing Anda.',
                                style: TextStyle(
                                  color: AppTheme.primaryMaroon,
                                  fontSize: 12.5,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Button: "Kembali ke Beranda"
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryMaroon,
                      foregroundColor: AppTheme.surfaceWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.pillRadius,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Kembali ke Beranda',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBoldValue = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildConfettiList() {
    return [
      // Top left ribbon
      Positioned(
        top: 15,
        left: 30,
        child: Transform.rotate(
          angle: -math.pi / 4,
          child: Container(
            width: 10,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.primaryMaroon.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
      // Left circle
      Positioned(
        top: 38,
        left: 55,
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: AppTheme.primaryMaroon.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
      ),
      // Left square
      Positioned(
        bottom: 30,
        left: 35,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFBDBDBD),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
      // Top right ribbon
      Positioned(
        top: 25,
        right: 40,
        child: Transform.rotate(
          angle: math.pi / 6,
          child: Container(
            width: 12,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.primaryMaroon.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
      // Right ring
      Positioned(
        top: 50,
        right: 60,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryMaroon.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
        ),
      ),
      // Right dot
      Positioned(
        bottom: 32,
        right: 45,
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: AppTheme.primaryMaroon.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
      ),
    ];
  }
}
