import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../models/scanned_data_model.dart';
import '../widgets/camera_view.dart';
import 'data_list_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  QRViewController? controller;
  List<ScannedDataModel> scannedDataList = [];
  bool showScanResult = false; // New state to control visibility of the card
  String scanData = ''; // To hold scanned data

  void _onQRScanned(Barcode scanData) {
    // Pause the camera to stop scanning in the background
    controller?.pauseCamera();

    setState(() {
      this.scanData = scanData.code!;
      showScanResult = true; // Show the card with scan result
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      DataListScreen(dataList: scannedDataList),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          CameraView(
            onCodeScanned: _onQRScanned,
            onControllerCreated: (QRViewController qrViewController) {
              this.controller = qrViewController;
            },
          ),
          if (showScanResult)
            Align(
              alignment: Alignment.bottomCenter,
              child: Card(
                elevation: 4.0,
                margin: const EdgeInsets.all(12.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Scan Successful!',
                          style: TextStyle(fontSize: 18.0)),
                      Icon(Icons.check_circle_outline,
                          color: Colors.green, size: 60),
                      Text('Data: $scanData'),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            scannedDataList.add(ScannedDataModel(scanData));
                            showScanResult = false; // Hide the card
                            controller?.resumeCamera(); // Resume scanning
                          });
                        },
                        child: const Text('Store this data'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
