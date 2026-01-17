import 'package:asistencia/app_theme.dart';
import 'package:asistencia/models/professor.dart';
import 'package:asistencia/screens/GaleriaUploadScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
        .set(datosActualizados, SetOptions(merge: true))
        .then((value) => print("Document successfully written!"))
        .catchError((error) => print("Error writing document: $error"));

    print("Datos actualizados perfil: $datosActualizados");
    Navigator.pop(context, datosActualizados);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil actualizado con éxito'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Editar Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.tertiary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildForm(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 100,
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
        ),
        Positioned(
          bottom: -50,
          child: GestureDetector(
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
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: (_imagen != null && _imagen!.isNotEmpty)
                        ? NetworkImage(_imagen!)
                        : null,
                    child: (_imagen == null || _imagen!.isEmpty)
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: widget.profesor.aprobado == 'aprobado'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.profesor.aprobado == 'aprobado'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.profesor.aprobado == 'aprobado'
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: widget.profesor.aprobado == 'aprobado'
                          ? Colors.green
                          : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.profesor.aprobado == 'aprobado'
                          ? 'Cuenta Aprobada'
                          : 'Pendiente de Aprobación',
                      style: TextStyle(
                        color: widget.profesor.aprobado == 'aprobado'
                            ? Colors.green[700]
                            : Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.profesor.correo,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          _buildTextField(
            controller: _nombreController,
            label: 'Nombre Completo',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _ciController,
            label: 'Cédula de Identidad',
            icon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _telefonoController,
            label: 'Teléfono',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 40),
          SizedBox(
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
                shadowColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.4),
              ),
              child: const Text(
                'Guardar Cambios',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: AppTheme.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
