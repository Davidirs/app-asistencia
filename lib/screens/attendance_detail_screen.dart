import 'dart:convert';

import 'package:asistencia/app_theme.dart';
import 'package:asistencia/models/attendance.dart';
import 'package:asistencia/models/student.dart';
import 'package:asistencia/screens/scraping_unellez.dart';
import 'package:asistencia/screens/student_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AttendanceDetailScreen extends StatefulWidget {
  final title;
  final Attendance attendance;
  const AttendanceDetailScreen(this.title, this.attendance, {super.key});

  @override
  State<AttendanceDetailScreen> createState() => _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
  bool isLoading = false;
  List<Student> listEstudiantes = [];
  @override
  initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    isLoading = true;
    setState(() {});
    const url =
        'https://api-springboot-hdye.onrender.com/buscarestudiantes';
    String body = jsonEncode(widget.attendance.estudiantes); // reemplaza con el string que deseas enviar
    
    
  final headers = {
    'Content-Type': 'application/json',
  };

  final response = await http.post(Uri.parse(url), headers: headers, body: body);
    print("Respuesta: ${response.body}");
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      List list = jsonDecode(response.body);
      list.map((json) => Student.fromJson(json));
      print(list);
      if (list.isNotEmpty) {
        setState(() {
          listEstudiantes = list
              .map((json) => Student.fromJson(json))
              .toList()
              .cast<Student>();
        });
      } else {
        print('No hay subproyectos disponibles');
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title + " asistencia",
          style: AppTheme.headline,
        ),
        centerTitle: true,
        actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar',
              onPressed: () {
                cargarDatos();
              },
            ),
          ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Fecha: ",
                  style: AppTheme.title,
                ),
                Text(
                  widget.attendance.fecha,
                  style: AppTheme.body2,
                ),
                const Text(
                  "Comentario: ",
                  style: AppTheme.title,
                ),
                Text(
                  widget.attendance.descripcion,
                  maxLines: 3,
                  style: AppTheme.body2,
                ),
                const Divider(),
              ],
            ),
            const Text(
              "Listado de estudiantes",
              style: AppTheme.title,
            ),
            if (widget.attendance.estudiantes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  textAlign: TextAlign.center,
                  "Aún no se han agregado estudiantes a esta lista de asistencia",
                  style: TextStyle(),
                ),
              ),if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            Flexible(
              child: ListView.builder(
                itemCount: widget.attendance.estudiantes.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            //color: Colors.red,
                            offset: Offset.zero,
                            blurRadius: 0.1,
                            spreadRadius: 0.1,
                          ),
                        ],
                        color: Colors.white,
                      ),
                      child: Dismissible(
                        background: Container(
                          decoration: const BoxDecoration(
                            //borderRadius: BorderRadius.circular(10),
                            color: Colors.green,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Icon(Icons.info, color: Colors.white),
                              const Text(
                                "Ver Información",
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2,
                              ),
                            ],
                          ),
                        ),
                        secondaryBackground: Container(
                          decoration: const BoxDecoration(
                            //borderRadius: BorderRadius.circular(10),
                            color: Colors.red,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2,
                              ),
                              const Text(
                                "Eliminar",
                                style: TextStyle(color: Colors.white),
                              ),
                              const Icon(Icons.delete, color: Colors.white),
                            ],
                          ),
                        ),
                        key: UniqueKey(),
                        direction: DismissDirection.startToEnd,
                        confirmDismiss: (DismissDirection direction) async {
                          if (direction == DismissDirection.endToStart) {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirmación"),
                                  content: const Text(
                                      "¿Estás seguro que quieres eliminar?, esta acción no la puedes deshacer."),
                                  actions: <Widget>[
                                    ElevatedButton(
                                        onPressed: () {
                                          print("Eliminar");
                                          print(index);

                                          widget.attendance.estudiantes.remove(
                                              widget.attendance
                                                  .estudiantes[index]);
                                          setState(() {});
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text("ELIMINAR")),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("CANCELAR"),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            if (listEstudiantes.isNotEmpty)
                             Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentDetailScreen(
                                  student: listEstudiantes[index],
                                ),
                              ),
                            );

                            return false;
                          }
                        },
                        onDismissed: (DismissDirection direction) {
                          if (direction == DismissDirection.endToStart) {
                          } else {}
                        },
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.person),
                              Text(
                                "#${index + 1}",
                                style: AppTheme.textbutton,
                              ),
                            ],
                          ),
                          title: Text(
                            widget.attendance.estudiantes[index],
                            style: AppTheme.subtitle2,
                          ),
                          subtitle: Text(listEstudiantes.isEmpty?
                            'Nombre del estudiante':
                            listEstudiantes[index].nombre,
                            style: AppTheme.caption,
                          ), 
                          //isThreeLine: true,
                          trailing:listEstudiantes.isNotEmpty? listEstudiantes[index].estado ==
                                  "SIN VERIFICAR"
                              ? IconButton(
                                  onPressed: () async {
                                    print("Verificar");

                                    listEstudiantes[index] =
                                        await verificarEstudiante(widget
                                            .attendance
                                            .estudiantes[index]
                                            .cedula);
                                    setState(() {});
                                  },
                                  icon: const Column(
                                    children: [
                                      Icon(
                                        Icons.cloud_sync,
                                        color: Colors.orange,
                                      ),
                                      Text(
                                        "Verificar",
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ))
                              : listEstudiantes[index].estado ==
                                      "NO REGISTRADO"
                                  ? const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    )
                                  : const Icon(
                                      Icons.verified,
                                      color: Colors.green,
                                    ): const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                        
                        ),
                      ));
                },
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  Future<Student> verificarEstudiante(cedula) async {
    Student respuesta = StudentNoVerificado.fromCedula(cedula);
    try {
      Student estudianteVerificado = await dataFromUnellez(cedula);

      if (estudianteVerificado.estado == "SIN VERIFICAR") {
        //respuesta = estudianteNoVerificado;
        mensaje(
            '¡Estudiante $cedula no se puede verificar en este momento!', "n");
      } else if (estudianteVerificado.cedula.isEmpty) {
        respuesta = StudentNoRegistrado.fromCedula(cedula);
        mensaje('¡Estudiante $cedula no existe!', "n");
      } else {
        respuesta = estudianteVerificado;
        mensaje('¡Estudiante $cedula Verificado exitosamente!', "y");
      }
    } catch (e) {
      mensaje('¡Error al agregar estudiante $cedula!', "n");
    }
    return respuesta;
  }

  mensaje(String msg, color) {
    // Muestra un mensaje al volver a la página anterior
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color == "y" ? Colors.green : Colors.red,
      ),
    );
  }
}
