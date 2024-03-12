import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:8000/api/v1';

  static Future<bool> updateItemBorrower(int itemId) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      print("User ID is not set.");
      return false;
    }

    final url = Uri.parse('$_baseUrl/item/$itemId/');
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'borrowed_by_user_id': userId}),
    );

    return response.statusCode == 200;
  }
}
