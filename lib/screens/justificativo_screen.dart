import 'dart:convert';
import 'package:asistencia/app_theme.dart';
import 'package:asistencia/models/justificativo.dart';
import 'package:asistencia/models/professor.dart';
import 'package:asistencia/screens/create_justificativo.dart';
import 'package:asistencia/screens/full_image_view.dart';
import 'package:asistencia/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class JustificativoScreen extends StatefulWidget {
  final Professor profesor;
  const JustificativoScreen(this.profesor, {super.key});

  @override
  State<JustificativoScreen> createState() => _JustificativoScreenState();
}

class _JustificativoScreenState extends State<JustificativoScreen> {
  bool isLoading = false;
  
  String imageUrl = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listarJustificativos();
  }
  Future<void> listarJustificativos() async {
    isLoading = true;
    listJustificativos = [];
    setState(() {});
    const url =
        'https://api-springboot-hdye.onrender.com/listajustificativosprofesor';
    String body = jsonEncode(widget.profesor.toJson()); // reemplaza con el string que deseas enviar
    print("Cargando Justificativos del profesor: ${widget.profesor.toJson()}");
  final headers = {
    'Content-Type': 'application/json',
  };
    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    print("Respuesta del servidor: ${response.statusCode}");
    print("Cuerpo de la respuesta: ${response.body}");
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      List list = jsonDecode(response.body);
          list.map((json) => Justificativo.fromJson(json));
      print(list);
      if (list.isNotEmpty) {
        setState(() {
          listJustificativos = list
              .map((json) => Justificativo.fromJson(json))
              .toList()
              .cast<Justificativo>();
        }); 
      } else {
        print('No hay justificativos disponibles');
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
            widget.profesor.nombre,
            style: AppTheme.headline,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar',
              onPressed: () {
                listarJustificativos();
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
            if (listJustificativos .isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  textAlign: TextAlign.center,
                  "Aún no se han creado Justificativos",
                  style: TextStyle(),
                ),
              ),
            Flexible(
              child: ListView.builder(
                itemCount: listJustificativos .length,
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

                                          listJustificativos 
                                              .remove(listJustificativos [index]);
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
                                  student: listJustificativos [index],
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
                              const Icon(Icons.list_alt),
                              Text("#${index + 1}", style: AppTheme.textbutton),
                            ],
                          ),
                          title:  Text(
                            listJustificativos [index].descripcion,
                            style: AppTheme.subtitle2,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                listJustificativos [index].fecha,
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
                                icon: Image.network(
                                  listJustificativos [index].imageUrl,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                                onPressed: () {
                                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullImageView(imageUrl: listJustificativos [index].imageUrl),
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
                                          const CreateJustificativosScreen("Editar"),
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
           final justificativo = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CrearJustificativoScreen(
                    profesor: widget.profesor,
                  ),
                ),
              );

// imageUrl ahora contiene la URL de la imagen subida
              if (justificativo != null) {
                print('📸 Justificativo creado: ${justificativo}');
                print('📸 Justificativo creado: ${Justificativo.fromJson(justificativo)}');
                setState(() {
                   agregarJustificativos(Justificativo.fromJson(justificativo));
                });
                print('📸 URL de la imagen: $imageUrl');
              }
          },
          tooltip: 'Agregar Justificativo',
          child: const Icon(Icons.add),
        ));
  }

  Future<void> agregarJustificativos(justificativo) async {
    print("Agregando justificativo: ${justificativo}");
    setState(() {
      listJustificativos .add(justificativo);
      mensaje('¡Justificativo creado exitosamente!', "y");
    });
  }

  /*  Future<void> editarJustificativos(index, attendance) async {
    setState(() {
      listJustificativos [index] = attendance;
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
