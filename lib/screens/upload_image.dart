// ignore_for_file: no_logic_in_create_state

import 'dart:io';
import 'package:asistencia/services/auth_service.dart';
import 'package:asistencia/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:camerawesome/camerawesome_plugin.dart';

class CameraScreen extends StatefulWidget {
  final String type; // 'justificativo' or 'asistencia'
  const CameraScreen(this.type, {super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState(type);
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isUploading = false;
  String? _capturedImagePath;

  _CameraScreenState(String type);

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    AuthService().usuarioActual().then((value) {
      setState(() {
        professor = value;
      });
    });
  }

  Future<void> _uploadToSupabase() async {
    if (_capturedImagePath == null) return;

    setState(() {
      _isUploading = true;
    });

    final file = File(_capturedImagePath!);
    final fileName =
        '${widget.type}/${professor.id}/img_${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      await Supabase.instance.client.storage
          .from('uploads')
          .upload(fileName, file);

      final publicUrl = Supabase.instance.client.storage
          .from('uploads')
          .getPublicUrl(fileName);

      Navigator.pop(context, publicUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: const Text('¡Imagen subida exitosamente!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Limpiar la imagen después de subir
      setState(() {
        _capturedImagePath = null;
      });
    } catch (e) {
      print("❌ Error al subir imagen: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
      _capturedImagePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _capturedImagePath == null
          ? _buildCameraView()
          : _buildPhotoPreview(),
    );
  }

  Widget _buildCameraView() {
    return CameraAwesomeBuilder.awesome(
      onMediaCaptureEvent: (event) {
        switch ((event.status, event.isPicture, event.isVideo)) {
          case (MediaCaptureStatus.capturing, true, false):
            debugPrint('Capturing picture...');
          case (MediaCaptureStatus.success, true, false):
            event.captureRequest.when(
              single: (single) {
                debugPrint('Picture saved: ${single.file?.path}');
                setState(() {
                  _capturedImagePath = single.file?.path;
                });
              },
              multiple: (multiple) {
                multiple.fileBySensor.forEach((key, value) {
                  debugPrint('multiple image taken: $key ${value?.path}');
                });
              },
            );
          case (MediaCaptureStatus.failure, true, false):
            debugPrint('Failed to capture picture: ${event.exception}');
          case (MediaCaptureStatus.capturing, false, true):
            debugPrint('Capturing video...');
          case (MediaCaptureStatus.success, false, true):
            event.captureRequest.when(
              single: (single) {
                debugPrint('Video saved: ${single.file?.path}');
              },
              multiple: (multiple) {
                multiple.fileBySensor.forEach((key, value) {
                  debugPrint('multiple video taken: $key ${value?.path}');
                });
              },
            );
          case (MediaCaptureStatus.failure, false, true):
            debugPrint('Failed to capture video: ${event.exception}');
          default:
            debugPrint('Unknown event: $event');
        }
      },
      saveConfig: SaveConfig.photoAndVideo(
        initialCaptureMode: CaptureMode.photo,
        photoPathBuilder: (sensors) async {
          final Directory extDir = await getTemporaryDirectory();
          final testDir = await Directory(
            '${extDir.path}/camerawesome',
          ).create(recursive: true);
          if (sensors.length == 1) {
            final String filePath =
                '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
            return SingleCaptureRequest(filePath, sensors.first);
          }
          // Separate pictures taken with front and back camera
          return MultipleCaptureRequest(
            {
              for (final sensor in sensors)
                sensor:
                    '${testDir.path}/${sensor.position == SensorPosition.front ? 'front_' : "back_"}${DateTime.now().millisecondsSinceEpoch}.jpg',
            },
          );
        },
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return Stack(
      children: [
        // Vista previa de la imagen capturada
        Positioned.fill(
          child: Image.file(
            File(_capturedImagePath!),
            fit: BoxFit.cover,
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
              icon: const Icon(
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
            child: _buildPhotoControls(),
          ),
        ),
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
        const SizedBox(height: 30),
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
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
            ),
            child: isLoading
                ? const SizedBox(
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
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
