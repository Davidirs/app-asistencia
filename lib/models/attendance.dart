import 'package:asistencia/models/student.dart';

class Attendance {
  final String fecha;
  final String hora;
  final List<Student> listStudent;
  final String descripcion;

  Attendance({
    required this.fecha,
    required this.hora,
    required this.listStudent,
    required this.descripcion,
  });
}
