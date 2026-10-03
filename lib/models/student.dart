class NimParser {
  NimParser._();

  static const String prodiInformatikaCode = '11';
  static const String prodiInformatikaName = 'Informatika';

  static bool isValid(String nim) {
    if (!RegExp(r'^\d{7}$').hasMatch(nim)) {
      return false;
    }
    return nim.substring(2, 4) == prodiInformatikaCode;
  }

  static int getAngkatan(String nim) {
    if (!isValid(nim)) {
      throw FormatException('NIM tidak valid: $nim');
    }
    final prefix = int.parse(nim.substring(0, 2));
    return 2000 + prefix;
  }

  static String getProdi(String nim) {
    if (!isValid(nim)) {
      throw FormatException('NIM tidak valid: $nim');
    }
    final code = nim.substring(2, 4);
    if (code == prodiInformatikaCode) {
      return prodiInformatikaName;
    }
    return 'Lainnya';
  }

  static String getUrutan(String nim) {
    if (!isValid(nim)) {
      throw FormatException('NIM tidak valid: $nim');
    }
    return nim.substring(4, 7);
  }
}

class Student {
  final String nama;
  final String nim;
  final int semester;

  const Student({
    required this.nama,
    required this.nim,
    required this.semester,
  });

  String get programStudi => NimParser.getProdi(nim);
  int get angkatan => NimParser.getAngkatan(nim);
  String get urutan => NimParser.getUrutan(nim);

  String get initials {
    final parts = nama.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class Advisor {
  final String nama;
  final String nidn;

  const Advisor({required this.nama, required this.nidn});
}

class ParallelClass {
  final String kode;
  final String jadwal;
  final int sisaKursi;

  const ParallelClass({
    required this.kode,
    required this.jadwal,
    required this.sisaKursi,
  });
}
