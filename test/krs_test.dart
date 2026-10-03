import 'package:checkout_sks/data/mock_data.dart';
import 'package:checkout_sks/logic/krs_logic.dart';
import 'package:checkout_sks/models/class_section.dart';
import 'package:checkout_sks/models/course.dart';
import 'package:checkout_sks/models/schedule.dart';
import 'package:checkout_sks/models/student.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tahap 1 - Data Mahasiswa & NimParser Tests', () {
    test('Validasi NIM 7 digit dengan kode prodi 11', () {
      expect(NimParser.isValid('2411098'), isTrue);
      expect(NimParser.isValid('2411001'), isTrue);
      expect(NimParser.isValid('241109'), isFalse);
      expect(NimParser.isValid('24110989'), isFalse);
      expect(NimParser.isValid('241109A'), isFalse);
      expect(NimParser.isValid('2412098'), isFalse);
    });

    test('Ekstraksi Angkatan, Prodi, dan Urutan dari NIM', () {
      const nim = '2411098';
      expect(NimParser.getAngkatan(nim), equals(2024));
      expect(NimParser.getProdi(nim), equals('Informatika'));
      expect(NimParser.getUrutan(nim), equals('098'));
    });

    test('Data Mahasiswa Hanif Ahmad terdefinisi dengan benar', () {
      expect(student.nama, equals('Hanif Ahmad'));
      expect(student.nim, equals('2411098'));
      expect(student.semester, equals(5));
      expect(student.programStudi, equals('Informatika'));
      expect(student.angkatan, equals(2024));
      expect(student.urutan, equals('098'));
      expect(student.initials, equals('HA'));
    });
  });

  group('Revisi 1 - Kode 6-Digit Mata Kuliah & Migrasi Tests', () {
    test('Semua mata kuliah menggunakan kode 6-digit String', () {
      expect(mockCourses.length, equals(9));
      for (final course in mockCourses) {
        expect(
          course.kode.length,
          equals(6),
          reason: '${course.namaMk} harus berkode 6 digit',
        );
        expect(
          RegExp(r'^\d{6}$').hasMatch(course.kode),
          isTrue,
          reason: '${course.namaMk} harus berupa angka 6 digit',
        );
      }

      // Pastikan kode spesifik sesuai ketentuan
      final ppi = mockCourses.firstWhere((c) => c.namaMk.contains('Penulisan'));
      expect(ppi.kode, equals('000800'));

      final kripto = mockCourses.firstWhere(
        (c) => c.namaMk.contains('Kriptografi'),
      );
      expect(kripto.kode, equals('110700'));
    });

    test(
      'Fungsi migrasi memetakan kode lama ke kode 6 digit baru dengan benar',
      () {
        expect(migrateCourseCode('IF501'), equals('000800'));
        expect(migrateCourseCode('IF502'), equals('110700'));
        expect(migrateCourseCode('IF503'), equals('111100'));
        expect(migrateCourseCode('IF504'), equals('111300'));
        expect(migrateCourseCode('IF505'), equals('111400'));
        expect(migrateCourseCode('IF506'), equals('110600'));
        expect(migrateCourseCode('IF507'), equals('111000'));
        expect(migrateCourseCode('IF508'), equals('111600'));
        expect(migrateCourseCode('IF509'), equals('111500'));
        // Jika sudah kode baru, tetap tidak berubah
        expect(migrateCourseCode('000800'), equals('000800'));
      },
    );
  });

  group('Tahap 2 - Aturan SKS, Kuota & Matkul Wajib Tests', () {
    test('Katalog memiliki 9 mata kuliah dengan total 26 SKS', () {
      final totalSks = KrsLogic.calculateTotalSks(mockCourses);
      expect(totalSks, equals(26));
    });

    test('Mata kuliah wajib adalah Penulisan dan Publikasi Ilmiah (2 SKS)', () {
      final mandatoryCourses = mockCourses
          .where((c) => c.tipe == CourseType.wajib)
          .toList();
      expect(mandatoryCourses.length, equals(1));
      expect(
        mandatoryCourses.first.namaMk,
        equals('Penulisan dan Publikasi Ilmiah'),
      );
      expect(mandatoryCourses.first.sks, equals(2));
      expect(KrsLogic.isMandatory(mandatoryCourses.first), isTrue);
    });

    test('Perhitungan dinamis maksimal mata kuliah pilihan adalah 7', () {
      final maxElectives = KrsLogic.calculateMaxElectiveCourses(
        catalog: mockCourses,
        maxCreditLimit: maxSks,
      );
      expect(maxElectives, equals(7));
    });

    test('Mata kuliah pilihan ke-8 ditolak karena melebihi batas 24 SKS', () {
      final mandatory = mockCourses.firstWhere(
        (c) => c.tipe == CourseType.wajib,
      );
      final electives = mockCourses
          .where((c) => c.tipe == CourseType.pilihan)
          .toList();

      final selected = <Course>[mandatory, ...electives.take(7)];
      expect(KrsLogic.calculateTotalSks(selected), equals(23));

      final remaining = KrsLogic.calculateRemainingQuota(
        selected,
        maxCreditLimit: maxSks,
      );
      expect(remaining, equals(1));

      final eighthElective = electives[7];
      expect(eighthElective.sks, equals(3));
      final canAdd = KrsLogic.canAddCourse(
        currentSelected: selected,
        candidate: eighthElective,
        maxCreditLimit: maxSks,
      );
      expect(canAdd, isFalse);
    });

    test('Membatalkan satu matkul pilihan mengembalikan kuota', () {
      final mandatory = mockCourses.firstWhere(
        (c) => c.tipe == CourseType.wajib,
      );
      final electives = mockCourses
          .where((c) => c.tipe == CourseType.pilihan)
          .toList();

      final selected = <Course>[mandatory, ...electives.take(7)];
      selected.removeLast();

      expect(KrsLogic.calculateTotalSks(selected), equals(20));
      expect(
        KrsLogic.calculateRemainingQuota(selected, maxCreditLimit: maxSks),
        equals(4),
      );

      final candidate = electives.last;
      expect(
        KrsLogic.canAddCourse(
          currentSelected: selected,
          candidate: candidate,
          maxCreditLimit: maxSks,
        ),
        isTrue,
      );
    });
  });

  group('Tahap 3 - Kelas & Jadwal Tests', () {
    test('Kode kelas terstruktur dari IFB + semester + huruf', () {
      const classA = ClassSection(
        semester: 5,
        letter: 'A',
        shift: ClassShift.pagi,
      );
      const classB = ClassSection(
        semester: 5,
        letter: 'B',
        shift: ClassShift.pagi,
      );
      const classJ = ClassSection(
        semester: 5,
        letter: 'J',
        shift: ClassShift.malam,
      );
      const classK = ClassSection(
        semester: 5,
        letter: 'K',
        shift: ClassShift.malam,
      );

      expect(classA.code, equals('IFB5A'));
      expect(classB.code, equals('IFB5B'));
      expect(classJ.code, equals('IFB5J'));
      expect(classK.code, equals('IFB5K'));
    });

    test('Setiap matkul memiliki 4 jadwal dengan hari+jam mulai yang unik', () {
      for (final course in mockCourses) {
        final schedules = getSchedulesForCourse(course.id);
        expect(
          schedules.length,
          equals(4),
          reason: '${course.namaMk} harus memiliki 4 jadwal',
        );

        final timeKeys = schedules
            .map((s) => '${s.day}_${s.startTime}')
            .toSet();
        expect(
          timeKeys.length,
          equals(4),
          reason:
              'Kombinasi hari dan jam mulai untuk ${course.namaMk} harus unik di antara 4 kelas',
        );
      }
    });

    test('Semua 9 matkul di kelas IFB5A tidak saling bertabrakan', () {
      final schedulesIFB5A = <CourseSchedule>[];
      for (final course in mockCourses) {
        final sched = getScheduleFor(course.id, 'IFB5A');
        expect(sched, isNotNull);
        schedulesIFB5A.add(sched!);
      }

      for (int i = 0; i < schedulesIFB5A.length; i++) {
        for (int j = i + 1; j < schedulesIFB5A.length; j++) {
          final s1 = schedulesIFB5A[i];
          final s2 = schedulesIFB5A[j];
          expect(s1.overlapsWith(s2), isFalse);
        }
      }
    });

    test('Semua 9 matkul di kelas IFB5B tidak saling bertabrakan', () {
      final schedulesIFB5B = <CourseSchedule>[];
      for (final course in mockCourses) {
        final sched = getScheduleFor(course.id, 'IFB5B');
        expect(sched, isNotNull);
        schedulesIFB5B.add(sched!);
      }

      for (int i = 0; i < schedulesIFB5B.length; i++) {
        for (int j = i + 1; j < schedulesIFB5B.length; j++) {
          final s1 = schedulesIFB5B[i];
          final s2 = schedulesIFB5B[j];
          expect(s1.overlapsWith(s2), isFalse);
        }
      }
    });
  });

  group('Revisi 3 & 4 - Single Shift, Tabel Jadwal & Validasi Tests', () {
    test('Tabel jadwal per shift menghasilkan kolom dan baris yang sesuai', () {
      final selected = mockCourses.take(3).toList();
      final selectedClasses = <String, ClassSection?>{
        selected[0].id: availableClassSections[0], // IFB5A
      };

      final tableData = KrsLogic.buildScheduleTable(
        shift: ClassShift.pagi,
        selectedCourses: selected,
        selectedClasses: selectedClasses,
        availableClasses: availableClassSections,
      );

      expect(tableData.shift, equals(ClassShift.pagi));
      expect(tableData.columns.length, equals(2)); // IFB5A, IFB5B
      expect(tableData.rows.length, equals(3));

      // Baris pertama matkul 1: IFB5A harus isSelected = true
      final row0 = tableData.rows[0];
      expect(row0.cellByClassCode['IFB5A']?.isSelected, isTrue);
      expect(row0.cellByClassCode['IFB5B']?.isSelected, isFalse);
    });

    test('Tabel mendeteksi bentrok jadwal pada sel alternatif', () {
      // 111300 (Robotika) dan 111600 (Teknologi Aplikasi Bergerak) di IFB5J sama-sama Senin 18:30 - 21:00
      final robotika = mockCourses.firstWhere((c) => c.kode == '111300');
      final tab = mockCourses.firstWhere((c) => c.kode == '111600');
      final classJ = availableClassSections.firstWhere(
        (c) => c.code == 'IFB5J',
      );

      final selected = [robotika, tab];
      // User memilih robotika di IFB5J
      final selectedClasses = <String, ClassSection?>{
        robotika.id: classJ,
        tab.id: null, // belum memilih TAB
      };

      final tableData = KrsLogic.buildScheduleTable(
        shift: ClassShift.malam,
        selectedCourses: selected,
        selectedClasses: selectedClasses,
        availableClasses: availableClassSections,
      );

      // Pada baris TAB, sel IFB5J harus ditandai isClashing = true karena bentrok dengan robotika
      final tabRow = tableData.rows.firstWhere((r) => r.course.id == tab.id);
      final cellIFB5J = tabRow.cellByClassCode['IFB5J'];
      expect(cellIFB5J?.isClashing, isTrue);
      expect(cellIFB5J?.clashingWithCourseName, equals(robotika.namaMk));
    });

    test(
      'Validasi submission gagal jika kelas tidak sesuai dengan shift terpilih',
      () {
        final mandatory = mockCourses.firstWhere(
          (c) => c.tipe == CourseType.wajib,
        );
        final classJ = availableClassSections.firstWhere(
          (c) => c.code == 'IFB5J',
        ); // Malam

        final selectedClasses = <String, ClassSection?>{
          mandatory.id:
              classJ, // Memilih kelas malam padahal shift pengajuan pagi
        };

        final result = KrsLogic.validateSubmissionWithShift(
          shift: ClassShift.pagi,
          selectedCourses: [mandatory],
          selectedClasses: selectedClasses,
          maxCreditLimit: maxSks,
        );

        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('tidak sesuai dengan shift'));
      },
    );

    test(
      'Validasi submission berhasil jika seluruh matkul satu shift dan tidak bentrok',
      () {
        final mandatory = mockCourses.firstWhere(
          (c) => c.tipe == CourseType.wajib,
        );
        final electives = mockCourses
            .where((c) => c.tipe == CourseType.pilihan)
            .take(3)
            .toList();
        final selected = [mandatory, ...electives];

        final classA = availableClassSections.firstWhere(
          (c) => c.code == 'IFB5A',
        );
        final selectedClasses = <String, ClassSection?>{};
        for (final c in selected) {
          selectedClasses[c.id] = classA;
        }

        final result = KrsLogic.validateSubmissionWithShift(
          shift: ClassShift.pagi,
          selectedCourses: selected,
          selectedClasses: selectedClasses,
          maxCreditLimit: maxSks,
        );

        expect(result.isValid, isTrue);
        expect(result.errorMessage, isNull);
      },
    );
  });
}
