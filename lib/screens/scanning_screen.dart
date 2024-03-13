import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lending_app/screens/settings_screen.dart';
import 'package:lending_app/services/api_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../models/scanned_data_model.dart';
import '../widgets/camera_view.dart';

class ScanningScreen extends StatefulWidget {
  final Function(ScannedDataModel) onDataScanned;

  const ScanningScreen({super.key, required this.onDataScanned});

  @override
  _ScanningScreenState createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen>
    with WidgetsBindingObserver {
  QRViewController? controller;
  bool showScanResult = false;
  bool _hasCameraPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer
    _checkCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkCameraPermission(); // Re-check permissions when app resumes
    }
  }

  Future<void> _checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }

    // Re-check after the request
    status = await Permission.camera.status;
    setState(() {
      _hasCameraPermission = status.isGranted;
    });
  }

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

  void _debugScan() {
    const jsonString = '{"id":3,"deviceName":"ElectroTech M1"}';
    final jsonData = jsonDecode(jsonString);
    final scannedData = ScannedDataModel.fromJson(jsonData);

    _showConfirmationDialog(scannedData);
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
                Text('Device Name: ${scannedData.deviceName}'),
                Text('Device ID: ${scannedData.id}'),
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

                print('Update item borrower request was successful: $success');

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(success
                        ? "Data stored successfully!"
                        : "Failed to store data.")));

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
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: _hasCameraPermission
          ? CameraView(
              onCodeScanned: _onQRScanned,
              onControllerCreated: (QRViewController qrViewController) {
                controller = qrViewController;
              },
            )
          : const Center(
              child: Text(
                'Camera permission is not granted.\nUse the debug button below to simulate a scan.',
                textAlign: TextAlign.center,
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _debugScan,
        tooltip: "Debug Scan",
        child: const Icon(Icons.code),
      ),
    );
  }
}
