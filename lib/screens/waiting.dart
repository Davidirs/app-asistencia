import 'package:asistencia/app_theme.dart';
import 'package:asistencia/screens/list_proyects_screens.dart';
import 'package:asistencia/screens/login_screen.dart';
import 'package:asistencia/services/auth_service.dart';
import 'package:asistencia/utils/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WaitingScreen extends StatefulWidget {
  const WaitingScreen({super.key});

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  bool isLoading = false;
  @override
  initState() {
    super.initState();
    print("initState");
   
    verificarAprobacion();
  }

  Future<void> verificarAprobacion() async {
     AuthService().usuarioActual().then((value) {
      setState(() {
        professor = value;
      });
      if (professor.aprobado == "aprobado") {
        // Si el usuario no tiene CI, redirigir a la pantalla de login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ListProyectsScreen(
              // Aquí puedes pasar los parámetros necesarios
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Estado de Apobación", style: AppTheme.headline),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              verificarAprobacion();
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
                  currentAccountPicture: CircleAvatar(
                    child: professor.imagen != ''?Image.network(
                      professor.imagen ,
                      fit: BoxFit.cover,
                    ):Icon(Icons.person, size: 50, color: AppTheme.primary),
                  ),
                  accountName: Text(professor.nombre, style: AppTheme.title),
                  accountEmail:
                      Text(professor.correo, style: AppTheme.subtitle2),
                  decoration: const BoxDecoration(color: AppTheme.white),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                if (professor.ci == "")
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      textAlign: TextAlign.center,
                      "Hace falta información por favor inicie sesión nuevamente",
                      style: TextStyle(),
                    ),
                  
                ),
                if (professor.aprobado == "pendiente")
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      textAlign: TextAlign.center,
                      "Su solicitud de aprobación está pendiente, un administrador la revisará pronto.",
                      style: TextStyle(),
                    ),
                  
                ),
                if (professor.aprobado == "rechazado")
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      textAlign: TextAlign.center,
                      "Su solicitud de aprobación ha sido rechazada, esto indica que no podrá acceder a la aplicación, si es un profesor y cree que puede ser aprobado, por favor comuniquese con un administrador.",
                      style: TextStyle(),
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
