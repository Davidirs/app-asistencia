import 'package:asistencia/models/attendance.dart';

class Professor {
  final String correo;
  final String imagen;
  final String id;
  final String telefono;
  final String nombre;

  Professor({
    required this.correo,
    required this.imagen,
    required this.id,
    required this.telefono,
    required this.nombre
  });

 static Professor fromJson(Map<String, dynamic> json) {
    return Professor(
      correo: json['correo'],
      imagen: json['imagen'],
      id: json['id'],
      telefono: json['telefono'],
      nombre: json['nombre']
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'correo': correo,
      'imagen': imagen,
      'id': id,
      'telefono': telefono,
      'nombre': nombre
    };
  }
}
