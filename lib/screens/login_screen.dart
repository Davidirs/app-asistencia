
import 'package:asistencia/screens/list_proyects_screens.dart';
import 'package:asistencia/screens/register_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await AuthService().login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // Navegar a pantalla principal después de login exitoso
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ListProyectsScreen(),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  

  bool isVisible = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 40),
                const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: _emailController,
                  label: 'Correo Electrónico',
                  hint: 'ejemplo@dominio.com',
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su correo';
                    }
                    if (!value.contains('@')) {
                      return 'Ingrese un correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    Expanded(
      child: CustomTextField(
        controller: _passwordController,
        label: 'Contraseña',
        hint: 'Ingrese su contraseña',
        icon: Icons.lock,
        obscureText: isVisible,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese su contraseña';
          }
          if (value.length < 6) {
            return 'La contraseña debe tener al menos 6 caracteres';
          }
          return null;
        },
      ),
    ),
    IconButton(
      onPressed: () {
        setState(() {
          isVisible = !isVisible;
        });
      },
      icon: Icon(isVisible
          ? Icons.visibility
          : Icons.visibility_off),
    ),
  ],
),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('INGRESAR'),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿No tienes una cuenta?,'),
                    TextButton(
                      onPressed: () {
                        // Navegar a pantalla de recuperación de contraseña
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text('Regístrate aquí',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
