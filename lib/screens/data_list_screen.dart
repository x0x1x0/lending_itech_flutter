import 'package:flutter/material.dart';
import '../models/scanned_data_model.dart';

class DataListScreen extends StatelessWidget {
  final List<ScannedDataModel> dataList;

  const DataListScreen({super.key, required this.dataList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stored Data'),
      ),
      body: ListView.builder(
        itemCount: dataList.length,
        itemBuilder: (context, index) {
          final item = dataList[index];
          // Using a Card to display each item's name and ID
          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(item.itemName),
              subtitle: Text('ID: ${item.itemId}'),
            ),
          );
        },
      ),
    );
  }
}
