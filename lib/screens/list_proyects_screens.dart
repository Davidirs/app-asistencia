import 'dart:convert';

import 'package:asistencia/app_theme.dart';
import 'package:asistencia/models/professor.dart';
import 'package:asistencia/models/subproyect.dart';
import 'package:asistencia/screens/justificativo_screen.dart';
import 'package:asistencia/screens/login_screen.dart';
import 'package:asistencia/screens/profile_screen.dart';
import 'package:asistencia/screens/proyect_screen.dart';
import 'package:asistencia/screens/waiting.dart';
import 'package:asistencia/services/auth_service.dart';
import 'package:asistencia/utils/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ListProyectsScreen extends StatefulWidget {
  const ListProyectsScreen({super.key});

  @override
  State<ListProyectsScreen> createState() => _ListProyectsScreenState();
}

class _ListProyectsScreenState extends State<ListProyectsScreen> {
  bool isLoading = false;
  @override
  initState() {
    super.initState();
    listarSubproyectos();
  }

  Future<void> verificarAprobacion() async {
    AuthService().usuarioActual().then((value) {
      setState(() {
        professor = value;
      });
      if (professor.aprobado != "aprobado") {
        // Si el usuario no tiene CI, redirigir a la pantalla de login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const WaitingScreen(),
          ),
        );
      }
    });
  }

  Future<void> listarSubproyectos() async {
    verificarAprobacion();
    listSubproyectos = [];
    isLoading = true;
    setState(() {});
    const url =
        'https://api-springboot-hdye.onrender.com/listasubproyectosprofesor';
    print(professor.ci);
    String body = jsonEncode({'id': professor.id}); // reemplaza con el string que deseas enviar
    
  final headers = {
    'Content-Type': 'application/json',
  };
    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      List list = jsonDecode(response.body);
      list.map((json) => Professor.fromJson(json));
      print(list);
      if (list.isNotEmpty) {
        setState(() {
          listSubproyectos = list
              .map((json) => SubProyect.fromJson(json))
              .toList()
              .cast<SubProyect>();
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
        title: const Text("SubProyectos", style: AppTheme.headline),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              listarSubproyectos();
            },
          ),
        ],
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // Important: Remove any padding from the ListView.

          children: [
            Column(
              children: [
                UserAccountsDrawerHeader(
                  currentAccountPicture: 
                  CircleAvatar(
                radius: 50,
                backgroundImage: (professor.imagen == null || professor.imagen!.isEmpty)
                    ? null
                    : Image.network(professor.imagen!).image,
                child: professor.imagen == null || professor.imagen!.isEmpty
                    ? Icon(Icons.person, size: 50, color: AppTheme.primary)
                    :null
              ),
                  accountName: Text(professor.nombre, style: AppTheme.title),
                  accountEmail:
                      Text(professor.correo, style: AppTheme.subtitle2),
                  decoration: const BoxDecoration(color: AppTheme.white),
                ),
                 Container(
                  color: AppTheme.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                   child: ListTile(
                      title: const Text('Perfil'), 
                      onTap: () async {
                        // Update the state of the app.
                        // ...
                       final datosActualizados  = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>  EditarPerfilScreen(
                              profesor: professor,
                            ),
                          ),
                        );
                        print("Datos actualizados: ${datosActualizados}");
                        if (datosActualizados != null) {
                          setState(() {
                            professor = Professor.fromJson(datosActualizados);
                            print("Nuevo profesor: ${professor}");
                          });
                        }
                      },
                      leading: const Icon(Icons.person, color: AppTheme.primary),
                      trailing: const Icon(
                        Icons.arrow_right,
                        color: AppTheme.primary,
                      ),
                    ),
                    
                 ),
                 SizedBox(height: 8),
                 Container(
                  color: AppTheme.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                   child: ListTile(
                      title: const Text('Justificativos'), 
                      onTap: () {
                        // Update the state of the app.
                        // ...
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>   JustificativoScreen(
                               professor,
                            ),
                          ),
                        );
                      },
                      leading: const Icon(Icons.file_copy, color: AppTheme.primary),
                      trailing: const Icon(
                        Icons.arrow_right,
                        color: AppTheme.primary,
                      ),
                    ),
                    
                 ),
                  /*
                  ListTile(
                    title: const Text('Item 2'),
                    onTap: () {
                      // Update the state of the app.
                      // ...
                    },
                  ), */
              ],
            ),
            Column(
              children: [
                const Divider(),
                TextButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("cerrar sesión",
                        style: AppTheme.textbutton)),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                if (listSubproyectos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      textAlign: TextAlign.center,
                      "Aún no se han asignado subproyectos a este profesor, por favor comuniquese con el administrador.",
                      style: TextStyle(),
                    ),
                  ),
                Flexible(
                  child: ListView.builder(
                    itemCount: listSubproyectos.length,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Icon(Icons.edit, color: Colors.white),
                                  const Text(
                                    "Editar",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
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

                                              listSubproyectos.remove(
                                                  listSubproyectos[index]);
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
                                  student: listSubproyectos[index],
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
                                  const Icon(Icons.menu_book),
                                  Text("#${index + 1}",
                                      style: AppTheme.textbutton),
                                ],
                              ),
                              title: Text(listSubproyectos[index].nombre,
                                  style: AppTheme.subtitle2),
                              subtitle: Text(professor.nombre,
                                  style: AppTheme.caption),
                              //isThreeLine: true,
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppTheme.primary,
                                ),
                                onPressed: () {
                                  print(listSubproyectos[index].nombre);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProyectScreen(
                                          listSubproyectos[index]),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ));
                    },
                  ),
                ),
              ]),
            ),
      /* floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final subproyect = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateSubProyectScreen(),
              ),
            );
            agregarSubProyecto(subproyect);
          },
          tooltip: 'Agregar SubProyecto',
          child: const Icon(Icons.add),
        )*/
    );
  }

  Future<void> agregarSubProyecto(subproyect) async {
    setState(() {
      listSubproyectos.add(subproyect);
      mensaje('¡Subproyecto ${subproyect.nombre} agregado!', "y");
    });
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
