import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CsrfService {
  static const String csrfUrl = "http://10.0.2.2:8000/csrf-token/";

  static Future<void> fetchCsrfToken() async {
    try {
      final response = await http.get(Uri.parse(csrfUrl));
      if (response.statusCode == 200) {
        final cookies = response.headers['set-cookie'];
        if (cookies != null) {
          final csrfToken = extractCsrfToken(cookies);
          if (csrfToken != null) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('csrf_token', csrfToken);
            print("CSRF Token Fetched: $csrfToken");
          }
        }
      } else {
        print("Failed to fetch CSRF token: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching CSRF token: $e");
    }
  }

  static String? extractCsrfToken(String cookies) {
    final match = RegExp(r'csrftoken=([^;]+)').firstMatch(cookies);
    return match?.group(1);
  }
}
