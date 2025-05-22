import 'dart:convert';

import 'package:asistencia/models/student.dart';

class Attendance {
  final String fecha;
  final String id;
  final String profesor;
  //final List<Student> estudiantes;
  final List estudiantes;
  final String descripcion;
  final String subproyecto;

  Attendance({
    required this.fecha,
    required this.id,
    required this.profesor,
    required this.estudiantes,
    required this.descripcion,
    required this.subproyecto,
  });

  static Attendance fromJson(Map<String, dynamic> json) {
    return Attendance(
      fecha: json['fecha'],
      id: json['id'],
      profesor: json['profesor'],
      estudiantes: json['estudiantes'],
      /* estudiantes: jsonDecode(json['estudiantes'])
          .map((e) => Student.fromJson(e))
          .toList(), */
      descripcion: json['descripcion'] ?? "",
      subproyecto: json['subproyecto'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha,
      'id': id,
      'profesor': profesor,
      'estudiantes': estudiantes.toList(),
      'descripcion': descripcion,
      'subproyecto': subproyecto,
    };
  }
}
