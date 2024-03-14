import 'package:flutter/material.dart';
import 'package:lending_app/screens/settings_screen.dart';
import 'package:lending_app/services/api_service.dart';
import 'scanning_screen.dart';

class DataListScreen extends StatefulWidget {
  const DataListScreen({Key? key}) : super(key: key);

  @override
  State<DataListScreen> createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> {
  List<dynamic> dataList = [];

  @override
  void initState() {
    super.initState();
    _loadBorrowedItems();
  }

  Future<void> _loadBorrowedItems() async {
    print("Fetching items borrowed by the user...");
    List<dynamic> items = await ApiService.fetchItemsBorrowedByUser();
    print("Items fetched: ${items.length}");
    setState(() {
      dataList = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ausgeliehene Geräte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const SettingsScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBorrowedItems,
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: ListView.builder(
            itemCount: dataList.length,
            itemBuilder: (context, index) {
              final item = dataList[index];
              print("Displaying item: ${item['id']}");
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(item['product_type']['name'] ?? 'N/A'),
                  subtitle: Text('ID: ${item['id'].toString()}'),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ScanningScreen(onDataScanned: (_) {}))),
        child: const Icon(Icons.add),
        tooltip: "Add New Scan",
      ),
    );
  }
}
