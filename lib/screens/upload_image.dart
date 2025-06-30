import 'dart:io';
import 'package:asistencia/services/auth_service.dart';
import 'package:asistencia/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

late List<CameraDescription> cameras;

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _isReady = false;
  bool _isUploading = false;
  XFile? _imageFile;
  late List<CameraDescription> cameras;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _getCurrentUser();
  }

  Future<void> _initCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras[_selectedCameraIndex], 
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller.initialize();
    setState(() {
      _isReady = true;
    });
  }
  Future<void> _getCurrentUser() async {
    AuthService().usuarioActual().then((value) {
      setState(() {
        professor = value;
      });
      
    });
  }

  Future<void> _switchCamera() async {
    if (cameras.length < 2) return;
    
    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras.length;
      _isReady = false;
    });

    await _controller.dispose();
    _controller = CameraController(
      cameras[_selectedCameraIndex], 
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller.initialize();
    
    setState(() {
      _isReady = true;
    });
  }

  Future<void> _takePicture() async {
    if (!_controller.value.isInitialized) return;
    
    try {
      final image = await _controller.takePicture();
      setState(() {
        _imageFile = image;
      });
    } catch (e) {
      print("Error al tomar foto: $e");
    }
  }

  Future<void> _uploadToSupabase() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
    });

    final file = File(_imageFile!.path);
    final fileName = 'asistencias/${professor.id}/img_${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      await Supabase.instance.client.storage
          .from('uploads')
          .upload(fileName, file);

      final publicUrl = Supabase.instance.client.storage
          .from('uploads')
          .getPublicUrl(fileName);

      Navigator.pop(context, publicUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Imagen subida exitosamente!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Limpiar la imagen después de subir
      setState(() {
        _imageFile = null;
      });

    } catch (e) {
      print("❌ Error al subir imagen: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir imagen'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _retakePhoto() {
    setState(() {
      _imageFile = null;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text(
                'Iniciando cámara...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vista previa de la cámara o imagen tomada
          Positioned.fill(
            child: _imageFile == null
                ? CameraPreview(_controller)
                : Image.file(
                    File(_imageFile!.path),
                    fit: BoxFit.cover,
                  ),
          ),
          
          // Botón de cambiar cámara (solo visible cuando no hay foto tomada)
          if (_imageFile == null && cameras.length > 1)
            Positioned(
              top: 50,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _switchCamera,
                  icon: Icon(
                    Icons.flip_camera_ios,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),

          // Botón de cerrar
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),

          // Controles inferiores
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: _imageFile == null ? _buildCameraControls() : _buildPhotoControls(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Espacio vacío para centrar el botón de captura
            SizedBox(width: 60),
            
            // Botón de captura (grande y centrado)
            GestureDetector(
              onTap: _takePicture,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            
            // Galería (opcional, puedes implementarlo después)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Icon(
                Icons.photo_library,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildPhotoControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Botón para retomar foto
            _buildActionButton(
              onPressed: _retakePhoto,
              icon: Icons.refresh,
              label: 'Retomar',
              color: Colors.grey,
            ),
            
            // Botón para subir foto
            _buildActionButton(
              onPressed: _isUploading ? null : _uploadToSupabase,
              icon: _isUploading ? Icons.hourglass_empty : Icons.cloud_upload,
              label: _isUploading ? 'Subiendo...' : 'Subir',
              color: Colors.blue,
              isLoading: _isUploading,
            ),
          ],
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
    bool isLoading = false,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: CircleBorder(),
              padding: EdgeInsets.zero,
            ),
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(icon, size: 28),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}