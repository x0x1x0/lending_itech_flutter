import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class CameraView extends StatefulWidget {
  final Function(Barcode) onCodeScanned;
  final Function(QRViewController) onControllerCreated;

  const CameraView({
    super.key,
    required this.onCodeScanned,
    required this.onControllerCreated,
  });

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.amber,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: MediaQuery.of(context).size.width * 0.6,
      ),
    );
  }

  void _onQRViewCreated(QRViewController qrViewController) {
    setState(() {
      controller = qrViewController;
    });
    widget.onControllerCreated(qrViewController);
    // Listen to the scan stream only if a scan is initiated by the parent widget.
    qrViewController.scannedDataStream.listen((scanData) {
      widget.onCodeScanned(scanData);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
