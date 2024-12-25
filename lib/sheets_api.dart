import 'package:http/http.dart' as http;
import 'dart:convert';

class UserSheetsApi {
  static Future<List<Map<String, dynamic>>> fetchAllFarmData(String farmName) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://script.google.com/macros/s/AKfycbyMu3mmaRjoR2ytUlzh8UOMCUNMQYtIh56NX_lxQx69CL7_Ka_JZwDWrRSDJ5nx93cu/exec',
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonData['allData']);
      } else {
        throw Exception('Failed to load data from Google Sheets');
      }
    } catch (e) {
      print('Error fetching all farm data: $e');
      return [];
    }
  }
}
