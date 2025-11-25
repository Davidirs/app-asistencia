import 'package:asistencia/models/professor.dart';
import 'package:asistencia/screens/upload_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CrearJustificativoScreen extends StatefulWidget {
  final Professor profesor;
  const CrearJustificativoScreen({
    Key? key,
    required this.profesor,
  }) : super(key: key);

  @override
  _CrearJustificativoScreenState createState() =>
      _CrearJustificativoScreenState();
}

class _CrearJustificativoScreenState extends State<CrearJustificativoScreen> {
  TextEditingController _descripcionController = TextEditingController();
  String? _imagen;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _descripcionController.dispose();
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
    if (_descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Descripción es requerida')),
      );
      return;
    }

    try {
      final db = FirebaseFirestore.instance;

      // Crear una referencia con ID automático
      final docRef = db.collection("justificativos").doc();

      final justificativo = {
        'id': docRef.id,
        'descripcion': _descripcionController.text,
        'profesor': widget.profesor.id,
        'fecha': DateTime.now().toLocal().toString(),
        'imageUrl': _imagen,
      };

      // Guardar los datos en Firestore con el ID generado
      await docRef.set(justificativo);

      print("Justificativo creado: $justificativo");

      // Regresar a la pantalla anterior con los datos
      Navigator.pop(context, justificativo);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado con éxito')),
      );
    } catch (error) {
      print("Error al guardar el justificativo: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Justificativo'),
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
                    builder: (_) => const CameraScreen('justificativos'),
                  ),
                );

                if (imageUrl != null) {
                  print('🖼️ Imagen subida: $imageUrl');
                  setState(() {
                    _imagen = imageUrl;
                  });
                }
              },
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  image: (_imagen != null && _imagen!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(_imagen!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (_imagen == null || _imagen!.isEmpty)
                    ? const Center(child: Icon(Icons.camera_alt, size: 40))
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            TextField(
              maxLines: 3,
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.text_fields),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guardarCambios,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Crear Justificativo'),
            ),
          ],
        ),
      ),
    );
  }
}
