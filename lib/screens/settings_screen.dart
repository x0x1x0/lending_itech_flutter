import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '';
    _idController.text = userId;
  }

  _saveUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', _idController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(labelText: "User ID"),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                _saveUserId();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("User ID saved!"),
                ));
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
