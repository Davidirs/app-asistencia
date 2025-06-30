class Student {
  final String carrera;
  final String periodo;
  final String imagen;
  final String nombre;
  final String cedula;
  final String fechaNacimiento;
  final String estado;

  Student({
    required this.carrera,
    required this.periodo,
    required this.imagen,
    required this.nombre,
    required this.cedula,
    required this.fechaNacimiento,
    required this.estado,
  });
  static Student fromJson(Map<String, dynamic> json) {
    return Student(
      carrera: json['carrera'],
      periodo: json['periodo'] ?? '',
      imagen: json['imagen'],
      nombre: json['nombre'],
      cedula: json['cedula'],
      fechaNacimiento: json['fechaNacimiento'] ?? '',
      estado: json['estado'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carrera': carrera,
      'periodo': periodo,
      'imagen': imagen,
      'nombre': nombre,
      'cedula': cedula,
      'fechaNacimiento': fechaNacimiento,
      'estado': estado,
    };
  }
}

class StudentVerificado extends Student {
  StudentVerificado({
    required super.carrera,
    required super.periodo,
    required super.imagen,
    required super.nombre,
    required super.cedula,
    required super.fechaNacimiento,
    required super.estado,
  });

  static StudentVerificado fromCedula(String cedula) {
    // Aquí puedes hacer alguna lógica para obtener el resto de los datos del estudiante
    return StudentVerificado(
      carrera: 'Carrera Verificada',
      periodo: '2024',
      imagen: 'imagen_verificada.jpg',
      nombre: 'Estudiante Verificado',
      cedula: cedula,
      fechaNacimiento: '01/01/2000',
      estado: 'Verificado',
    );
  }
}

class StudentNoVerificado extends Student {
  StudentNoVerificado({
    required super.carrera,
    required super.periodo,
    required super.imagen,
    required super.nombre,
    required super.cedula,
    required super.fechaNacimiento,
    required super.estado,
  });

  static StudentNoVerificado fromCedula(String cedula) {
    // Aquí puedes hacer alguna lógica para obtener el resto de los datos del estudiante
    return StudentNoVerificado(
        carrera: "SIN VERIFICAR",
        periodo: "SIN VERIFICAR",
        imagen: "SIN VERIFICAR",
        nombre: "ESTUDIANTE UNELLEZ",
        cedula: cedula,
        fechaNacimiento: "SIN VERIFICAR",
        estado: "SIN VERIFICAR");
  }
}

class StudentNoRegistrado extends Student {
  StudentNoRegistrado({
    required super.carrera,
    required super.periodo,
    required super.imagen,
    required super.nombre,
    required super.cedula,
    required super.fechaNacimiento,
    required super.estado,
  });

  static StudentNoRegistrado fromCedula(String cedula) {
    // Aquí puedes hacer alguna lógica para obtener el resto de los datos del estudiante
    return StudentNoRegistrado(
        carrera: "NO REGISTRADO",
        periodo: "NO REGISTRADO",
        imagen: "NO REGISTRADO",
        nombre: "NO REGISTRADO",
        cedula: cedula,
        fechaNacimiento: "NO REGISTRADO",
        estado: "NO REGISTRADO");
  }
}
