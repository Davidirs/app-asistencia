import 'package:asistencia/models/professor.dart';
import 'package:asistencia/screens/list_proyects_screens.dart';
import 'package:asistencia/screens/login_screen.dart';
import 'package:asistencia/screens/waiting.dart';
import 'package:asistencia/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _dontShowAgain = false;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Bienvenido",
      "text":
          "Gestiona la asistencia de tus estudiantes de manera eficiente y rápida.",
      "image":
          "assets/images/logo.png", // Using logo as placeholder if specific assets aren't available
    },
    {
      "title": "Escanea Códigos QR",
      "text":
          "Registra la asistencia escaneando los códigos QR de los carnets estudiantiles.",
      "image": "assets/images/logo.png",
    },
    {
      "title": "Sincronización en Nube",
      "text":
          "Tus datos se guardan seguros en la nube y se sincronizan en tiempo real.",
      "image": "assets/images/logo.png",
    },
    {
      "title": "Reportes Detallados",
      "text":
          "Visualiza el historial de asistencia y genera justificaciones fácilmente.",
      "image": "assets/images/logo.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) => OnboardingContent(
                  title: _onboardingData[index]["title"]!,
                  text: _onboardingData[index]["text"]!,
                  image: _onboardingData[index]["image"]!,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => buildDot(index: index),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_currentPage == _onboardingData.length - 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _dontShowAgain,
                          onChanged: (value) {
                            setState(() {
                              _dontShowAgain = value ?? false;
                            });
                          },
                        ),
                        const Text("No volver a mostrar"),
                      ],
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_currentPage == _onboardingData.length - 1) {
                          if (_dontShowAgain) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('seenOnboarding', true);
                          }

                          // Logic to duplicate SplashScreen's destination determination
                          // This prevents looping back to SplashScreen which might show Onboarding again
                          Professor user = await AuthService().usuarioActual();
                          if (user.ci == "") {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          } else if (user.aprobado != "aprobado") {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WaitingScreen(),
                              ),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ListProyectsScreen(),
                              ),
                            );
                          }
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _currentPage == _onboardingData.length - 1
                            ? "Comenzar"
                            : "Siguiente",
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: _currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Theme.of(context).colorScheme.primary
            : const Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String title, text, image;
  const OnboardingContent({
    Key? key,
    required this.title,
    required this.text,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /* const Spacer(),
        Text(
          "ASISTENCIA UNELLEZ",
          style: TextStyle(
            fontSize: 32,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ), */
        const Spacer(),
        Image.asset(
          image,
          height: 200,
          width: 200,
        ),
        const Spacer(),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
