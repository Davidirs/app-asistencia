import 'package:asistencia/models/professor.dart';
import 'package:asistencia/utils/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e.code);
    }
  }

  Future<User?> register(String email, String password, String name, String ci) async {
    final db = FirebaseFirestore.instance;

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Professor professor = Professor(
          correo: userCredential.user!.email!,
          imagen: userCredential.user!.photoURL ?? '',
          id: userCredential.user!.uid,
          ci: ci,
          telefono: '',
          nombre: name,
          aprobado: "pendiente");
      print('Usuario autenticado: ${professor}');

      db
          .collection("profesores")
          .doc(professor.id)
          .set(professor.toJson())
          .then((value) => print("Document successfully written!"))
          .catchError((error) => print("Error writing document: $error"));
      // .onSuccess((_) => print("Document successfully written!"))

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Error de autenticación: ${e.code}');
      throw _handleAuthError(e.code);
    }
  }

  Future<Professor> usuarioActual() async {
    Professor profesor =  professor;
    final db = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    if (user == null) {
      return profesor; // Retorna un objeto Profesor vacío si no hay usuario autenticado
    }

    try {
      DocumentSnapshot document = await db.collection("profesores").doc(user.uid).get();
      if (document.exists) {
        profesor = Professor.fromJson(document.data() as Map<String, dynamic>);
        print("Datos del profesor: ${profesor.nombre}, ${profesor.correo}");
      } else {
        print("El documento no existe");
      }
    } catch (error) {
      print("Error al obtener el documento: $error");
      throw Exception("Failed to fetch professor data.");
    }

    return profesor;
  }

  String _handleAuthError(String code) {
    print('Error de autenticación: ${code}');
    switch (code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'user-disabled':
        return 'Usuario deshabilitado';
      case 'too-many-requests':
        return 'Demasiados intentos. Intente más tarde';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      case 'email-already-in-use':
        return 'El correo electrónico ya está en uso';
      default:
        return 'Error de autenticación';
    }
  }
}
