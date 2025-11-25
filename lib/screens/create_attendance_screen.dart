import 'dart:convert';

import 'package:asistencia/app_theme.dart';
import 'package:asistencia/models/attendance.dart';
import 'package:asistencia/models/student.dart';
import 'package:asistencia/screens/full_image_view.dart';
import 'package:asistencia/screens/scanner_screen.dart';
import 'package:asistencia/screens/scraping_unellez.dart';
import 'package:asistencia/screens/student_detail_screen.dart';
import 'package:asistencia/screens/upload_image.dart';
import 'package:asistencia/services/store_service.dart';
import 'package:asistencia/utils/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title + " asistencia", style: AppTheme.headline),
        centerTitle: true,
        actions: [
          imageUrl.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullImageView(imageUrl: imageUrl),
                      ),
                    );
                  },
                  child: Image.network(
                    imageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(Icons.image, size: 40),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () async {
              final url = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CameraScreen( 'asistencias'),
                ),
              );

// imageUrl ahora contiene la URL de la imagen subida
              if (url != null) {
                setState(() {
                  imageUrl = url;
                });
                print('📸 URL de la imagen: $imageUrl');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text(style: AppTheme.title, "Agregar estudiante"),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
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
            child: Form(
              key: _formKey, // Asigna la clave al formulario
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: controller,
                          focusNode: _focusNode,
                          onFieldSubmitted: (value) {
                            if (_formKey.currentState!.validate()) {
                              bool existe = listEstudiantes.any((estudiante) =>
                                  estudiante.cedula == controller.text);

                              if (existe) {
                                print("Hay estudiantes no registrados");
                                mensaje('¡Estudiante ya agregado!', "n");
                              } else {
                                agregarEstudiante(controller, controller.text);
                                controller.clear();
                              }
                            }
                            _focusNode.unfocus();
                          },
                          keyboardType: TextInputType.number,
                          //initialValue: "24114415",
                          style: AppTheme.body1,
                          decoration: const InputDecoration(
                              //hintText: "Ingrese número de cédula",
                              label: Text(
                            "Número de cedula",
                            style: AppTheme.body2,
                          )),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese número de cédula';
                            }
                            if (value.length < 6) {
                              return 'Cedúla debe ser mayor a 6 dígitos';
                            }
                            return null; // La validación pasa
                          },
                        ),
                        Text(
                          "Comentario: $commentary",
                        )
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                          onPressed: () async {
                            final cedula = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ScannerScreen(),
                              ),
                            );
                            agregarEstudiante(controller, cedula);
                          },
                          icon: const Column(
                            children: [
                              Icon(
                                Icons.qr_code,
                                color: AppTheme.primary,
                              ),
                              Text(
                                style: AppTheme.textbutton,
                                "Escanear",
                              ),
                            ],
                          )),
                      IconButton(
                          onPressed: () async {
                            commentary = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Comentario'),
                                    content: TextFormField(
                                      controller: commentController,
                                      maxLines: 3,
                                      decoration: const InputDecoration(
                                        hintText: 'Escriba su comentario aquí',
                                        border: OutlineInputBorder(),
                                      ),
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Cerrar el diálogo sin guardar el comentario
                                        },
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          commentary = commentController.text;
                                          // Hacer algo con el comentario, por ejemplo, guardarlo en una variable y cerrar el diálogo
                                          print(
                                              'Comentario ingresado: $commentary');
                                          Navigator.of(context).pop(
                                              commentary); // Cerrar el diálogo y pasar el comentario ingresado
                                        },
                                        child: const Text('Guardar'),
                                      ),
                                    ],
                                  );
                                });
                            setState(() {});
                          },
                          icon: const Column(
                            children: [
                              Icon(
                                Icons.add,
                                color: AppTheme.primary,
                              ),
                              Text(style: AppTheme.textbutton, "Comentario")
                            ],
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text(style: AppTheme.title, "Listado de estudiantes"),
          ),
          if (listEstudiantes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                textAlign: TextAlign.center,
                "Aún no se han agregado estudiantes a esta lista de asistencia",
                style: TextStyle(),
              ),
            ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListView.builder(
                itemCount: listEstudiantes.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      margin: const EdgeInsets.only(bottom: 8),
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
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("Cancelar"),
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          print("Eliminar");
                                          print(index);

                                          listEstudiantes
                                              .remove(listEstudiantes[index]);
                                          setState(() {});
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text("Eliminar")),
                                  ],
                                );
                              },
                            );
                          } else {
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
                              Text("#${index + 1}", style: AppTheme.textbutton),
                            ],
                          ),
                          title: Text(listEstudiantes[index].cedula,
                              style: AppTheme.subtitle2),
                          subtitle: Text(listEstudiantes[index].nombre,
                              style: AppTheme.caption),
                          //isThreeLine: true,
                          trailing: listEstudiantes[index].estado ==
                                  "SIN VERIFICAR"
                              ? IconButton(
                                  onPressed: () async {
                                    print("Verificar");

                                    listEstudiantes[index] =
                                        await verificarEstudiante(
                                            listEstudiantes[index].cedula);
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
                              : listEstudiantes[index].estado == "NO REGISTRADO"
                                  ? const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    )
                                  : const Icon(
                                      Icons.verified,
                                      color: Colors.green,
                                    ),
                        ),
                      ));
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: listEstudiantes.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                bool hayNoRegistrados = listEstudiantes
                    .any((estudiante) => estudiante.estado == "NO REGISTRADO");

                if (hayNoRegistrados) {
                  mensaje(
                      '¡No puede crear asistencia con estudiantes no registrados!',
                      "n");
                  return;
                }

                String fecha = DateTime.now().toLocal().toString();
                Attendance attendance = Attendance(
                  fecha: fecha,
                  //hora: "12:00 pm",
                  id: "IDfirestore",
                  estudiantes: obtenerEstudiantes(listEstudiantes),
                  descripcion: commentary,
                  profesor: professor.id,
                  subproyecto: subproyecto.id,
                  imageUrl: imageUrl,
                );
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirmación"),
                      content: const Text(
                          "¿Has cargado todos los estudiantes?, verifique antes de aceptar."),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("Cancelar"),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              crearAsistencia(attendance);

                              Navigator.of(context).pop(true);
                              Navigator.pop(context, attendance);
                            },
                            child: const Text("Aceptar")),
                      ],
                    );
                  },
                );
              },
              tooltip: 'Listo',
              child: const Icon(Icons.done),
            )
          : Container(),
    );
  }

  obtenerEstudiantes(listEstudiantes) {
    List listCiEstudiantes = [];

    listEstudiantes.forEach((est) {
      listCiEstudiantes.add(est.cedula);
    });
    // Obtiene la lista de estudiantes
    return listCiEstudiantes;
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

  Future<void> agregarEstudiante(controller, cedula) async {
    setState(() {
      listEstudiantes.add(StudentNoVerificado.fromCedula(cedula));
      mensaje('¡Estudiante $cedula agregado!', "y");
    });
    listEstudiantes[listEstudiantes.length - 1] =
        await verificarEstudiante(cedula);
    setState(() {
      print("segundo setstate");
    });
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
        StoreService.crearEstudiante(estudianteVerificado);
      }
    } catch (e) {
      mensaje('¡Error al agregar estudiante $cedula!', "n");
    }
    return respuesta;
  }

  Future<void> crearAsistencia(Attendance asistencia) async {
    const url = 'https://api-springboot-hdye.onrender.com/agregarasistencia';
    String body = jsonEncode(
        asistencia.toJson()); // reemplaza con el string que deseas enviar
    print(body);

    final headers = {
      'Content-Type': 'application/json',
    };

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      /* List list = jsonDecode(response.body);
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
      }*/
      print('Asistencia creada: ${response.body}');
    } else {
      print('Error: ${response.statusCode}');
    }
  }
}
