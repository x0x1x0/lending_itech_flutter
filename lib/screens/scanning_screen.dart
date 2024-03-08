// scanning_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../models/scanned_data_model.dart';
import '../widgets/camera_view.dart';

class ScanningScreen extends StatefulWidget {
  final Function(ScannedDataModel) onDataScanned;

  const ScanningScreen({Key? key, required this.onDataScanned})
      : super(key: key);

  @override
  _ScanningScreenState createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  QRViewController? controller;
  bool showScanResult = false;

  // Inside ScanningScreen
  void _onQRScanned(Barcode scanData) {
    if (showScanResult) {
      // If a confirmation is already being shown, ignore further scans
      return;
    }

    // Pause scanning as soon as a QR code is detected
    controller?.pauseCamera();
    print("Scanned Raw Data: ${scanData.code}");

    try {
      final jsonData = jsonDecode(scanData.code);
      final scannedData = ScannedDataModel.fromJson(jsonData);

      // Directly show the confirmation dialog
      _showConfirmationDialog(scannedData);
    } catch (e) {
      // Show an error dialog if the scanned data is not in the expected format
      _showErrorDialog('Invalid QR code. Please scan a valid QR code.');
    }
  }

  void _showConfirmationDialog(ScannedDataModel scannedData) {
    setState(() {
      showScanResult = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Scan Successful!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Item Name: ${scannedData.itemName}'),
                Text('Item ID: ${scannedData.itemId}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Store this data'),
              onPressed: () {
                widget.onDataScanned(scannedData); // Notify parent widget
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Resume scanning immediately after the dialog is dismissed
      if (mounted) {
        setState(() => showScanResult = false);
        controller?.resumeCamera();
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() => showScanResult = false);
        controller?.resumeCamera();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: CameraView(
        onCodeScanned: _onQRScanned,
        onControllerCreated: (QRViewController qrViewController) {
          controller = qrViewController;
        },
      ),
    );
  }
}
