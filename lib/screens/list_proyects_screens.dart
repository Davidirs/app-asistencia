import 'package:asistencia/app_theme.dart';
import 'package:asistencia/screens/create_subproyect_screen.dart';
import 'package:asistencia/screens/proyect_screen.dart';
import 'package:asistencia/utils/globals.dart';
import 'package:flutter/material.dart';

class ListProyectsScreen extends StatefulWidget {
  const ListProyectsScreen({super.key});

  @override
  State<ListProyectsScreen> createState() => _ListProyectsScreenState();
}

class _ListProyectsScreenState extends State<ListProyectsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("SubProyectos", style: AppTheme.headline),
          centerTitle: true,
        ),
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // Important: Remove any padding from the ListView.

            children: [
              const Column(
                children: [
                  UserAccountsDrawerHeader(
                    currentAccountPicture: CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    accountName:
                        Text("Nombre del docente", style: AppTheme.title),
                    accountEmail:
                        Text("correo@correo.com", style: AppTheme.subtitle2),
                    decoration: BoxDecoration(color: AppTheme.white),
                  ),
                  /* ListTile(
                    title: const Text('Item 1'),
                    onTap: () {
                      // Update the state of the app.
                      // ...
                    },
                  ),
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
                      onPressed: () {},
                      icon: const Icon(Icons.logout),
                      label: const Text("cerrar sesión",
                          style: AppTheme.textbutton))
                ],
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            if (listSubproyectos.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  textAlign: TextAlign.center,
                  "Aún no se han agregado estudiantes a esta lista de asistencia",
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

                                          listSubproyectos
                                              .remove(listSubproyectos[index]);
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
                              Text("#${index + 1}", style: AppTheme.textbutton),
                            ],
                          ),
                          title: Text(listSubproyectos[index].nombre,
                              style: AppTheme.subtitle2),
                          subtitle: const Text("Nombre del docente",
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
                                  builder: (context) =>
                                      ProyectScreen(listSubproyectos[index]),
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
        floatingActionButton: FloatingActionButton(
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
        ));
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
