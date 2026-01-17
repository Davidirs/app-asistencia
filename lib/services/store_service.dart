import 'package:asistencia/models/student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoreService {
  static Future crearEstudiante(Student estudiante) async {
    final db = FirebaseFirestore.instance;
    final cedula = estudiante.cedula;

    // Verificar si el estudiante ya existe
    final doc = await db.collection("estudiantes").doc(cedula).get();
    if (doc.exists) {
      print("El estudiante ya existe");
      return;
    }

    // Crear el estudiante si no existe
    final nuevoEstudiante = estudiante.toJson();
    nuevoEstudiante['telefono'] = '';
    nuevoEstudiante['correo'] = '';
    db
        .collection("estudiantes")
        .doc(cedula)
        .set(nuevoEstudiante)
        .then((value) => print("Estudiante Creado exitosamente"))
        .catchError((error) => print("Error writing document: $error"));
  }

  static Future<Map<String, dynamic>> getSupabaseConfig() async {
    final db = FirebaseFirestore.instance;
    final doc = await db.collection("ajustes").doc("supabase").get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    } else {
      throw Exception(
          "No se encontró la configuración de Supabase en Firestore");
    }
  }
}
