import 'package:flutter/material.dart';
import '../models/scanned_data_model.dart';

class DataListScreen extends StatelessWidget {
  final List<ScannedDataModel> dataList;

  const DataListScreen({Key? key, required this.dataList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stored Data'),
      ),
      body: ListView.builder(
        itemCount: dataList.length,
        itemBuilder: (context, index) {
          final item = dataList[index];
          return ListTile(
            title: Text(item.data),
          );
        },
      ),
    );
  }
}
