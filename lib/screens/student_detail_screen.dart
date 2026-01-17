import 'package:asistencia/app_theme.dart';
import 'package:asistencia/models/student.dart';
import 'package:flutter/material.dart';

class StudentDetailScreen extends StatelessWidget {
  final Student student;
  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil del Estudiante",
            style: TextStyle(color: Colors.white)),
        backgroundColor:
            Colors.transparent, // Transparent for gradient effect if we had one
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
            _buildInfoCards(context),
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
          height: 120,
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
          bottom: -60,
          child: Container(
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
              radius: 60,
              backgroundColor: Colors.grey[200],
              backgroundImage: (student.imagen.isNotEmpty &&
                      student.imagen.startsWith('http'))
                  ? NetworkImage(student.imagen)
                  : const AssetImage("assets/images/logo-unellez.png")
                      as ImageProvider,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 70, left: 16, right: 16),
      child: Column(
        children: [
          Text(
            student.nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(
              student.cedula,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 2,
          ),
          const SizedBox(height: 24),
          _buildDetailRow(Icons.school, "Carrera", student.carrera),
          _buildDetailRow(
              Icons.calendar_month, "Periodo Académico", student.periodo),
          _buildDetailRow(
              Icons.cake, "Fecha de Nacimiento", student.fechaNacimiento),
          _buildDetailRow(Icons.info_outline, "Estado", student.estado,
              isHighlight: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {bool isHighlight = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isHighlight
            ? Border.all(color: AppTheme.primary, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isHighlight
                  ? AppTheme.primary.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isHighlight ? AppTheme.primary : Colors.grey[700],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? "No disponible" : value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isHighlight ? AppTheme.primary : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
