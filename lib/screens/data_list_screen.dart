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
    var items = await ApiService.fetchItemsBorrowedByUser();
    if (mounted) {
      setState(() {
        dataList = items;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ausgeliehene Geräte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBorrowedItems,
        child: ListView.builder(
          itemCount: dataList.length,
          itemBuilder: (context, index) {
            final item = dataList[index];
            return Dismissible(
              key: Key(item['id'].toString()),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) async {
                bool success = await ApiService.returnItem(item['id']);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Item returned successfully!'),
                  ));
                  _loadBorrowedItems(); // Reload items
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed to return item.'),
                  ));
                }
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(item['product_type']['name'] ?? 'Unknown Item'),
                  subtitle: Text('ID: ${item['id']}'),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ScanningScreen(onDataScanned: (_) {}),
          ),
        ),
        child: const Icon(Icons.add),
        tooltip: "Add New Scan",
      ),
    );
  }
}
