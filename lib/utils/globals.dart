import 'package:asistencia/models/attendance.dart';
import 'package:asistencia/models/justificativo.dart';
import 'package:asistencia/models/professor.dart';
import 'package:asistencia/models/student.dart';
import 'package:asistencia/models/subproyect.dart';

List<Student> listEstudiantes = [];
List<Justificativo> listJustificativos = [];
List<Attendance> listAttendance = [];
List<SubProyect> listSubproyectos = [];
Professor professor = Professor(
    correo: "",
    imagen: "",
    id: "",
    ci: "",
    telefono: "",
    nombre: "",
    aprobado: ""
    );

    SubProyect subproyecto = SubProyect(
        id: "ULF15HUa6V5ALe9YeuU5",
        nombre: "Organización de Sistemas",
        profesor: "20408381"
        );
