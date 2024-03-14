import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.6.107:8000/api/v1';

  static Future<bool> returnItem(int itemId) async {
    final url = Uri.parse('$_baseUrl/item/id/$itemId/');

    print('Making a PATCH request to $url');
    print('Request body: {"borrowed_by_user":null}');

    try {
      final response = await http.patch(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(
              {'borrowed_by_user': null}) // Pass null directly without quotes
          );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Exception during API call: $e');
      return false;
    }
  }

  static Future<bool> updateItemBorrower(int itemId) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      print("User ID is not set.");
      return false;
    }

    final url = Uri.parse('$_baseUrl/item/id/$itemId/');
    final body = jsonEncode({'borrowed_by_user': userId});

    print('Making a PATCH request to $url');
    print('Request body: $body');

    try {
      final response = await http.patch(url,
          headers: {'Content-Type': 'application/json'}, body: body);

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Exception during API call: $e');
      return false;
    }
  }

  static Future<List<dynamic>> fetchItemsBorrowedByUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId == null) {
      print("User ID is not set.");
      return [];
    }
    final url = Uri.parse('$_baseUrl/borrowed_items_by_user/$userId/');
    try {
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        print('Failed to load items');
        return [];
      }
    } catch (e) {
      print('Exception caught during API call: $e');
      return [];
    }
  }
}
