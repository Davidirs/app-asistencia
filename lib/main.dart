import 'package:asistencia/screens/splash_screen.dart';
import 'package:asistencia/services/config_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:asistencia/services/store_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await ConfigService().loadConfig(); // Load cached config

  try {
    final supabaseConfig = await StoreService.getSupabaseConfig();
    await supa.Supabase.initialize(
      url: supabaseConfig['url'],
      anonKey: supabaseConfig['anonKey'],
    );
  } catch (e) {
    print('Error initializing Supabase: $e');
  }

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
    return ValueListenableBuilder<Color>(
      valueListenable: ConfigService().primaryColor,
      builder: (context, primaryColor, child) {
        return ValueListenableBuilder<Color>(
            valueListenable: ConfigService().secondaryColor,
            builder: (context, secondaryColor, _) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                debugShowMaterialGrid: false,
                theme: ThemeData(
                  appBarTheme: const AppBarTheme(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  colorScheme: ColorScheme.fromSeed(
                    primary: primaryColor,
                    seedColor: primaryColor,
                    tertiary: secondaryColor,
                  ),
                  useMaterial3: true,
                ),
                home: const SplashScreen(),
              );
            });
      },
    );
  }
}
