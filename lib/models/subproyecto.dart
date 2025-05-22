
import 'package:asistencia/models/attendance.dart';

class SubProyecto {
  final String nombre;
  final String docente;
  final List<Attendance> listAttendance;

  SubProyecto({
    required this.nombre,
    required this.docente,
    required this.listAttendance,
  });

  static SubProyecto fromJson(Map<String, dynamic> json) {
    return SubProyecto(
      nombre: json['nombre'],
      docente: json['docente'],
      listAttendance: (json['listAttendance'] as List)
          .map((e) => Attendance.fromJson(e))
          .toList(),
    );
  }
  
}