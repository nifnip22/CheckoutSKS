import '../data/mock_data.dart';
import '../models/class_section.dart';
import '../models/course.dart';
import '../models/schedule.dart';

class KrsValidationResult {
  final bool isValid;
  final String? errorMessage;
  final Course? courseA;
  final Course? courseB;

  const KrsValidationResult.success()
    : isValid = true,
      errorMessage = null,
      courseA = null,
      courseB = null;

  const KrsValidationResult.error(
    this.errorMessage, {
    this.courseA,
    this.courseB,
  }) : isValid = false;
}

class ScheduleCellInfo {
  final CourseSchedule? schedule;
  final bool isSelected;
  final bool isClashing;
  final String? clashingWithCourseName;

  const ScheduleCellInfo({
    required this.schedule,
    required this.isSelected,
    required this.isClashing,
    this.clashingWithCourseName,
  });
}

class ScheduleTableRowData {
  final Course course;
  final Map<String, ScheduleCellInfo> cellByClassCode;

  const ScheduleTableRowData({
    required this.course,
    required this.cellByClassCode,
  });
}

class ScheduleTableData {
  final ClassShift shift;
  final List<ClassSection> columns;
  final List<ScheduleTableRowData> rows;

  const ScheduleTableData({
    required this.shift,
    required this.columns,
    required this.rows,
  });
}

class KrsSubmissionItem {
  final String courseCode;
  final String classCode;

  const KrsSubmissionItem({required this.courseCode, required this.classCode});
}

class KrsSubmission {
  final String submissionNumber;
  final ClassShift shift;
  final List<KrsSubmissionItem> items;
  final DateTime submittedAt;

  const KrsSubmission({
    required this.submissionNumber,
    required this.shift,
    required this.items,
    required this.submittedAt,
  });
}

class KrsLogic {
  KrsLogic._();

  /// Menghitung total SKS dari daftar mata kuliah
  static int calculateTotalSks(Iterable<Course> courses) {
    return courses.fold<int>(0, (sum, c) => sum + c.sks);
  }

  /// Menghitung sisa kuota SKS yang masih bisa diambil
  static int calculateRemainingQuota(
    Iterable<Course> selectedCourses, {
    required int maxCreditLimit,
  }) {
    final currentSks = calculateTotalSks(selectedCourses);
    final remaining = maxCreditLimit - currentSks;
    return remaining < 0 ? 0 : remaining;
  }

  /// Menghitung secara dinamis batas maksimal mata kuliah pilihan yang bisa diambil
  static int calculateMaxElectiveCourses({
    required List<Course> catalog,
    required int maxCreditLimit,
  }) {
    final mandatoryCourses = catalog
        .where((c) => c.tipe == CourseType.wajib)
        .toList();
    final mandatorySks = calculateTotalSks(mandatoryCourses);
    final quotaForElectives = maxCreditLimit - mandatorySks;

    final electiveCourses = catalog
        .where((c) => c.tipe == CourseType.pilihan)
        .toList();
    if (electiveCourses.isEmpty || quotaForElectives <= 0) return 0;

    final sortedSks = electiveCourses.map((c) => c.sks).toList()..sort();
    int count = 0;
    int currentSum = 0;
    for (final sks in sortedSks) {
      if (currentSum + sks <= quotaForElectives) {
        currentSum += sks;
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// Memeriksa apakah mata kuliah kandidat dapat ditambahkan
  static bool canAddCourse({
    required Iterable<Course> currentSelected,
    required Course candidate,
    required int maxCreditLimit,
  }) {
    if (currentSelected.any((c) => c.id == candidate.id)) {
      return false;
    }
    final remaining = calculateRemainingQuota(
      currentSelected,
      maxCreditLimit: maxCreditLimit,
    );
    return candidate.sks <= remaining;
  }

  /// Memeriksa apakah mata kuliah adalah mata kuliah wajib
  static bool isMandatory(Course course) {
    return course.tipe == CourseType.wajib;
  }

  /// Memeriksa apakah opsi kelas tertentu untuk suatu mata kuliah bertabrakan
  /// dengan pilihan kelas yang sudah aktif pada mata kuliah lain
  static (bool, String?) checkClassClashForCourse({
    required Course course,
    required ClassSection classSection,
    required List<Course> selectedCourses,
    required Map<String, ClassSection?> selectedClasses,
  }) {
    final targetSchedule = getScheduleFor(course.id, classSection.code);
    if (targetSchedule == null) return (false, null);

    for (final otherCourse in selectedCourses) {
      if (otherCourse.id == course.id) continue;
      final otherClass = selectedClasses[otherCourse.id];
      if (otherClass == null) continue;

      final otherSchedule = getScheduleFor(otherCourse.id, otherClass.code);
      if (otherSchedule != null && targetSchedule.overlapsWith(otherSchedule)) {
        return (true, otherCourse.namaMk);
      }
    }
    return (false, null);
  }

  /// Membangun data tabel jadwal per shift (Revisi 4) secara murni logika Dart
  static ScheduleTableData buildScheduleTable({
    required ClassShift shift,
    required List<Course> selectedCourses,
    required Map<String, ClassSection?> selectedClasses,
    required List<ClassSection> availableClasses,
  }) {
    final columns = availableClasses.where((c) => c.shift == shift).toList();

    final rows = <ScheduleTableRowData>[];

    for (final course in selectedCourses) {
      final cellMap = <String, ScheduleCellInfo>{};

      for (final col in columns) {
        final sched = getScheduleFor(course.id, col.code);
        final isSelected = selectedClasses[course.id]?.code == col.code;

        // Cek tabrakan dengan pilihan kelas mata kuliah lain
        final (isClashing, clashingName) = checkClassClashForCourse(
          course: course,
          classSection: col,
          selectedCourses: selectedCourses,
          selectedClasses: selectedClasses,
        );

        cellMap[col.code] = ScheduleCellInfo(
          schedule: sched,
          isSelected: isSelected,
          isClashing: isClashing,
          clashingWithCourseName: clashingName,
        );
      }

      rows.add(ScheduleTableRowData(course: course, cellByClassCode: cellMap));
    }

    return ScheduleTableData(shift: shift, columns: columns, rows: rows);
  }

  /// Mendeteksi apakah ada jadwal yang bertabrakan di antara mata kuliah terpilih
  static (Course, Course, CourseSchedule, CourseSchedule)? findScheduleClash({
    required List<Course> selectedCourses,
    required Map<String, CourseSchedule> courseSchedules,
  }) {
    for (int i = 0; i < selectedCourses.length; i++) {
      final courseA = selectedCourses[i];
      final scheduleA = courseSchedules[courseA.id];
      if (scheduleA == null) continue;

      for (int j = i + 1; j < selectedCourses.length; j++) {
        final courseB = selectedCourses[j];
        final scheduleB = courseSchedules[courseB.id];
        if (scheduleB == null) continue;

        if (scheduleA.overlapsWith(scheduleB)) {
          return (courseA, courseB, scheduleA, scheduleB);
        }
      }
    }
    return null;
  }

  /// Validasi menyeluruh pengajuan KRS dengan Shift terpadu (Revisi 3 & 4)
  static KrsValidationResult validateSubmissionWithShift({
    required ClassShift? shift,
    required List<Course> selectedCourses,
    required Map<String, ClassSection?> selectedClasses,
    required int maxCreditLimit,
  }) {
    if (shift == null) {
      return const KrsValidationResult.error(
        'Silakan pilih shift kelas terlebih dahulu.',
      );
    }

    if (selectedCourses.isEmpty) {
      return const KrsValidationResult.error(
        'Daftar mata kuliah terpilih tidak boleh kosong.',
      );
    }

    // 1. Cek batas SKS
    final totalSks = calculateTotalSks(selectedCourses);
    if (totalSks > maxCreditLimit) {
      return KrsValidationResult.error(
        'Total SKS ($totalSks) melebihi batas maksimal $maxCreditLimit SKS.',
      );
    }

    // 2. Cek apakah mata kuliah wajib ada
    final hasMandatory = selectedCourses.any((c) => c.tipe == CourseType.wajib);
    if (!hasMandatory) {
      return const KrsValidationResult.error(
        'Mata kuliah wajib harus diambil.',
      );
    }

    // 3. Cek apakah semua mata kuliah sudah dipilihkan kelasnya dan sesuai shift
    final Map<String, CourseSchedule> schedulesMap = {};
    for (final course in selectedCourses) {
      final chosenClass = selectedClasses[course.id];
      if (chosenClass == null) {
        return KrsValidationResult.error(
          'Silakan pilih kelas untuk mata kuliah "${course.namaMk}".',
        );
      }

      if (chosenClass.shift != shift) {
        return KrsValidationResult.error(
          'Kelas ${chosenClass.code} pada "${course.namaMk}" tidak sesuai dengan shift ${shift.label}.',
        );
      }

      final sched = getScheduleFor(course.id, chosenClass.code);
      if (sched == null) {
        return KrsValidationResult.error(
          'Jadwal untuk "${course.namaMk}" di kelas ${chosenClass.code} tidak ditemukan.',
        );
      }
      schedulesMap[course.id] = sched;
    }

    // 4. Cek tabrakan jadwal
    final clash = findScheduleClash(
      selectedCourses: selectedCourses,
      courseSchedules: schedulesMap,
    );
    if (clash != null) {
      final (courseA, courseB, schedA, schedB) = clash;
      return KrsValidationResult.error(
        'Jadwal bentrok antara "${courseA.namaMk}" (${schedA.day}, ${schedA.startTime}-${schedA.endTime}) dan "${courseB.namaMk}" (${schedB.day}, ${schedB.startTime}-${schedB.endTime}).',
        courseA: courseA,
        courseB: courseB,
      );
    }

    return const KrsValidationResult.success();
  }

  /// Validasi menyeluruh pengajuan KRS (Kompatibilitas lama)
  static KrsValidationResult validateSubmission({
    required List<Course> selectedCourses,
    required Map<String, CourseSchedule> courseSchedules,
    required int maxCreditLimit,
  }) {
    if (selectedCourses.isEmpty) {
      return const KrsValidationResult.error(
        'Daftar mata kuliah terpilih tidak boleh kosong.',
      );
    }

    final totalSks = calculateTotalSks(selectedCourses);
    if (totalSks > maxCreditLimit) {
      return KrsValidationResult.error(
        'Total SKS ($totalSks) melebihi batas maksimal $maxCreditLimit SKS.',
      );
    }

    final hasMandatory = selectedCourses.any((c) => c.tipe == CourseType.wajib);
    if (!hasMandatory) {
      return const KrsValidationResult.error(
        'Mata kuliah wajib harus diambil.',
      );
    }

    for (final course in selectedCourses) {
      if (!courseSchedules.containsKey(course.id)) {
        return KrsValidationResult.error(
          'Silakan pilih kelas untuk mata kuliah "${course.namaMk}".',
        );
      }
    }

    final clash = findScheduleClash(
      selectedCourses: selectedCourses,
      courseSchedules: courseSchedules,
    );
    if (clash != null) {
      final (courseA, courseB, schedA, schedB) = clash;
      return KrsValidationResult.error(
        'Jadwal bentrok antara "${courseA.namaMk}" (${schedA.day}, ${schedA.startTime}-${schedA.endTime}) dan "${courseB.namaMk}" (${schedB.day}, ${schedB.startTime}-${schedB.endTime}).',
        courseA: courseA,
        courseB: courseB,
      );
    }

    return const KrsValidationResult.success();
  }
}
