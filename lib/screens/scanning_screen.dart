// scanning_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lending_app/screens/settings_screen.dart';
import 'package:lending_app/services/api_service.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  void _onQRScanned(Barcode scanData) {
    if (showScanResult) return;

    controller?.pauseCamera();
    print("Scanned Raw Data: ${scanData.code}");

    try {
      final jsonData = jsonDecode(scanData.code);
      final scannedData = ScannedDataModel.fromJson(jsonData);

      _showConfirmationDialog(scannedData);
    } catch (e) {
      _showErrorDialog('Invalid QR code. Please scan a valid QR code.');
    }
  }

  void _showConfirmationDialog(ScannedDataModel scannedData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Scan Successful!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Item Name: ${scannedData.deviceName}'),
                Text('Item ID: ${scannedData.id}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Store this data'),
              onPressed: () async {
                final success =
                    await ApiService.updateItemBorrower(scannedData.id);

                Navigator.of(context).pop(); // Close the dialog
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Data stored successfully!")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to store data.")));
                }

                setState(() => showScanResult = false);
                controller?.resumeCamera();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                setState(() => showScanResult = false);
                controller?.resumeCamera();
              },
            ),
          ],
        );
      },
    );
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
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            ),
          ),
        ],
      ),
      body: CameraView(
        onCodeScanned: _onQRScanned,
        onControllerCreated: (QRViewController qrViewController) {
          controller = qrViewController;
        },
      ),
    );
  }
}
