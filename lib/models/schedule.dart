class CourseSchedule {
  final String courseId;
  final String classCode;
  final String day;
  final String startTime;
  final String endTime;
  final String room;

  const CourseSchedule({
    required this.courseId,
    required this.classCode,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.room,
  });

  /// Mengonversi waktu 'HH:mm' menjadi total menit sejak tengah malam
  int _toMinutes(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return hour * 60 + minute;
  }

  int get startMinutes => _toMinutes(startTime);
  int get endMinutes => _toMinutes(endTime);

  /// Memeriksa apakah jadwal ini tumpang tindih / bertabrakan dengan jadwal lain
  bool overlapsWith(CourseSchedule other) {
    if (day != other.day) return false;
    return startMinutes < other.endMinutes && other.startMinutes < endMinutes;
  }

  String get formattedSchedule => '$day, $startTime - $endTime WIB ($room)';

  @override
  String toString() => '$classCode: $formattedSchedule';
}
