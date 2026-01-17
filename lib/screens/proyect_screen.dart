import 'dart:convert';

import 'package:asistencia/models/attendance.dart';
import 'package:asistencia/models/subproyect.dart';
import 'package:asistencia/screens/attendance_detail_screen.dart';
import 'package:asistencia/screens/create_attendance_screen.dart';
import 'package:asistencia/services/config_service.dart';
import 'package:asistencia/utils/globals.dart';
import 'package:flutter/material.dart';
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
    super.initState();
    listarAsistencias();
  }

  Future<void> listarAsistencias() async {
    isLoading = true;
    listAttendance = [];
    if (mounted) setState(() {});

    final url = '${ConfigService().apiUrl}/asistenciassubproyecto';
    String body = jsonEncode({'id': widget.subproyecto.id});
    print("Cargando asistencias del subproyecto: ${widget.subproyecto.id}");

    final headers = {'Content-Type': 'application/json'};

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      if (response.statusCode == 200) {
        List list = jsonDecode(response.body);
        print(list);
        if (list.isNotEmpty) {
          if (mounted) {
            setState(() {
              listAttendance = list
                  .map((json) => Attendance.fromJson(json))
                  .toList()
                  .cast<Attendance>();
            });
          }
        } else {
          print('No hay asistencias disponibles');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print("Error al conectar: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                      : _buildAttendanceList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          subproyecto = widget.subproyecto;
          Attendance? attendance = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateAttendanceScreen("Crear"),
            ),
          );
          if (attendance != null) {
            listEstudiantes = [];
            agregarAttendance(attendance);
          }
        },
        tooltip: 'Agregar Asistencia',
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 140,
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  widget.subproyecto.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Actualizar',
                onPressed: listarAsistencias,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (listAttendance.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Aún no se han creado listas de asistencia",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listAttendance.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildAttendanceCard(context, index);
      },
    );
  }

  Widget _buildAttendanceCard(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("ELIMINAR",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Icon(Icons.delete, color: Colors.white),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Confirmación"),
                  content: const Text(
                      "¿Estás seguro que quieres eliminar? \n\nSe perderá todo el registro de asistencia, esta acción no la puedes deshacer."),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Cancelar"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        listAttendance.remove(listAttendance[index]);
                        setState(() {});
                        Navigator.of(context).pop(true);
                      },
                      child: const Text("Eliminar"),
                    ),
                  ],
                );
              },
            );
          },
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Text(
                "#${index + 1}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: const Text(
              "Lista de asistencia",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 5),
                    Text(
                      listAttendance[index].fecha,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        professor.nombre,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AttendanceDetailScreen("Ver", listAttendance[index]),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> agregarAttendance(attendance) async {
    setState(() {
      listAttendance.add(attendance);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Asistencia creada exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
}
