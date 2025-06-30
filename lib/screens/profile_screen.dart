import 'dart:io';

import 'package:asistencia/models/professor.dart';
import 'package:asistencia/screens/GaleriaUploadScreen.dart';
import 'package:asistencia/utils/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class EditarPerfilScreen extends StatefulWidget {
  final Professor profesor;
  const EditarPerfilScreen({
    Key? key,
    required this.profesor,
  }) : super(key: key);

  @override
  _EditarPerfilScreenState createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  late TextEditingController _ciController;
  late TextEditingController _telefonoController;
  late TextEditingController _nombreController;
  String? _imagen;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _imagen = widget.profesor.imagen;
    _ciController = TextEditingController(text: widget.profesor.ci);
    _telefonoController = TextEditingController(text: widget.profesor.telefono);
    _nombreController = TextEditingController(text: widget.profesor.nombre);
  }

  @override
  void dispose() {
    _ciController.dispose();
    _telefonoController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  /* Future<void> _pickFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  } */

  Future<void> _guardarCambios() async {
    // Validar los campos antes de guardar
    if (_nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es requerido')),
      );
      return;
    }

    // Aquí iría la lógica para guardar los cambios en tu backend
    final datosActualizados = {
      'imagen': _imagen,
      'ci': _ciController.text,
      'telefono': _telefonoController.text,
      'nombre': _nombreController.text,
      'correo': widget.profesor.correo,
      'aprobado': widget.profesor.aprobado,
      'id': widget.profesor.id,
    };

    final db = FirebaseFirestore.instance;

    await db
        .collection("profesores")
        .doc(widget.profesor.id)
        .set(datosActualizados)
        .then((value) => print("Document successfully written!"))
        .catchError((error) => print("Error writing document: $error"));

    // Simulamos el guardado exitoso
    
    print("Datos actualizados perfil: $datosActualizados");
    // Opcional: regresar a la pantalla anterior con los datos actualizados
    Navigator.pop(context, datosActualizados);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado con éxito')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final imageUrl = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        GaleriaUploadScreen(currentImage: _imagen ?? ''),
                  ),
                );

                if (imageUrl != null) {
                  print('🖼️ Imagen subida: $imageUrl');
                  setState(() {
                    _imagen = imageUrl;
                  });
                }
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: (_imagen == null || _imagen!.isEmpty)
                    ? null
                    : Image.network(_imagen!).image,
                child: _imagen == null || _imagen!.isEmpty
                    ? const Icon(Icons.camera_alt, size: 40)
                    :null
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.profesor.correo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: widget.profesor.aprobado == 'aprobado'
                  ? Colors.green
                  : Colors.red,
              child: Center(
                child: Text(
                  widget.profesor.aprobado == 'aprobado'
                      ? 'Aprobado'
                      : 'No Aprobado',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ciController,
              decoration: const InputDecoration(
                labelText: 'Cédula de Identidad',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guardarCambios,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
