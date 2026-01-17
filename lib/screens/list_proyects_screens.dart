import 'dart:convert';

import 'package:asistencia/models/professor.dart';
import 'package:asistencia/models/subproyect.dart';
import 'package:asistencia/screens/justificativo_screen.dart';
import 'package:asistencia/screens/login_screen.dart';
import 'package:asistencia/screens/profile_screen.dart';
import 'package:asistencia/screens/proyect_screen.dart';
import 'package:asistencia/screens/waiting.dart';
import 'package:asistencia/services/auth_service.dart';
import 'package:asistencia/services/config_service.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  initState() {
    super.initState();
    listarSubproyectos();
  }

  Future<void> verificarAprobacion() async {
    final value = await AuthService().usuarioActual();
    setState(() {
      professor = value;
    });
    if (professor.aprobado != "aprobado") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const WaitingScreen(),
        ),
      );
    }
  }

  Future<void> listarSubproyectos() async {
    await verificarAprobacion();
    listSubproyectos = [];
    isLoading = true;
    setState(() {});
    final url = '${ConfigService().apiUrl}/listasubproyectosprofesor';
    String body = jsonEncode({'id': professor.id});

    final headers = {
      'Content-Type': 'application/json',
    };
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      List list = jsonDecode(response.body);
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
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Column(
              children: [
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildProjectList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                onPressed: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "Mis Subproyectos",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                tooltip: 'Actualizar',
                onPressed: listarSubproyectos,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectList() {
    if (listSubproyectos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.assignment_outlined,
                  size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                "No hay subproyectos asignados",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                "Comunícate con el administrador para que te asignen uno.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: listSubproyectos.length,
      itemBuilder: (BuildContext context, int index) {
        final subproject = listSubproyectos[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProyectScreen(subproject),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.class_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subproject.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            professor.nombre,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.tertiary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    key: ValueKey(
                        professor.imagen), // Force rebuild if URL changes
                    radius: 40,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: (professor.imagen.isEmpty)
                        ? null
                        : NetworkImage(professor.imagen),
                    child: professor.imagen.isEmpty
                        ? const Icon(Icons.person, size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  professor.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  professor.correo,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildDrawerItem(
            icon: Icons.person_outline,
            title: 'Perfil',
            onTap: () async {
              final datosActualizados = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditarPerfilScreen(profesor: professor),
                ),
              );
              if (datosActualizados != null) {
                setState(() {
                  professor = Professor.fromJson(datosActualizados);
                });
              }
            },
          ),
          _buildDrawerItem(
            icon: Icons.description_outlined,
            title: 'Justificativos',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JustificativoScreen(professor),
                ),
              );
            },
          ),
          const Spacer(),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.logout_rounded,
            title: 'Cerrar Sesión',
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading:
          Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  Future<void> agregarSubProyecto(subproyect) async {
    setState(() {
      listSubproyectos.add(subproyect);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subproyecto ${subproyect.nombre} agregado!')),
      );
    });
  }
}
