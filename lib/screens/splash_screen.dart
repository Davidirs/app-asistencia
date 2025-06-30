import 'package:asistencia/models/professor.dart';
import 'package:asistencia/screens/list_proyects_screens.dart';
import 'package:asistencia/screens/waiting.dart';
import 'package:asistencia/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _whereNavigate();
  }

  _whereNavigate() async {
    Professor user = await AuthService().usuarioActual();
    //await Future.delayed(const Duration(seconds: 2));
    if (user.ci == "") {
      // Si no hay usuario autenticado, redirigir a la pantalla de login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => const LoginScreen(),
        ),
      );
    } else if (user.aprobado != "aprobado") {
      // Si el usuario no está aprobado, redirigir a la pantalla de espera
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => const WaitingScreen(),
        ),
      );
    } else {
      // Si el usuario está autenticado y aprobado, redirigir a la pantalla principal

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          fullscreenDialog: true, builder: (context) => const ListProyectsScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              'Control de asistencia',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
