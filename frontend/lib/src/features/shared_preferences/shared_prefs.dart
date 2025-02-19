import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  // Save user data
  static Future<void> saveUserData(
    String name,
    String email,
    String phoneno,
    String location,
    String password, {
    String? profilePicture,
    String? locationId, // New parameter for location ID
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('email', email);
    await prefs.setString('phone_no', phoneno);
    await prefs.setString('location', location);
    await prefs.setString('password', password);
    if (profilePicture != null) {
      await prefs.setString('profile_picture', profilePicture);
    }
    if (locationId != null) {
      await prefs.setString('location_id', locationId); // Save location ID
    }
  }

  // Retrieve user data
  static Future<Map<String, String?>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      "name": prefs.getString('user_name'),
      "email": prefs.getString('email'),
      "phone_no": prefs.getString('phone_no'),
      "location": prefs.getString('location'),
      "password": prefs.getString('password'),
      "profile_picture": prefs.getString('profile_picture'),
      "location_id": prefs.getString('location_id'), // Retrieve location ID
    };
  }

  // Clear all user data
  static Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Save online status
  static Future<void> saveOnlineStatus(bool isOnline) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_online', isOnline);
  }

  // Get online status
  static Future<bool> getOnlineStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_online') ?? false; // Default to offline if not set
  }

  // **New: Save CSRF Token**
  static Future<void> saveCsrfToken(String csrfToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('csrf_token', csrfToken);
  }

  // **New: Get CSRF Token**
  static Future<String?> getCsrfToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('csrf_token');
  }

  static Future<void> saveSessionId(String sessionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sessionid', sessionId);
    print("Session ID saved: $sessionId");
  }

  static Future<String?> getSessionId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('sessionid');
  }
}
