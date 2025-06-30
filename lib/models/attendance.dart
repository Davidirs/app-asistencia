
class Attendance {
  final String fecha;
  final String id;
  final String profesor;
  //final List<Student> estudiantes;
  final List estudiantes;
  final String descripcion;
  final String subproyecto;
  final String imageUrl;

  Attendance({
    required this.fecha,
    required this.id,
    required this.profesor,
    required this.estudiantes,
    required this.descripcion,
    required this.subproyecto,
    required this.imageUrl,
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
      imageUrl: json['imageUrl'] ?? "",
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
      'imageUrl': imageUrl,
    };
  }
}
