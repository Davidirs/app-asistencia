import 'package:asistencia/app_theme.dart';
import 'package:asistencia/models/student.dart';
import 'package:flutter/material.dart';

class StudentDetailScreen extends StatelessWidget {
  final Student student;
  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "Información del estudiante",
          style: AppTheme.headline,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Carrera",
                        style: AppTheme.title,
                      ),
                      Text(
                        student.carrera,
                        style: AppTheme.body2,
                      ),
                      const Text(
                        "Periodo académico:",
                        style: AppTheme.title,
                      ),
                      Text(
                        student.periodo,
                        style: AppTheme.body2,
                      ),
                    ],
                  ),
                  Image.asset(
                    "assets/images/logo-unellez.png",
                    width: 60,
                    height: 60,
                    color: Colors.red,
                  ),
                ],
              ),
              const Divider(),
              CircleAvatar(
                radius: 80,
                child: Image.asset(
                  "assets/images/logo-unellez.png",
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Link de imagen:",
                    style: AppTheme.title,
                  ),
                  Text(
                    student.imagen,
                    style: AppTheme.body2,
                  ),
                  const Text(
                    "Nombres:",
                    style: AppTheme.title,
                  ),
                  Text(
                    student.nombre,
                    style: AppTheme.body2,
                  ),
                  const Text(
                    "Cedula:",
                    style: AppTheme.title,
                  ),
                  Text(
                    student.cedula,
                    style: AppTheme.body2,
                  ),
                  const Text(
                    "Fecha de Nacimiento:",
                    style: AppTheme.title,
                  ),
                  Text(
                    student.fechaNacimiento,
                    style: AppTheme.body2,
                  ),
                  const Divider(),
                  const Text(
                    "Estado de inscripcion:",
                    style: AppTheme.title,
                  ),
                  Text(
                    student.estado,
                    style: AppTheme.body2,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
