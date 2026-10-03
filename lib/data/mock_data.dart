import '../models/class_section.dart';
import '../models/course.dart';
import '../models/schedule.dart';
import '../models/student.dart';

/// Data Mahasiswa (Tahap 1)
const Student student = Student(
  nama: 'Hanif Ahmad',
  nim: '2411098',
  semester: 5,
);

const Advisor advisor = Advisor(
  nama: 'Yusuf Wibisono, S.E.,M.T.I',
  nidn: '1101017101',
);

/// Kelas yang tersedia (Tahap 3 & Revisi 3)
const List<ClassSection> availableClassSections = [
  ClassSection(semester: 5, letter: 'A', shift: ClassShift.pagi),
  ClassSection(semester: 5, letter: 'B', shift: ClassShift.pagi),
  ClassSection(semester: 5, letter: 'J', shift: ClassShift.malam),
  ClassSection(semester: 5, letter: 'K', shift: ClassShift.malam),
];

// Kompatibilitas dengan kode lama jika diperlukan
const List<ParallelClass> parallelClasses = [
  ParallelClass(kode: 'IFB5A', jadwal: 'Pagi (Senin - Sabtu)', sisaKursi: 15),
  ParallelClass(kode: 'IFB5B', jadwal: 'Pagi (Senin - Sabtu)', sisaKursi: 12),
  ParallelClass(kode: 'IFB5J', jadwal: 'Malam (Senin - Jumat)', sisaKursi: 10),
  ParallelClass(kode: 'IFB5K', jadwal: 'Malam (Senin - Jumat)', sisaKursi: 8),
];

const String semesterLabel = 'Semester Ganjil 2026';
const int maxSks = 24;
const String defaultApplicationNumber = 'KRS-2026-0001';

/// Pemetaan kode lama (misal IF501 dst) ke kode 6 digit baru berdasarkan nama matkul
const Map<String, String> oldCourseCodeToNewCode = {
  'IF501': '000800',
  'IF502': '110700',
  'IF503': '111100',
  'IF504': '111300',
  'IF505': '111400',
  'IF506': '110600',
  'IF507': '111000',
  'IF508': '111600',
  'IF509': '111500',
  // Jika ada kode 3 digit lama dari prototipe awal
  'IF301': '111000',
  'IF302': '111500',
};

/// Fungsi migrasi kode lama ke kode baru
String migrateCourseCode(String oldCode) {
  if (oldCourseCodeToNewCode.containsKey(oldCode)) {
    return oldCourseCodeToNewCode[oldCode]!;
  }
  return oldCode;
}

/// 9 Mata Kuliah dengan Kode 6 Digit Baru (Revisi 1)
/// Total 26 SKS: 1 Wajib 2 SKS, 8 Pilihan @ 3 SKS
const List<Course> mockCourses = [
  Course(
    id: '000800',
    kode: '000800',
    namaMk: 'Penulisan dan Publikasi Ilmiah',
    sks: 2,
    sisaKuota: 40,
    namaDosen: 'Yusuf Wibisono, S.E.,M.T.I',
    tipe: CourseType.wajib,
  ),
  Course(
    id: '110700',
    kode: '110700',
    namaMk: 'Kriptografi',
    sks: 3,
    sisaKuota: 35,
    namaDosen: 'Sumardi, S.Kom., M.Kom',
    tipe: CourseType.pilihan,
  ),
  Course(
    id: '111100',
    kode: '111100',
    namaMk: 'Penalaran Komputer',
    sks: 3,
    sisaKuota: 30,
    namaDosen: 'Isa Rosita, S.Kom., M.Cs..',
    tipe: CourseType.pilihan,
  ),
  Course(
    id: '111300',
    kode: '111300',
    namaMk: 'Robotika',
    sks: 3,
    sisaKuota: 25,
    namaDosen: "Muhammad Safi’i, S.Kom., M.Kom",
    tipe: CourseType.pilihan,
  ),
  Course(
    id: '111400',
    kode: '111400',
    namaMk: 'Simulasi dan Game Komputer',
    sks: 3,
    sisaKuota: 30,
    namaDosen: 'Heruzulkifli Rowady, S.Kom., M.Kom.',
    tipe: CourseType.pilihan,
  ),
  Course(
    id: '110600',
    kode: '110600',
    namaMk: 'Jaringan Nirkabel',
    sks: 3,
    sisaKuota: 28,
    namaDosen: 'Wisnu Hera Pamungkas, S.T.P., M.Eng',
    tipe: CourseType.pilihan,
  ),
  Course(
    id: '111000',
    kode: '111000',
    namaMk: 'Pemrograman Aplikasi Bergerak',
    sks: 3,
    sisaKuota: 35,
    namaDosen: 'Pramudya Prima Insan S.Kom., M.Kom.',
    tipe: CourseType.pilihan,
  ),
  Course(
    id: '111600',
    kode: '111600',
    namaMk: 'Teknologi Aplikasi Bergerak',
    sks: 3,
    sisaKuota: 30,
    namaDosen: 'Istia Budi S.T., M.M.',
    tipe: CourseType.pilihan,
  ),
  Course(
    id: '111500',
    kode: '111500',
    namaMk: 'Sistem Manajemen Basis Data',
    sks: 3,
    sisaKuota: 32,
    namaDosen: 'Nasruddin Bin Idris, S.Kom., M.Kom.',
    tipe: CourseType.pilihan,
  ),
];

/// Jadwal Deterministik (9 Matkul x 4 Kelas = 36 Jadwal)
/// Bebas tabrakan untuk kelas pagi (IFB5A dan IFB5B)
const List<CourseSchedule> mockSchedules = [
  // --- 000800: Penulisan dan Publikasi Ilmiah (2 SKS = 100 menit) ---
  CourseSchedule(
    courseId: '000800',
    classCode: 'IFB5A',
    day: 'Senin',
    startTime: '08:00',
    endTime: '09:40',
    room: 'R301',
  ),
  CourseSchedule(
    courseId: '000800',
    classCode: 'IFB5B',
    day: 'Selasa',
    startTime: '13:00',
    endTime: '14:40',
    room: 'R301',
  ),
  CourseSchedule(
    courseId: '000800',
    classCode: 'IFB5J',
    day: 'Rabu',
    startTime: '19:00',
    endTime: '20:40',
    room: 'R301',
  ),
  CourseSchedule(
    courseId: '000800',
    classCode: 'IFB5K',
    day: 'Kamis',
    startTime: '19:00',
    endTime: '20:40',
    room: 'R301',
  ),

  // --- 110700: Kriptografi (3 SKS = 150 menit) ---
  CourseSchedule(
    courseId: '110700',
    classCode: 'IFB5A',
    day: 'Senin',
    startTime: '10:00',
    endTime: '12:30',
    room: 'R301',
  ),
  CourseSchedule(
    courseId: '110700',
    classCode: 'IFB5B',
    day: 'Rabu',
    startTime: '08:00',
    endTime: '10:30',
    room: 'R301',
  ),
  CourseSchedule(
    courseId: '110700',
    classCode: 'IFB5J',
    day: 'Kamis',
    startTime: '18:30',
    endTime: '21:00',
    room: 'R301',
  ),
  CourseSchedule(
    courseId: '110700',
    classCode: 'IFB5K',
    day: 'Jumat',
    startTime: '18:30',
    endTime: '21:00',
    room: 'R301',
  ),

  // --- 111100: Penalaran Komputer (3 SKS = 150 menit) ---
  CourseSchedule(
    courseId: '111100',
    classCode: 'IFB5A',
    day: 'Selasa',
    startTime: '08:00',
    endTime: '10:30',
    room: 'R302',
  ),
  CourseSchedule(
    courseId: '111100',
    classCode: 'IFB5B',
    day: 'Kamis',
    startTime: '08:00',
    endTime: '10:30',
    room: 'R302',
  ),
  CourseSchedule(
    courseId: '111100',
    classCode: 'IFB5J',
    day: 'Jumat',
    startTime: '18:30',
    endTime: '21:00',
    room: 'R302',
  ),
  CourseSchedule(
    courseId: '111100',
    classCode: 'IFB5K',
    day: 'Senin',
    startTime: '18:30',
    endTime: '21:00',
    room: 'R302',
  ),

  // --- 111300: Robotika (3 SKS = 150 menit) ---
  CourseSchedule(
    courseId: '111300',
    classCode: 'IFB5A',
    day: 'Selasa',
    startTime: '10:45',
    endTime: '13:15',
    room: 'R302',
  ),
  CourseSchedule(
    courseId: '111300',
    classCode: 'IFB5B',
    day: 'Jumat',
    startTime: '08:00',
    endTime: '10:30',
    room: 'R302',
  ),
  CourseSchedule(
    courseId: '111300',
    classCode: 'IFB5J',
    day: 'Senin',
    startTime: '18:30',
    endTime: '21:00',
    room: 'R302',
  ),
  CourseSchedule(
    courseId: '111300',
    classCode: 'IFB5K',
    day: 'Selasa',
    startTime: '18:30',
    endTime: '21:00',
    room: 'R302',
  ),

  // --- 111400: Simulasi dan Game Komputer (3 SKS = 150 menit) ---
  CourseSchedule(
    courseId: '111400',
    classCode: 'IFB5A',
    day: 'Rabu',
    startTime: '08:00',
    endTime: '10:30',
    room: 'Lab 1',
  ),
  CourseSchedule(
    courseId: '111400',
    classCode: 'IFB5B',
    day: 'Sabtu',
    startTime: '08:00',
    endTime: '10:30',
    room: 'Lab 1',
  ),
  CourseSchedule(
    courseId: '111400',
    classCode: 'IFB5J',
    day: 'Selasa',
    startTime: '18:30',
    endTime: '21:00',
    room: 'Lab 1',
  ),
  CourseSchedule(
    courseId: '111400',
    classCode: 'IFB5K',
    day: 'Rabu',
    startTime: '18:30',
    endTime: '21:00',
    room: 'Lab 1',
  ),

  // --- 110600: Jaringan Nirkabel (3 SKS = 150 menit) ---
  CourseSchedule(
    courseId: '110600',
    classCode: 'IFB5A',
    day: 'Rabu',
    startTime: '10:45',
    endTime: '13:15',
    room: 'Lab 1',
  ),
  CourseSchedule(
    courseId: '110600',
    classCode: 'IFB5B',
    day: 'Senin',
    startTime: '08:00',
    endTime: '10:30',
    room: 'Lab 1',
  ),
  CourseSchedule(
    courseId: '110600',
    classCode: 'IFB5J',
    day: 'Kamis',
    startTime: '18:30',
    endTime: '21:00',
    room: 'Lab 1',
  ),
  CourseSchedule(
    courseId: '110600',
    classCode: 'IFB5K',
    day: 'Jumat',
    startTime: '18:30',
    endTime: '21:00',
    room: 'Lab 1',
  ),

  // --- 111000: Pemrograman Aplikasi Bergerak (3 SKS = 150 menit) ---
  CourseSchedule(
    courseId: '111000',
    classCode: 'IFB5A',
    day: 'Kamis',
    startTime: '08:00',
    endTime: '10:30',
    room: 'Lab 2',
  ),
  CourseSchedule(
    courseId: '111000',
    classCode: 'IFB5B',
    day: 'Senin',
    startTime: '10:45',
    endTime: '13:15',
    room: 'Lab 2',
  ),
  CourseSchedule(
    courseId: '111000',
    classCode: 'IFB5J',
    day: 'Jumat',
    startTime: '18:30',
    endTime: '21:00',
    room: 'Lab 2',
  ),
  CourseSchedule(
    courseId: '111000',
    classCode: 'IFB5K',
    day: 'Senin',
    startTime: '18:30',
    endTime: '21:00',
    room: 'Lab 2',
  ),

  // --- 111600: Teknologi Aplikasi Bergerak (3 SKS = 150 menit) ---
  CourseSchedule(
    courseId: '111600',
    classCode: 'IFB5A',
    day: 'Jumat',
    startTime: '08:00',
    endTime: '10:30',
    room: 'R303',
  ),
  CourseSchedule(
    courseId: '111600',
    classCode: 'IFB5B',
    day: 'Selasa',
    startTime: '08:00',
    endTime: '10:30',
    room: 'R303',
  ),
  CourseSchedule(
    courseId: '111600',
    classCode: 'IFB5J',
    day: 'Senin',
    startTime: '18:30',
    endTime: '21:00',
    room: 'R303',
  ),
  CourseSchedule(
    courseId: '111600',
    classCode: 'IFB5K',
    day: 'Selasa',
    startTime: '18:30',
    endTime: '21:00',
    room: 'R303',
  ),

  // --- 111500: Sistem Manajemen Basis Data (3 SKS = 150 menit) ---
  CourseSchedule(
    courseId: '111500',
    classCode: 'IFB5A',
    day: 'Sabtu',
    startTime: '08:00',
    endTime: '10:30',
    room: 'R303',
  ),
  CourseSchedule(
    courseId: '111500',
    classCode: 'IFB5B',
    day: 'Rabu',
    startTime: '10:45',
    endTime: '13:15',
    room: 'R303',
  ),
  CourseSchedule(
    courseId: '111500',
    classCode: 'IFB5J',
    day: 'Selasa',
    startTime: '18:30',
    endTime: '21:00',
    room: 'R303',
  ),
  CourseSchedule(
    courseId: '111500',
    classCode: 'IFB5K',
    day: 'Rabu',
    startTime: '18:30',
    endTime: '21:00',
    room: 'R303',
  ),
];

/// Helper pencarian jadwal berdasarkan mata kuliah dan kode kelas
CourseSchedule? getScheduleFor(String courseId, String classCode) {
  final targetId = migrateCourseCode(courseId);
  try {
    return mockSchedules.firstWhere(
      (s) => s.courseId == targetId && s.classCode == classCode,
    );
  } catch (_) {
    return null;
  }
}

/// Helper mengambil jadwal yang tersedia untuk suatu mata kuliah
List<CourseSchedule> getSchedulesForCourse(String courseId) {
  final targetId = migrateCourseCode(courseId);
  return mockSchedules.where((s) => s.courseId == targetId).toList();
}
