import 'dart:convert';

import 'package:asistencia/app_theme.dart';
import 'package:asistencia/models/attendance.dart';
import 'package:asistencia/models/professor.dart';
import 'package:asistencia/models/subproyect.dart';
import 'package:asistencia/models/subproyecto.dart';
import 'package:asistencia/screens/attendance_detail_screen.dart';
import 'package:asistencia/screens/create_attendance_screen.dart';
import 'package:asistencia/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class ProyectScreen extends StatefulWidget {
  final SubProyect subproyecto;
  const ProyectScreen(this.subproyecto, {super.key});

  @override
  State<ProyectScreen> createState() => _ProyectScreenState();
}

class _ProyectScreenState extends State<ProyectScreen> {
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listarAsistencias();
  }
  Future<void> listarAsistencias() async {
    isLoading = true;
    setState(() {});
    const url =
        'https://api-springboot-hdye.onrender.com/asistenciassubproyecto';
    String body = widget.subproyecto.id; // reemplaza con el string que deseas enviar

    final response = await http.post(Uri.parse(url), body: body);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      List list = jsonDecode(response.body);
          list.map((json) => Attendance.fromJson(json));
      print(list);
      if (list.isNotEmpty) {
        setState(() {
          listAttendance = list
              .map((json) => Attendance.fromJson(json))
              .toList()
              .cast<Attendance>();
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
            widget.subproyecto.nombre,
            style: AppTheme.headline,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar',
              onPressed: () {
                listarAsistencias();
              },
            ),
          ],
        ),
        body: 
        isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              ):
        
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            if (listAttendance .isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  textAlign: TextAlign.center,
                  "Aún no se han creado listas de asistencia",
                  style: TextStyle(),
                ),
              ),
            Flexible(
              child: ListView.builder(
                itemCount: listAttendance .length,
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
                              const Icon(Icons.edit, color: Colors.white),
                              const Text(
                                "Editar",
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2,
                              ),
                            ],
                          ),
                        ),
                        direction: DismissDirection.endToStart,
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
                                "ELIMINAR",
                                style: TextStyle(color: Colors.white),
                              ),
                              const Icon(Icons.delete, color: Colors.white),
                            ],
                          ),
                        ),
                        key: UniqueKey(),
                        confirmDismiss: (DismissDirection direction) async {
                          if (direction == DismissDirection.endToStart) {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirmación"),
                                  content: const Text(
                                      "¿Estás seguro que quieres eliminar? \n\n Se perderá todo el registro de asistencia, esta acción no la puedes deshacer."),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("Cancelar"),
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          print("Eliminar");
                                          print(index);

                                          listAttendance 
                                              .remove(listAttendance [index]);
                                          setState(() {});
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text("Eliminar")),
                                  ],
                                );
                              },
                            );
                          } else {
                            /* Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentDetailScreen(
                                  student: listAttendance [index],
                                ),
                              ),
                            ); */

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
                              const Icon(Icons.contact_page),
                              Text("#${index + 1}", style: AppTheme.textbutton),
                            ],
                          ),
                          title: const Text(
                            "Lista de asistencia",
                            style: AppTheme.subtitle2,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                listAttendance [index].fecha,
                                style: AppTheme.caption,
                              ),
                               Text(professor.nombre,
                                  style: AppTheme.subtitle1),
                            ],
                          ),
                          //isThreeLine: true,
                          trailing: Column(
                            children: [
                              IconButton(
                                icon: const Column(
                                  children: [
                                    Icon(Icons.visibility,
                                        color: AppTheme.primary),
                                    Text(
                                      style: AppTheme.textbutton,
                                      "Ver",
                                    )
                                  ],
                                ),
                                onPressed: () {
                                  print(
                                      listAttendance [index]);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AttendanceDetailScreen(
                                              "Ver",
                                              listAttendance [index]),
                                    ),
                                  );
                                },
                              ),
                              /* IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CreateAttendanceScreen("Editar"),
                                    ),
                                  );
                                },
                              ), */
                            ],
                          ),
                        ),
                      ));
                },
              ),
            ),
          ]),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Attendance attendance = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateAttendanceScreen("Crear"),
              ),
            );
            listEstudiantes = [];
            agregarAttendance(attendance);
          },
          tooltip: 'Agregar Asistencia',
          child: const Icon(Icons.add),
        ));
  }

  Future<void> agregarAttendance(attendance) async {
    setState(() {


      listAttendance .add(attendance);
      mensaje('¡Asistencia creada exitosamente!', "y");
    });
  }

  /*  Future<void> editarAttendance(index, attendance) async {
    setState(() {
      listAttendance [index] = attendance;
      mensaje('¡Asistencia editada exitosamente!', "y");
    });
  } */

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
