import 'dart:convert';

import 'package:asistencia/models/attendance.dart';
import 'package:asistencia/models/student.dart';
import 'package:asistencia/screens/scraping_unellez.dart';
import 'package:asistencia/screens/student_detail_screen.dart';
import 'package:asistencia/services/config_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AttendanceDetailScreen extends StatefulWidget {
  final String title;
  final Attendance attendance;
  const AttendanceDetailScreen(this.title, this.attendance, {super.key});

  @override
  State<AttendanceDetailScreen> createState() => _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
  bool isLoading = false;
  List<Student> listEstudiantes = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    isLoading = true;
    if (mounted) setState(() {});

    final url = '${ConfigService().apiUrl}/buscarestudiantes';
    String body = jsonEncode(widget.attendance.estudiantes);
    final headers = {'Content-Type': 'application/json'};

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      print("Respuesta: ${response.body}");

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      if (response.statusCode == 200) {
        List list = jsonDecode(response.body);
        if (list.isNotEmpty) {
          if (mounted) {
            setState(() {
              listEstudiantes = list
                  .map((json) => Student.fromJson(json))
                  .toList()
                  .cast<Student>();
            });
          }
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print("Error loading data: $e");
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildInfoCard(),
                        _buildStudentListTitle(),
                        isLoading
                            ? const Center(
                                child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator()))
                            : _buildStudentList(),
                      ],
                    ),
                  ),
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
                  "${widget.title} Asistencia",
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
                onPressed: cargarDatos,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
              Icons.calendar_today, "Fecha", widget.attendance.fecha),
          const Divider(height: 30),
          _buildDetailRow(Icons.description_outlined, "Comentario",
              widget.attendance.descripcion),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentListTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Listado de estudiantes",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${widget.attendance.estudiantes.length} Total",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    if (widget.attendance.estudiantes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.person_off_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 10),
            const Text(
              "Aún no se han agregado estudiantes",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.attendance.estudiantes.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildStudentCard(context, index);
      },
    );
  }

  Widget _buildStudentCard(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.startToEnd,
          background: Container(
            color: Colors.green,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Row(
              children: [
                Icon(Icons.visibility, color: Colors.white),
                SizedBox(width: 10),
                Text("VER DETALLE",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          secondaryBackground: Container(
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
          confirmDismiss: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart) {
              // Delete
              return await showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text("Confirmación"),
                  content: const Text("¿Estás seguro que quieres eliminar?"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancelar")),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white),
                        onPressed: () {
                          widget.attendance.estudiantes.removeAt(index);
                          setState(() {});
                          Navigator.pop(context, true);
                        },
                        child: const Text("Eliminar")),
                  ],
                ),
              );
            } else {
              // View
              if (listEstudiantes.isNotEmpty &&
                  index < listEstudiantes.length) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StudentDetailScreen(student: listEstudiantes[index]),
                  ),
                );
              }
              return false;
            }
          },
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              widget.attendance.estudiantes[index],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              (listEstudiantes.isNotEmpty && index < listEstudiantes.length)
                  ? listEstudiantes[index].nombre
                  : 'Cargando nombre...',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: _buildStatusIcon(index),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(int index) {
    if (listEstudiantes.isEmpty || index >= listEstudiantes.length) {
      return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2));
    }

    final estado = listEstudiantes[index].estado;

    if (estado == "SIN VERIFICAR") {
      return IconButton(
        tooltip: 'Verificar Estudiante',
        icon: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.sync, color: Colors.orange, size: 20),
        ),
        onPressed: () async {
          final nuevoEstudiante =
              await verificarEstudiante(widget.attendance.estudiantes[index]);
          setState(() {
            listEstudiantes[index] = nuevoEstudiante;
          });
        },
      );
    } else if (estado == "NO REGISTRADO") {
      return Icon(Icons.cancel, color: Colors.red[300]);
    } else {
      return Icon(Icons.check_circle, color: Colors.green[400]);
    }
  }

  Future<Student> verificarEstudiante(String cedula) async {
    // Note: Assuming cedula is String based on previous code usage
    Student respuesta = StudentNoVerificado.fromCedula(cedula);
    try {
      // Assuming dataFromUnellez takes cedula
      // Note: dataFromUnellez signature was not visible in context but used in original code
      // I'm keeping the logic as is.
      Student estudianteVerificado = await dataFromUnellez(cedula);

      if (estudianteVerificado.estado == "SIN VERIFICAR") {
        _mostrarMensaje('¡No se pudo verificar!', Colors.orange);
      } else if (estudianteVerificado.cedula.isEmpty) {
        respuesta = StudentNoRegistrado.fromCedula(cedula);
        _mostrarMensaje('¡Estudiante no existe!', Colors.red);
      } else {
        respuesta = estudianteVerificado;
        _mostrarMensaje('¡Verificado exitosamente!', Colors.green);
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión', Colors.red);
    }
    return respuesta;
  }

  void _mostrarMensaje(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }
}
