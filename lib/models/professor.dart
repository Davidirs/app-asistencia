
class Professor {
  final String correo;
  final String imagen;
  final String id;
  final String ci;
  final String telefono;
  final String nombre;
  final String aprobado;

  Professor({
    required this.correo,
    required this.imagen,
    required this.id,
    required this.ci,
    required this.telefono,
    required this.nombre,
    required this.aprobado
  });

 static Professor fromJson(Map<String, dynamic> json) {
    return Professor(
      correo: json['correo'],
      imagen: json['imagen'],
      id: json['id'],
      ci: json['ci'],
      telefono: json['telefono'],
      nombre: json['nombre'],
      aprobado: json['aprobado']
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'correo': correo,
      'imagen': imagen,
      'id': id,
      'ci': ci,
      'telefono': telefono,
      'nombre': nombre,
      'aprobado': aprobado
    };
  }
}
