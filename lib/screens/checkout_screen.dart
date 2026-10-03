import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../logic/krs_logic.dart';
import '../models/class_section.dart';
import '../models/course.dart';
import '../theme/app_theme.dart';
import 'success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Course> selectedCourses;
  final VoidCallback onSubmitted;

  const CheckoutScreen({
    super.key,
    required this.selectedCourses,
    required this.onSubmitted,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Shift tunggal yang dipilih sekali di awal (Revisi 3)
  ClassShift? _selectedShift;

  // Pilihan kelas per mata kuliah
  final Map<String, ClassSection?> _selectedClasses = {};

  Future<void> _handleShiftChange(ClassShift? newShift) async {
    if (newShift == null || newShift == _selectedShift) return;

    final hasSelectedAnyClass = _selectedClasses.values.any(
      (section) => section != null,
    );

    if (hasSelectedAnyClass) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          ),
          title: const Text(
            'Ganti Shift Kelas?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          content: const Text(
            'Mengubah shift kelas akan mereset semua pilihan kelas mata kuliah yang telah Anda tentukan. Lanjutkan?',
            style: TextStyle(fontSize: 13.5, height: 1.3),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(
                'Batal',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryMaroon,
              ),
              child: const Text('Ganti Shift'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    setState(() {
      _selectedShift = newShift;
      _selectedClasses.clear();
    });
  }

  void _submitKrs() {
    final validationResult = KrsLogic.validateSubmissionWithShift(
      shift: _selectedShift,
      selectedCourses: widget.selectedCourses,
      selectedClasses: _selectedClasses,
      maxCreditLimit: maxSks,
    );

    if (!validationResult.isValid) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            validationResult.errorMessage ?? 'Pengajuan tidak valid.',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          backgroundColor: AppTheme.primaryMaroon,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: AppTheme.surfaceWhite,
            onPressed: () {},
          ),
        ),
      );
      return;
    }

    // Buat objek KrsSubmission dengan referensi ID matkul dan kode kelas
    final totalMk = widget.selectedCourses.length;
    final totalSks = KrsLogic.calculateTotalSks(widget.selectedCourses);

    final uniqueClasses = _selectedClasses.values
        .whereType<ClassSection>()
        .map((c) => c.code)
        .toSet()
        .toList();
    final summaryKelas =
        '${_selectedShift!.label} (${uniqueClasses.join(', ')})';

    // Bersihkan keranjang di HomeScreen
    widget.onSubmitted();

    // Buka SuccessScreen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => SuccessScreen(
          totalMk: totalMk,
          totalSks: totalSks,
          kelas: summaryKelas,
          nomorPengajuan: defaultApplicationNumber,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSks = KrsLogic.calculateTotalSks(widget.selectedCourses);
    final totalMk = widget.selectedCourses.length;

    // Filter daftar kelas berdasarkan shift yang dipilih
    final availableClassesForShift = _selectedShift == null
        ? <ClassSection>[]
        : availableClassSections
              .where((cs) => cs.shift == _selectedShift)
              .toList();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Pengajuan KRS',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Student Profile Card
                  _buildStudentCard(totalSks),
                  const SizedBox(height: 14),

                  // Collapsible Selected Courses Overview
                  _buildCourseExpansionCard(totalMk),
                  const SizedBox(height: 16),

                  // Section: Academic Advisor
                  const Text(
                    'DOSEN PEMBIMBING AKADEMIK',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildAdvisorCard(),
                  const SizedBox(height: 20),

                  // Section 1: Dropdown Shift Tunggal (Revisi 3)
                  const Text(
                    'SHIFT KELAS',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildShiftSelectorCard(),
                  const SizedBox(height: 18),

                  // Section 2: Tabel Informasi Jadwal (Revisi 4)
                  if (_selectedShift != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TABEL JADWAL KELAS',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          'Shift ${_selectedShift!.label}',
                          style: const TextStyle(
                            color: AppTheme.primaryMaroon,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildScheduleComparisonTable(availableClassesForShift),
                    const SizedBox(height: 20),
                  ],

                  // Section 3: Dropdown Kelas per Mata Kuliah (Revisi 3 & 4)
                  const Text(
                    'PILIH KELAS PER MATA KULIAH',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.selectedCourses.map(
                    (course) => _buildCourseClassPickerCard(
                      course,
                      availableClassesForShift,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Floating Bottom Checkout Bar
          _buildBottomBar(totalSks),
        ],
      ),
    );
  }

  Widget _buildStudentCard(int totalSks) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.tintMaroon,
            ),
            alignment: Alignment.center,
            child: Text(
              student.initials,
              style: const TextStyle(
                color: AppTheme.primaryMaroon,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.nama,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${student.programStudi} • Semester ${student.semester}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'NIM ${student.nim}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.tintMaroon,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$totalSks SKS',
              style: const TextStyle(
                color: AppTheme.primaryMaroon,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseExpansionCard(int totalMk) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.softShadow,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          ),
          leading: const Icon(
            Icons.menu_book_rounded,
            color: AppTheme.primaryMaroon,
            size: 22,
          ),
          title: Text(
            'Ringkasan Mata Kuliah ($totalMk)',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 14,
          ),
          children: widget.selectedCourses.map((course) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.tintMaroon,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      course.kode,
                      style: const TextStyle(
                        color: AppTheme.primaryMaroon,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      course.namaMk,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${course.sks} SKS',
                    style: const TextStyle(
                      color: AppTheme.primaryMaroon,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAdvisorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.tintMaroon,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppTheme.primaryMaroon,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advisor.nama,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'NIDN ${advisor.nidn}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dropdown tunggal untuk memilih shift kelas di awal (Revisi 3)
  Widget _buildShiftSelectorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wb_sunny_outlined,
            color: AppTheme.primaryMaroon,
            size: 22,
          ),
          const SizedBox(width: 12),
          const Text(
            'Pilih Shift:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ClassShift>(
                  value: _selectedShift,
                  isExpanded: true,
                  hint: const Text(
                    'Pilih Shift',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  items: ClassShift.values.map((shift) {
                    return DropdownMenuItem<ClassShift>(
                      value: shift,
                      child: Text(
                        shift.label,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newShift) {
                    _handleShiftChange(newShift);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tabel Informasi Jadwal (Revisi 4) yang digenerate dari fungsi Dart murni
  Widget _buildScheduleComparisonTable(List<ClassSection> columns) {
    if (_selectedShift == null) return const SizedBox.shrink();

    final tableData = KrsLogic.buildScheduleTable(
      shift: _selectedShift!,
      selectedCourses: widget.selectedCourses,
      selectedClasses: _selectedClasses,
      availableClasses: availableClassSections,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              AppTheme.tintMaroon.withValues(alpha: 0.4),
            ),
            columnSpacing: 18,
            horizontalMargin: 14,
            headingRowHeight: 44,
            dataRowMinHeight: 52,
            dataRowMaxHeight: 68,
            columns: [
              const DataColumn(
                label: Text(
                  'Mata Kuliah',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryMaroon,
                    fontSize: 13,
                  ),
                ),
              ),
              ...tableData.columns.map((col) {
                return DataColumn(
                  label: Text(
                    col.code,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryMaroon,
                      fontSize: 13,
                    ),
                  ),
                );
              }),
            ],
            rows: tableData.rows.map((row) {
              return DataRow(
                cells: [
                  // Nama & Kode MK
                  DataCell(
                    SizedBox(
                      width: 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            row.course.namaMk,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${row.course.kode} (${row.course.sks} SKS)',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Sel per Kelas
                  ...tableData.columns.map((col) {
                    final cellInfo = row.cellByClassCode[col.code];
                    if (cellInfo == null || cellInfo.schedule == null) {
                      return const DataCell(Text('-'));
                    }

                    final sched = cellInfo.schedule!;

                    Color cellBg = Colors.transparent;
                    Border? cellBorder;
                    if (cellInfo.isSelected) {
                      cellBg = AppTheme.tintMaroon;
                      cellBorder = Border.all(
                        color: AppTheme.primaryMaroon,
                        width: 1.5,
                      );
                    } else if (cellInfo.isClashing) {
                      cellBg = const Color(0xFFFEE2E2);
                      cellBorder = Border.all(
                        color: const Color(0xFFEF4444),
                        width: 1,
                      );
                    }

                    return DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: cellBg,
                          borderRadius: BorderRadius.circular(6),
                          border: cellBorder,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${sched.day}, ${sched.startTime}-${sched.endTime}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: cellInfo.isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: cellInfo.isSelected
                                    ? AppTheme.primaryMaroon
                                    : AppTheme.textPrimary,
                              ),
                            ),
                            if (cellInfo.isSelected) ...[
                              const SizedBox(height: 2),
                              const Text(
                                '✓ Terpilih',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryMaroon,
                                ),
                              ),
                            ] else if (cellInfo.isClashing) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Bentrok dg ${cellInfo.clashingWithCourseName ?? "lainnya"}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Kartu per mata kuliah dengan SATU dropdown kelas (Revisi 3 & 4)
  Widget _buildCourseClassPickerCard(
    Course course,
    List<ClassSection> availableClasses,
  ) {
    final currentClass = _selectedClasses[course.id];
    final schedule = currentClass != null
        ? getScheduleFor(course.id, currentClass.code)
        : null;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: currentClass != null
              ? AppTheme.primaryMaroon
              : AppTheme.borderColor,
          width: currentClass != null ? 1.5 : 1.0,
        ),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Mata Kuliah
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.tintMaroon,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  course.kode,
                  style: const TextStyle(
                    color: AppTheme.primaryMaroon,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.namaMk,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${course.sks} SKS • ${course.tipe.label}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dropdown Tunggal: Kelas (Mengikuti Shift)
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _selectedShift == null
                  ? const Color(0xFFF3F4F6)
                  : Colors.transparent,
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ClassSection>(
                value: currentClass,
                isExpanded: true,
                hint: Text(
                  _selectedShift == null
                      ? 'Pilih shift kelas di atas terlebih dahulu'
                      : 'Pilih Kelas untuk ${course.namaMk}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                items: _selectedShift == null
                    ? null
                    : availableClasses.map((cls) {
                        // Cek apakah opsi ini bertabrakan dengan kelas yang dipilih di matkul lain
                        final (
                          isClashing,
                          _,
                        ) = KrsLogic.checkClassClashForCourse(
                          course: course,
                          classSection: cls,
                          selectedCourses: widget.selectedCourses,
                          selectedClasses: _selectedClasses,
                        );

                        final itemText = isClashing
                            ? '${cls.code} (bentrok)'
                            : cls.code;

                        return DropdownMenuItem<ClassSection>(
                          value: cls,
                          child: Text(
                            itemText,
                            style: TextStyle(
                              fontSize: 13,
                              color: isClashing
                                  ? const Color(0xFFDC2626)
                                  : AppTheme.textPrimary,
                              fontWeight: isClashing
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                onChanged: _selectedShift == null
                    ? null
                    : (newClass) {
                        setState(() {
                          _selectedClasses[course.id] = newClass;
                        });
                      },
              ),
            ),
          ),

          // Detail Jadwal Setelah Kelas Dipilih
          if (schedule != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.tintMaroon.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 15,
                    color: AppTheme.primaryMaroon,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${schedule.day}, ${schedule.startTime} - ${schedule.endTime} WIB (${schedule.room})',
                      style: const TextStyle(
                        color: AppTheme.primaryMaroon,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(int totalSks) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.pillRadius),
          topRight: Radius.circular(AppTheme.pillRadius),
        ),
        boxShadow: AppTheme.floatingBarShadow,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total: $totalSks SKS',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  semesterLabel,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
            FilledButton(
              onPressed: widget.selectedCourses.isEmpty ? null : _submitKrs,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryMaroon,
                foregroundColor: AppTheme.surfaceWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              child: const Row(
                children: [
                  Text(
                    'Ajukan KRS',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
