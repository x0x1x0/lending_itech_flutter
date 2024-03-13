// data_list_screen.dart
import 'package:flutter/material.dart';
import 'package:lending_app/screens/settings_screen.dart';
import '../models/scanned_data_model.dart';
import 'scanning_screen.dart'; // Adjust the import path as necessary

class DataListScreen extends StatefulWidget {
  const DataListScreen({super.key});

  @override
  State<DataListScreen> createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> {
  List<ScannedDataModel> dataList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stored Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: dataList.length,
        itemBuilder: (context, index) {
          final item = dataList[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title:
                  Text(item.deviceName), // Use deviceName instead of itemName
              subtitle: Text('ID: ${item.id}'), // Use id (int) directly
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ScanningScreen(
              onDataScanned: (ScannedDataModel scannedData) {
                setState(() {
                  dataList.add(scannedData);
                });
              },
            ),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
