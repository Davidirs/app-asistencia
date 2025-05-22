import 'package:asistencia/models/attendance.dart';

class SubProyect {
  final String nombre;
  final String profesor;
  final String id;

  SubProyect({
    required this.nombre,
    required this.profesor,
    required this.id
  });

  static SubProyect fromJson(Map<String, dynamic> json) {
    return SubProyect(
      nombre: json['nombre'],
      profesor: json['profesor'],
      id: json['id'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'profesor': profesor,
      'id': id,
    };
  }
}
