import 'package:asistencia/app_theme.dart';
import 'package:asistencia/models/subproyect.dart';
import 'package:flutter/material.dart';

class CreateSubProyectScreen extends StatefulWidget {
  const CreateSubProyectScreen({super.key});

  @override
  State<CreateSubProyectScreen> createState() => _CreateSubProyectScreenState();
}

class _CreateSubProyectScreenState extends State<CreateSubProyectScreen> {
  TextEditingController controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>(); // Clave para el formulario
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Crear SubProyecto", style: AppTheme.headline),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey, // Asigna la clave al formulario

            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              /* const Text("Docente", style: AppTheme.title),
              const Text("Nombre del docente", style: AppTheme.body2),
              const Text("Datos del subproyecto", style: AppTheme.title), */
              TextFormField(
                controller: controller,
                focusNode: _focusNode,
                /* onFieldSubmitted: (value) {
                  if (_formKey.currentState!.validate()) {
                    agregarSubProyecto(controller.text);
                  }
                  _focusNode.unfocus();
                }, */
                keyboardType: TextInputType.text,
                //initialValue: "24114415",
                style: AppTheme.body1,
                decoration: const InputDecoration(
                    //hintText: "Ingrese nombre del subproyecto",
                    label:
                        Text("Nombre del subproyecto", style: AppTheme.body2)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese nombre del subproyecto';
                  }
                  if (value.length < 6) {
                    return 'Nombre debe ser mayor a 6 carácteres';
                  }
                  return null; // La validación pasa
                },
              ),
            ]),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              SubProyect subproyect = SubProyect(
                nombre: controller.text,
                docente: "Nombre del docente",
                listAttendance: [],
              );
              Navigator.pop(context, subproyect);
            }
          },
          tooltip: 'Agregar SubProyecto',
          child: const Icon(Icons.done),
        ));
  }
}
