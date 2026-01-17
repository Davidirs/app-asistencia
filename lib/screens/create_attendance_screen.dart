import 'dart:convert';

import 'package:asistencia/models/attendance.dart';
import 'package:asistencia/models/student.dart';
import 'package:asistencia/screens/full_image_view.dart';
import 'package:asistencia/screens/scanner_screen.dart';
import 'package:asistencia/screens/scraping_unellez.dart';
import 'package:asistencia/screens/student_detail_screen.dart';
import 'package:asistencia/screens/upload_image.dart';
import 'package:asistencia/services/store_service.dart';
import 'package:asistencia/services/config_service.dart';
import 'package:asistencia/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateAttendanceScreen extends StatefulWidget {
  final String title;
  const CreateAttendanceScreen(this.title, {super.key});

  @override
  State<CreateAttendanceScreen> createState() => _CreateAttendanceScreenState();
}

class _CreateAttendanceScreenState extends State<CreateAttendanceScreen> {
  TextEditingController controller = TextEditingController();
  TextEditingController commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>(); // Clave para el formulario
  String commentary = "";
  String imageUrl = "";

  @override
  void dispose() {
    controller.dispose();
    _focusNode.dispose();
    commentController.dispose();
    super.dispose();
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
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
                    child: Column(
                      children: [
                        _buildAddStudentCard(),
                        const SizedBox(height: 20),
                        _buildStudentListHeader(),
                        const SizedBox(height: 10),
                        _buildStudentList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: listEstudiantes.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _finalizeAttendance,
              label: const Text('Finalizar',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.check, color: Colors.white),
              backgroundColor: Theme.of(context).colorScheme.primary,
            )
          : null,
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
              if (imageUrl.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullImageView(imageUrl: imageUrl),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(imageUrl),
                    radius: 20,
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  tooltip: 'Tomar foto',
                  onPressed: _takePicture,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddStudentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Agregar Estudiante",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    focusNode: _focusNode,
                    onFieldSubmitted: (value) => _submitStudent(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Cédula de Identidad',
                      hintText: 'Ej. 24114415',
                      prefixIcon: Icon(Icons.badge_outlined,
                          color: Theme.of(context).colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese cédula';
                      }
                      if (value.length < 6) {
                        return 'Mínimo 6 dígitos';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.qr_code_scanner,
                        color: Theme.of(context).colorScheme.primary),
                    onPressed: _scanQR,
                    tooltip: 'Escanear QR',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _addComment,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.comment_outlined,
                        size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        commentary.isEmpty
                            ? "Agregar un comentario general..."
                            : commentary,
                        style: TextStyle(
                          color: commentary.isEmpty
                              ? Colors.grey[500]
                              : Colors.black87,
                          fontStyle: commentary.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Estudiantes en lista",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "${listEstudiantes.length}",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentList() {
    if (listEstudiantes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(Icons.group_outlined, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 10),
              Text(
                "No hay estudiantes agregados",
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: listEstudiantes.length,
      itemBuilder: (context, index) {
        final student = listEstudiantes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
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
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async => await _confirmDelete(index),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  child: Text(
                    "${index + 1}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  student.cedula,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(student.nombre),
                trailing: _buildStatusIcon(student, index),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StudentDetailScreen(student: student),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(Student student, int index) {
    if (student.estado == "SIN VERIFICAR") {
      return IconButton(
        icon: const Icon(Icons.sync, color: Colors.orange),
        onPressed: () async {
          listEstudiantes[index] = await verificarEstudiante(student.cedula);
          setState(() {});
        },
      );
    } else if (student.estado == "NO REGISTRADO") {
      return const Icon(Icons.error_outline, color: Colors.red);
    } else {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
  }

  Future<void> _submitStudent() async {
    if (_formKey.currentState!.validate()) {
      bool existe = listEstudiantes
          .any((estudiante) => estudiante.cedula == controller.text);

      if (existe) {
        mensaje('¡Estudiante ya agregado!', "n");
      } else {
        await agregarEstudiante(controller, controller.text);
        controller.clear();
      }
    }
    _focusNode.unfocus();
  }

  Future<void> _takePicture() async {
    final url = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScreen('asistencias'),
      ),
    );

    if (url != null) {
      setState(() {
        imageUrl = url;
      });
    }
  }

  Future<void> _scanQR() async {
    final cedula = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScannerScreen(),
      ),
    );
    if (cedula != null) {
      agregarEstudiante(controller, cedula);
    }
  }

  Future<void> _addComment() async {
    commentController.text = commentary;
    final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Comentario'),
            content: TextFormField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Escriba un comentario sobre esta asistencia...',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pop(commentController.text),
                child: const Text('Guardar'),
              ),
            ],
          );
        });

    if (result != null) {
      setState(() {
        commentary = result;
      });
    }
  }

  Future<bool> _confirmDelete(int index) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirmar eliminación"),
              content: const Text(
                  "¿Estás seguro de eliminar a este estudiante de la lista?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white),
                    onPressed: () {
                      listEstudiantes.removeAt(index);
                      setState(() {});
                      Navigator.of(context).pop(true);
                    },
                    child: const Text("Eliminar")),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _finalizeAttendance() async {
    bool hayNoRegistrados = listEstudiantes
        .any((estudiante) => estudiante.estado == "NO REGISTRADO");

    if (hayNoRegistrados) {
      mensaje(
          '¡No puede crear asistencia con estudiantes no registrados!', "n");
      return;
    }

    String fecha = DateTime.now().toLocal().toString();
    Attendance attendance = Attendance(
      fecha: fecha,
      id: "IDfirestore",
      estudiantes: obtenerEstudiantes(listEstudiantes),
      descripcion: commentary,
      profesor: professor.id,
      subproyecto: subproyecto.id,
      imageUrl: imageUrl,
    );

    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Asistencia"),
          content: Text(
              "Se registrará la asistencia para ${listEstudiantes.length} estudiantes.\n\n¿Desea continuar?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text("Confirmar")),
          ],
        );
      },
    );

    if (confirm == true) {
      await crearAsistencia(attendance);
      if (mounted) Navigator.pop(context, attendance);
    }
  }

  obtenerEstudiantes(listEstudiantes) {
    List listCiEstudiantes = [];
    listEstudiantes.forEach((est) {
      listCiEstudiantes.add(est.cedula);
    });
    return listCiEstudiantes;
  }

  mensaje(String msg, color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color == "y" ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> agregarEstudiante(controller, cedula) async {
    setState(() {
      listEstudiantes.add(StudentNoVerificado.fromCedula(cedula));
    });
    // Optimistic update, then verify
    int index = listEstudiantes.length - 1;
    listEstudiantes[index] = await verificarEstudiante(cedula);
    if (mounted) setState(() {});

    if (listEstudiantes[index].estado == "NO REGISTRADO") {
      mensaje('Estudiante no encontrado', "n");
    } else {
      mensaje('Estudiante verificado', "y");
    }
  }

  Future<Student> verificarEstudiante(cedula) async {
    Student respuesta = StudentNoVerificado.fromCedula(cedula);
    try {
      Student estudianteVerificado = await dataFromUnellez(cedula);

      if (estudianteVerificado.estado == "SIN VERIFICAR") {
        // Keep default
      } else if (estudianteVerificado.cedula.isEmpty) {
        respuesta = StudentNoRegistrado.fromCedula(cedula);
      } else {
        respuesta = estudianteVerificado;
        StoreService.crearEstudiante(estudianteVerificado);
      }
    } catch (e) {
      print("Error verifying: $e");
    }
    return respuesta;
  }

  Future<void> crearAsistencia(Attendance asistencia) async {
    final url = '${ConfigService().apiUrl}/agregarasistencia';
    String body = jsonEncode(asistencia.toJson());

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Asistencia creada: ${response.body}');
      } else {
        print('Error: ${response.statusCode}');
        if (mounted) mensaje('Error al enviar asistencia', "n");
      }
    } catch (e) {
      print("Error creating attendance: $e");
      if (mounted) mensaje('Error de conexión', "n");
    }
  }
}
