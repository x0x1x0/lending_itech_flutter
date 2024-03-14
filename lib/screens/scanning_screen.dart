import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lending_app/screens/settings_screen.dart';
import 'package:lending_app/services/api_service.dart';
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
  bool isScanning = false; // Assume we start in scanning mode

  @override
  void initState() {
    super.initState();
    // Optionally initialize scanning state here
  }

  void _toggleScanning() {
    setState(() {
      isScanning = !isScanning; // Toggle scanning state
    });

    if (isScanning) {
      controller?.resumeCamera(); // Resume camera for visual feedback
    } else {
      controller
          ?.pauseCamera(); // Optionally pause camera if you want to freeze the view
    }
  }

  void _onQRScanned(Barcode scanData) {
    if (!isScanning) return; // Do not process if we're not in scanning mode

    // Assuming you still want to stop scanning upon a successful scan:
    setState(() {
      isScanning = false;
    });

    try {
      final jsonData = jsonDecode(scanData.code);
      final scannedData = ScannedDataModel.fromJson(jsonData);
      _showConfirmationDialog(scannedData);
    } catch (e) {
      _showErrorDialog('Invalid QR code. Please scan a valid QR code.');
    }

    // Don't pause the camera here if you want it to remain active
  }

  void _showConfirmationDialog(ScannedDataModel scannedData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Scan Successful!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Device Name: ${scannedData.deviceName}'),
                Text('Device ID: ${scannedData.id}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Store this data'),
              onPressed: () async {
                
                final success =
                    await ApiService.updateItemBorrower(scannedData.id);

                if (mounted) {
                  // Close the dialog first
                  Navigator.of(context).pop();

                  // Then show the snackbar with the operation result
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(success
                        ? "Data stored successfully!"
                        : "Failed to store data."),
                  ));

                  // Lastly, resume the camera if the widget is still part of the tree
                  controller?.resumeCamera();
                }
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                if (mounted) {
                  // Resume camera without enabling scanning
                  controller?.resumeCamera();
                }
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
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SettingsScreen())),
          ),
        ],
      ),
      body: CameraView(
        onCodeScanned: _onQRScanned,
        onControllerCreated: (QRViewController qrViewController) {
          this.controller = qrViewController;
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.amber,
        onPressed: _toggleScanning,
        icon: Icon(Icons.camera_alt),
        label: Text('Scan Code'),
        tooltip: isScanning ? "Pause Scanning" : "Resume Scanning",
      ),
    );
  }
}
