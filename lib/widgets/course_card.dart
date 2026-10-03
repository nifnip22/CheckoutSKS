import 'package:flutter/material.dart';
import '../models/course.dart';
import '../theme/app_theme.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final bool isSelected;
  final bool isLocked;
  final bool exceedsQuota;
  final VoidCallback onTake;

  const CourseCard({
    super.key,
    required this.course,
    required this.isSelected,
    this.isLocked = false,
    this.exceedsQuota = false,
    required this.onTake,
  });

  @override
  Widget build(BuildContext context) {
    final isQuotaAvailable = course.sisaKuota > 0;
    final isTakeable =
        !isSelected && isQuotaAvailable && !exceedsQuota && !isLocked;

    String buttonText;
    if (isLocked) {
      buttonText = 'Wajib (Terkunci)';
    } else if (isSelected) {
      buttonText = 'Diambil';
    } else if (exceedsQuota) {
      buttonText = 'Kuota SKS Tidak Cukup';
    } else if (!isQuotaAvailable) {
      buttonText = 'Penuh';
    } else {
      buttonText = 'Ambil';
    }

    return Card(
      color: AppTheme.surfaceWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: const BorderSide(color: AppTheme.borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Kode MK Box & Tipe Badge (Tanpa Favorit, Revisi 2)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.tintMaroon,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      course.kode,
                      style: const TextStyle(
                        color: AppTheme.primaryMaroon,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: course.tipe == CourseType.wajib
                          ? AppTheme.tintMaroon
                          : const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      course.tipe.label,
                      style: TextStyle(
                        color: course.tipe == CourseType.wajib
                            ? AppTheme.primaryMaroon
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Course Name
              SizedBox(
                height: 42,
                child: Text(
                  course.namaMk,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Lecturer info
              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 15,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      course.namaDosen,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // SKS & Quota
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${course.sks} SKS',
                    style: const TextStyle(
                      color: AppTheme.primaryMaroon,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Sisa kuota: ${course.sisaKuota}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action Button (Pill width fill)
              SizedBox(
                width: double.infinity,
                height: 38,
                child: FilledButton(
                  onPressed: isTakeable ? onTake : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryMaroon,
                    foregroundColor: AppTheme.surfaceWhite,
                    disabledBackgroundColor: isLocked
                        ? AppTheme.tintMaroon
                        : const Color(0xFFE5E7EB),
                    disabledForegroundColor: isLocked
                        ? AppTheme.primaryMaroon
                        : const Color(0xFF9CA3AF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  child: Text(
                    buttonText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
}
