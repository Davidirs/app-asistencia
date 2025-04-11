import 'package:asistencia/app_theme.dart';
import 'package:asistencia/models/attendance.dart';
import 'package:asistencia/models/subproyect.dart';
import 'package:asistencia/screens/attendance_detail_screen.dart';
import 'package:asistencia/screens/create_attendance_screen.dart';
import 'package:asistencia/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProyectScreen extends StatefulWidget {
  final SubProyect subproyecto;
  const ProyectScreen(this.subproyecto, {super.key});

  @override
  State<ProyectScreen> createState() => _ProyectScreenState();
}

class _ProyectScreenState extends State<ProyectScreen> {
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
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            if (widget.subproyecto.listAttendance.isEmpty)
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
                itemCount: widget.subproyecto.listAttendance.length,
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

                                          widget.subproyecto.listAttendance
                                              .remove(widget.subproyecto
                                                  .listAttendance[index]);
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
                                  student: widget.subproyecto.listAttendance[index],
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
                                widget.subproyecto.listAttendance[index].fecha,
                                style: AppTheme.caption,
                              ),
                              const Text("Nombre del profesor",
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
                                      widget.subproyecto.listAttendance[index]);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AttendanceDetailScreen(
                                              "Ver",
                                              widget.subproyecto
                                                  .listAttendance[index]),
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
      widget.subproyecto.listAttendance.add(attendance);
      mensaje('¡Asistencia creada exitosamente!', "y");
    });
  }

  /*  Future<void> editarAttendance(index, attendance) async {
    setState(() {
      widget.subproyecto.listAttendance[index] = attendance;
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
