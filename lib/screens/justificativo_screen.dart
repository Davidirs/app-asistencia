import 'dart:convert';

import 'package:asistencia/models/justificativo.dart';
import 'package:asistencia/models/professor.dart';
import 'package:asistencia/screens/create_justificativo.dart';
import 'package:asistencia/screens/full_image_view.dart';
import 'package:asistencia/services/config_service.dart';
import 'package:asistencia/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JustificativoScreen extends StatefulWidget {
  final Professor profesor;
  const JustificativoScreen(this.profesor, {super.key});

  @override
  State<JustificativoScreen> createState() => _JustificativoScreenState();
}

class _JustificativoScreenState extends State<JustificativoScreen> {
  bool isLoading = false;
  String imageUrl = "";

  @override
  void initState() {
    super.initState();
    listarJustificativos();
  }

  Future<void> listarJustificativos() async {
    isLoading = true;
    listJustificativos = [];
    if (mounted) setState(() {});

    final url = '${ConfigService().apiUrl}/listajustificativosprofesor';
    String body = jsonEncode(widget.profesor.toJson());
    print("Cargando Justificativos del profesor: ${widget.profesor.toJson()}");

    final headers = {'Content-Type': 'application/json'};

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      print("Respuesta del servidor: ${response.statusCode}");

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      if (response.statusCode == 200) {
        List list = jsonDecode(response.body);
        print(list);
        if (list.isNotEmpty) {
          if (mounted) {
            setState(() {
              listJustificativos = list
                  .map((json) => Justificativo.fromJson(json))
                  .toList()
                  .cast<Justificativo>();
            });
          }
        } else {
          print('No hay justificativos disponibles');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print("Error al conectar: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Column(
              children: [
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildJustificativoList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final justificativo = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CrearJustificativoScreen(
                profesor: widget.profesor,
              ),
            ),
          );

          if (justificativo != null) {
            print(
                '📸 Justificativo creado: ${Justificativo.fromJson(justificativo)}');
            setState(() {
              agregarJustificativos(Justificativo.fromJson(justificativo));
            });
          }
        },
        tooltip: 'Agregar Justificativo',
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 140,
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  widget.profesor.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Actualizar',
                onPressed: listarJustificativos,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJustificativoList() {
    if (listJustificativos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Aún no se han creado Justificativos",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listJustificativos.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildJustificativoCard(context, index);
      },
    );
  }

  Widget _buildJustificativoCard(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("ELIMINAR",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Icon(Icons.delete, color: Colors.white),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Confirmación"),
                  content: const Text(
                      "¿Estás seguro que quieres eliminar? \n\nEsta acción no la puedes deshacer."),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Cancelar"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        listJustificativos.remove(listJustificativos[index]);
                        setState(() {});
                        Navigator.of(context).pop(true);
                      },
                      child: const Text("Eliminar"),
                    ),
                  ],
                );
              },
            );
          },
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "#${index + 1}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              listJustificativos[index].descripcion,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 5),
                    Text(
                      listJustificativos[index].fecha,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            trailing: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullImageView(
                        imageUrl: listJustificativos[index].imageUrl),
                  ),
                );
              },
              child: Hero(
                tag: listJustificativos[index].imageUrl,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(listJustificativos[index].imageUrl),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> agregarJustificativos(justificativo) async {
    setState(() {
      listJustificativos.add(justificativo);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Justificativo creado exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
}
