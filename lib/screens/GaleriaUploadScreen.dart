import 'dart:io';
import 'package:asistencia/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GaleriaUploadScreen extends StatefulWidget {
  final String
      currentImage; // puedes pasar un nombre personalizado como "${userId}.jpg"

  const GaleriaUploadScreen({super.key, required this.currentImage});

  @override
  State<GaleriaUploadScreen> createState() => _GaleriaUploadScreenState();
}

class _GaleriaUploadScreenState extends State<GaleriaUploadScreen> {
  XFile? _imageFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _uploadToSupabase() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
    });

    final file = File(_imageFile!.path);
    final fileName =
        'perfil/${professor.id}/${DateTime.now().millisecondsSinceEpoch}.jpg'; // Ruta en Supabase

    try {
      // Subir imagen
      await Supabase.instance.client.storage
          .from('uploads')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      // Obtener URL pública
      final publicUrl = Supabase.instance.client.storage
          .from('uploads')
          .getPublicUrl(fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Imagen subida exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, publicUrl); // ← retornamos la URL
    } catch (e) {
      print("❌ Error al subir imagen: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Error al subir imagen'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subir imagen desde galería"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _imageFile != null
                ? Image.file(
                    File(_imageFile!.path),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : widget.currentImage.isNotEmpty
                    ? Image.network(
                        widget.currentImage,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : const Placeholder(
                        fallbackHeight: 200,
                        fallbackWidth: double.infinity,
                      ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickFromGallery,
              icon: const Icon(Icons.photo),
              label: const Text("Seleccionar desde galería"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed:
                  _isUploading || _imageFile == null ? null : _uploadToSupabase,
              icon: _isUploading
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.cloud_upload),
              label: Text(_isUploading ? "Subiendo..." : "Subir imagen"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
