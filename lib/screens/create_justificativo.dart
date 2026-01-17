import 'package:asistencia/models/professor.dart';
import 'package:asistencia/screens/upload_image.dart';
import 'package:asistencia/screens/full_image_view.dart';
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
  bool _isSaving = false;

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (_descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Descripción es requerida'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final db = FirebaseFirestore.instance;
      final docRef = db.collection("justificativos").doc();

      final justificativo = {
        'id': docRef.id,
        'descripcion': _descripcionController.text,
        'profesor': widget.profesor.id,
        'fecha': DateTime.now().toLocal().toString(),
        'imageUrl': _imagen,
      };

      await docRef.set(justificativo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Justificativo creado con éxito'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context, justificativo);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al guardar: $error'),
              backgroundColor: Colors.red),
        );
        setState(() {
          _isSaving = false;
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
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 20),
                    _buildForm(),
                    const SizedBox(height: 30),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
            if (_isSaving)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ));
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
              const Expanded(
                child: Text(
                  "Nuevo Justificativo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      width: double.infinity,
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
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              if (_imagen != null && _imagen!.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullImageView(imageUrl: _imagen!),
                  ),
                );
              } else {
                _takePhoto();
              }
            },
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                image: (_imagen != null && _imagen!.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(_imagen!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (_imagen == null || _imagen!.isEmpty)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined,
                            size: 50, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        Text("Toque para agregar foto",
                            style: TextStyle(color: Colors.grey[500])),
                      ],
                    )
                  : null,
            ),
          ),
          if (_imagen != null && _imagen!.isNotEmpty)
            TextButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Cambiar Foto"),
            )
          else
            TextButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Tomar Foto"),
            ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Future<void> _takePhoto() async {
    final imageUrl = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CameraScreen('justificativos'),
      ),
    );

    if (imageUrl != null) {
      setState(() {
        _imagen = imageUrl;
      });
    }
  }

  Widget _buildForm() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Detalles",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            maxLines: 5,
            controller: _descripcionController,
            decoration: InputDecoration(
              labelText: 'Descripción del justificativo',
              hintText: 'Explique la razón...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 80),
                child: Icon(Icons.description_outlined),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _guardarCambios,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: const Text("Guardar Justificativo",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
