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

    final url = Uri.parse('$_baseUrl/item/id/$itemId/');
    print('Making a PATCH request to $url');
    print('Body: ${jsonEncode({'borrowed_by_user': userId})}');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'borrowed_by_user': userId}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Exception caught during API call: $e');
      return false;
    }
  }
}
