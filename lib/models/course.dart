enum CourseType {
  wajib,
  pilihan;

  String get label {
    switch (this) {
      case CourseType.wajib:
        return 'Wajib';
      case CourseType.pilihan:
        return 'Pilihan';
    }
  }
}

class Course {
  final String id;
  final String kode;
  final String namaMk;
  final int sks;
  final int sisaKuota;
  final String namaDosen;
  final CourseType tipe;

  const Course({
    required this.id,
    required this.kode,
    required this.namaMk,
    required this.sks,
    required this.sisaKuota,
    required this.namaDosen,
    required this.tipe,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
