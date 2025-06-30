import 'dart:async';

import 'package:asistencia/models/student.dart';
import 'package:http/http.dart' as http;

import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;

Future<Student> dataFromUnellez(cedula) async {
  // URL base de la API
  var apiUrl = Uri.parse(
      "https://arse.unellez.edu.ve/arse/portal/consulta_estudiantes.php?qr=v&boton=1&cedula=$cedula");
  try {
    // Realizar la solicitud HTTP GET con un timeout de 10 segundos
    var response = await http.get(apiUrl).timeout(const Duration(seconds: 10));

    // Verificar si la solicitud fue exitosa (código de estado 200)
    if (response.statusCode == 200) {
      // Procesar los datos de respuesta como HTML
      String html = response.body;
      return filtrarDataUnellez(html);
    } else {
      // La solicitud no fue exitosa
      print('La solicitud falló con estado ${response.statusCode}.');
    }
  } on TimeoutException catch (error) {
    // Ocurrió un error de timeout
    print('Error de timeout al realizar la solicitud: $error');
  } catch (error) {
    // Ocurrió un error al realizar la solicitud
    print('Error al realizar la solicitud: $error');
  }
  return Student(
      carrera: "SIN VERIFICAR",
      periodo: "SIN VERIFICAR",
      imagen: "SIN VERIFICAR",
      nombre: "ESTUDIANTE UNELLEZ",
      cedula: cedula,
      fechaNacimiento: "SIN VERIFICAR",
      estado: "SIN VERIFICAR");
}

Student filtrarDataUnellez(String html) {
  const url = "https://arse.unellez.edu.ve";
  // Ejemplo de cómo analizar un fragmento HTML
  final html_dom.Document document = html_parser.parse(html);

  // Extraer los valores que necesitas
  var dtElements = document.getElementsByTagName('dt');
  var ddElements = document.getElementsByTagName('dd');

  // Extraer el src de la imagen
  var imagenSrc =
      document.querySelector('.img-thumbnail')?.attributes['src'] ?? '';
  imagenSrc = url + imagenSrc;

  // Extraer el texto "El estudiante tiene inscripción ACTIVA."
  var estadoInscripcion = document
          .querySelector('.alert.alert-success')
          ?.text
          .trim()
          .split('×')[0] ??
      '';

  // Extraer el texto "INGENIERIA INFORMATICA :"
  var carrera = document
          .querySelector('.panel-heading b:first-child')
          ?.text
          .trim()
          .split(':')[0] ??
      '';

  // Extraer el texto "2024: I-RG"
  var periodo =
      document.querySelector('.panel-heading b:last-child')?.text.trim() ?? '';

  // Iterar sobre los elementos y extraer los valores
  String cedula = "", nombres = "", fechaNacimiento = "";
  for (var i = 0; i < dtElements.length; i++) {
    if (dtElements[i].text.trim() == 'Cedula') {
      cedula = ddElements[i].text.trim();
    } else if (dtElements[i].text.trim() == 'Apellidos y Nombres') {
      nombres = ddElements[i].text.trim();
    } else if (dtElements[i].text.trim() == 'Fecha Nacimiento') {
      fechaNacimiento = ddElements[i].text.trim();
    }
  }

  // Imprimir los valores
  print("carrera: $carrera");
  print("periodo: $periodo");
  print("imagenSrc: $imagenSrc");
  print("Nombres: $nombres");
  print("Cedula: $cedula");
  print("Fecha de Nacimiento: $fechaNacimiento");
  print("estadoInscripcion: $estadoInscripcion");
  return Student(
      carrera: carrera,
      periodo: periodo,
      imagen: imagenSrc,
      nombre: nombres,
      cedula: cedula,
      fechaNacimiento: fechaNacimiento,
      estado: estadoInscripcion);
}
