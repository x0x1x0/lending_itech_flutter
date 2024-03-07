import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../models/scanned_data_model.dart';
import '../widgets/camera_view.dart';
import 'data_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  QRViewController? controller;
  List<ScannedDataModel> scannedDataList = [];
  bool showScanResult = false; // State to control visibility of the card

  void _onQRScanned(Barcode scanData) {
    if (showScanResult) {
      // If a confirmation is already being shown, ignore further scans
      return;
    }

    controller?.pauseCamera();
    print("Scanned Raw Data: ${scanData.code}");

    final jsonData = jsonDecode(scanData.code); // Decode the JSON string
    final scannedData = ScannedDataModel.fromJson(jsonData); // Convert to model

    setState(() {
      scannedDataList.add(scannedData);
      showScanResult = true;
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
              controller = qrViewController;
            },
          ),
          if (showScanResult && scannedDataList.isNotEmpty)
            Align(
              alignment: Alignment.center,
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
                      const Icon(Icons.check_circle_outline,
                          color: Color.fromARGB(255, 104, 187, 107), size: 60),
                      // Display the scanned item's name and ID
                      Text('Item Name: ${scannedDataList.last.itemName}'),
                      Text('Item ID: ${scannedDataList.last.itemId}'),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showScanResult =
                                false; // Hide the confirmation card
                          });
                          controller
                              ?.resumeCamera(); // Resume scanning immediately
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
