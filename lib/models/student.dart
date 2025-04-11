class Student {
  final String carrera;
  final String periodoAcademico;
  final String imagen;
  final String nombre;
  final String cedula;
  final String fechaNacimiento;
  final String estado;

  Student({
    required this.carrera,
    required this.periodoAcademico,
    required this.imagen,
    required this.nombre,
    required this.cedula,
    required this.fechaNacimiento,
    required this.estado,
  });
}

class StudentVerificado extends Student {
  StudentVerificado({
    required super.carrera,
    required super.periodoAcademico,
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
      periodoAcademico: '2024',
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
    required super.periodoAcademico,
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
        periodoAcademico: "SIN VERIFICAR",
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
    required super.periodoAcademico,
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
        periodoAcademico: "NO REGISTRADO",
        imagen: "NO REGISTRADO",
        nombre: "NO REGISTRADO",
        cedula: cedula,
        fechaNacimiento: "NO REGISTRADO",
        estado: "NO REGISTRADO");
  }
}
