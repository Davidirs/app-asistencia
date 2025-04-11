import 'package:asistencia/models/attendance.dart';

class SubProyect {
  final String nombre;
  final String docente;
  final List<Attendance> listAttendance;

  SubProyect({
    required this.nombre,
    required this.docente,
    required this.listAttendance,
  });
}
