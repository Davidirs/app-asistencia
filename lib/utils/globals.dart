import 'package:asistencia/models/attendance.dart';
import 'package:asistencia/models/professor.dart';
import 'package:asistencia/models/student.dart';
import 'package:asistencia/models/subproyect.dart';

List<Student> listEstudiantes = [];
List<Attendance> listAttendance = [];
List<SubProyect> listSubproyectos = [];
Professor professor = Professor(
    correo: "gabrielvielma91@gmail.com",
    imagen:
        "https://lh3.googleusercontent.com/cm/AGPWSu9E4K66u1GRzKXEbgoqerRKCGDtMzMaNt50-8szNfgiZhmDJwptPK_Ta8_Om1jva7HOBw=s48-p",
    id: "20408381",
    telefono: "04145021471",
    nombre: "Gabriel Vielma");

    SubProyect subproyecto = SubProyect(
        id: "ULF15HUa6V5ALe9YeuU5",
        nombre: "Organización de Sistemas",
        profesor: "20408381"
        );
