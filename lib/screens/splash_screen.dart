import 'package:asistencia/services/config_service.dart';
import 'package:http/http.dart' as http;
import 'package:asistencia/models/professor.dart';
import 'package:asistencia/screens/list_proyects_screens.dart';
import 'package:asistencia/screens/waiting.dart';
import 'package:asistencia/screens/onboarding_screen.dart';
import 'package:asistencia/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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
    // Fetch latest config (API URL, Colors)
    ConfigService().fetchRemoteConfig();
    _wakeUpServer();
    _checkVersion();
  }

  // Fire and forget request to wake up the server (Render spins down free instances)
  Future<void> _wakeUpServer() async {
    try {
      print("Waking up server...");
      // Not awaiting the result to block UI, just sending the ping
      http.get(Uri.parse('${ConfigService().apiUrl}/status'));
    } catch (e) {
      print("Error waking up server: $e");
    }
  }

  Future<void> _checkVersion() async {
    try {
      // 1. Get current app version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      // You might want to strip build number if it's included, e.g. "1.0.0+1" -> "1.0.0"
      // But packageInfo.version usually returns just the version string "1.0.0"

      print("Current App Version: $currentVersion");

      // 2. Get remote version from Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('ajustes')
          .doc('app')
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        String remoteVersion = data['version'] ?? "0.0.0";
        String updateUrl = data['url'] ?? "";

        print("Remote Version: $remoteVersion");

        // 3. Compare versions
        if (_isVersionLower(currentVersion, remoteVersion)) {
          if (mounted) {
            _showUpdateDialog(updateUrl);
          }
        } else {
          _checkOnboarding();
        }
      } else {
        // Fallback if config doesn't exist
        _checkOnboarding();
      }
    } catch (e) {
      print("Error checking version: $e");
      // Continue flow even if check fails
      _checkOnboarding();
    }
  }

  bool _isVersionLower(String current, String remote) {
    try {
      List<int> currentParts = current.split('.').map(int.parse).toList();
      List<int> remoteParts = remote.split('.').map(int.parse).toList();

      for (int i = 0; i < 3; i++) {
        int c = i < currentParts.length ? currentParts[i] : 0;
        int r = i < remoteParts.length ? remoteParts[i] : 0;

        if (c < r) return true;
        if (c > r) return false;
      }
      return false; // Equal
    } catch (e) {
      return false; // Parsing error, safer to assume not lower
    }
  }

  void _showUpdateDialog(String url) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must interact with buttons
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Nueva versión disponible"),
          content: const Text(
              "Hay una nueva versión de la aplicación disponible. ¿Deseas actualizarla ahora?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Omitir"),
              onPressed: () {
                Navigator.of(context).pop();
                _checkOnboarding();
              },
            ),
            ElevatedButton(
              child: const Text("Actualizar"),
              onPressed: () async {
                final Uri uri = Uri.parse(url);
                try {
                  // Intentamos abrir en navegador externo primero
                  if (!await launchUrl(uri,
                      mode: LaunchMode.externalApplication)) {
                    // Si falla, intentamos con el modo por defecto (podría elegir una app compatible)
                    print("External launch failed, trying default mode...");
                    if (!await launchUrl(uri)) {
                      print('Could not launch $url');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('No se pudo abrir el enlace')),
                      );
                    }
                  }
                } catch (e) {
                  print('Error launching URL: $e');
                  // Último intento sin modo específico
                  launchUrl(uri)
                      .catchError((e) => print("Final attempt failed $e"));
                }
              },
            ),
          ],
        );
      },
    );
  }

  _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (!seenOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else {
      _whereNavigate();
    }
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
          fullscreenDialog: true,
          builder: (context) => const ListProyectsScreen(),
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
