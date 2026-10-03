enum ClassShift {
  pagi('Pagi'),
  malam('Malam');

  final String label;
  const ClassShift(this.label);
}

class ClassSection {
  static const String fixedPrefix = 'IFB';

  final int semester;
  final String letter;
  final ClassShift shift;

  const ClassSection({
    required this.semester,
    required this.letter,
    required this.shift,
  });

  String get code => '$fixedPrefix$semester$letter';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassSection &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => code;
}
