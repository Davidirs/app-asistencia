import 'package:asistencia/app_theme.dart';
import 'package:asistencia/screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await supa.Supabase.initialize(
    url: 'https://klneweqkntbyblzbcmtk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtsbmV3ZXFrbnRieWJsemJjbXRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEyMzg0NjIsImV4cCI6MjA2NjgxNDQ2Mn0.cEWX6Hd-bphLUp4DIGQPTZth1xYEhE-KwY5BmrvyfoE',
  );
  FirebaseAuth.instance.userChanges().listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in! ${user.email}');
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        colorScheme: ColorScheme.fromSeed(
          primary: AppTheme.primary,
          seedColor: AppTheme.primary,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      //MyHomePage(title: 'Registro de asistencia'),
    );
  }
}
