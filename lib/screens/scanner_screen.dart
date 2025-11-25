// ignore_for_file: must_be_immutable, no_logic_in_create_state

import 'dart:developer';
import 'dart:io';
import 'package:asistencia/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
/* 
import 'package:registro_qr/db/db.dart';
import 'package:registro_qr/db/qr.dart';
import 'package:registro_qr/db/user.dart';
import 'package:registro_qr/pages/qr_used.dart'; */

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  Barcode? result;
  String cedula = "";
  String mensaje = 'Escanea un código';
  QRViewController? controller;
  bool isReady = false;
  bool isPause = false;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  DateTime now = DateTime.now();

  bool isCodeUsed = false;
  bool isDeleting = false;
  /*final List<int> _qrUsed = [];
  //DATABASE
  List<Qr> qrs = [];
  List<User> usuarios = [];
  String lastCode = "";

  cargaQrs() async {
    List<Qr> auxQr = await DB.qrs();
    setState(() {
      qrs = auxQr;
    });
  }

  cargaUsuarios() async {
    List<User> auxUser = await DB.usuarios();
    setState(() {
      usuarios = auxUser;
    });
  } */

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isReady = true;
        controller!.resumeCamera();
      });
      /*  cargaQrs();
      cargaUsuarios(); */
    });
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  pauseResume() {
    return !isPause
        ? IconButton(
            onPressed: () async {
              await controller?.pauseCamera();
              isPause = true;
              setState(() {});
            },
            icon: const Icon(color: Colors.white, Icons.pause),
          )
        : IconButton(
            onPressed: () async {
              await controller?.resumeCamera();
              isPause = false;
              setState(() {});
            },
            icon: const Icon(color: AppTheme.primary, Icons.play_arrow),
          );
  }

  @override
  Widget build(BuildContext context) {
    /* DateTime datetime =
        DateTime(now.year, now.month, now.day, now.hour, now.second);
     String date = datetime.toString().replaceAll(":00.000", "");
     _qrUsed = qrUsed();
    goToQrUsed(); */

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Escanear QR", style: AppTheme.headline),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          _buildQrView(context),
          !isReady ? const CircularProgressIndicator() : Container(),
          Column(
            children: <Widget>[
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(horizontal: 80),
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10)),
                child: result != null
                    ? Text(
                        'Cédula del estudiante:\n$cedula',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.primary),
                        maxLines: 5,
                      )
                    : Text(
                        mensaje,
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: IconButton(
                      onPressed: () async {
                        await controller?.toggleFlash();
                        setState(() {});
                      },
                      icon: const Icon(color: Colors.white, Icons.flash_on),
                    ),
                  ),
                  /* Container(
                    padding: const EdgeInsets.all(10),
                    child: IconButton(
                      onPressed: () async {
                        await controller?.flipCamera();
                        isPause = false;
                        setState(() {});
                      },
                      icon: const Icon(
                          color: Colors.white, Icons.flip_camera_ios_outlined),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: pauseResume(),
                  ), */
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            result = null;
                          });
                        },
                        icon: const Icon(
                          color: Colors.white,
                          Icons.refresh,
                        )),
                  )
                ],
              ),
            ],
          ),
          isPause
              ? const Icon(Icons.pause, size: 100, color: AppTheme.primary)
              : Container(),
        ],
      ),
      floatingActionButton: result != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pop(context, cedula);
              },
              child: const Icon(Icons.check),
            )
          : Container(),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: AppTheme.primary,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      print(scanData.code);
      // Utilizamos una expresión regular para buscar los números después de "cedula="
      RegExp regex = RegExp(r'cedula=(\d+)');
      Match? match = regex.firstMatch(scanData.code.toString());

      // Verificamos si se encontró una coincidencia y extraemos los números
      if (match != null) {
        String numerosDespuesDeCedula = match.group(1)!;
        print("Números después de cedula=: $numerosDespuesDeCedula");
        setState(() {
          cedula = numerosDespuesDeCedula;
          result = scanData;
        });
      } else {
      
        // Utilizamos una expresión regular para buscar los números después de "cedula="
        RegExp regex = RegExp(r'cod=(\d+)');
        Match? match = regex.firstMatch(scanData.code.toString());
        if (match != null) {
          String numerosDespues = match.group(1)!;
          print("Qr de profesor=: $numerosDespues");
          setState(() {
            mensaje = "Este QR es de profesor";
          });
        } else {
          print("No se encontraron números después de cedula=");
          setState(() {
            mensaje = "No es QR de estudiante";
          });
        }
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
