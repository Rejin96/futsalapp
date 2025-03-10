import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:playerconnect/src/api/urls.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Notificationpage extends StatefulWidget {
  const Notificationpage({super.key});

  @override
  State<Notificationpage> createState() => _NotificationpageState();
}

class _NotificationpageState extends State<Notificationpage> {
  bool isLoading = true;
  List<dynamic> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    String? csrfToken = prefs.getString('csrf_token');

    if (token == null || csrfToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication tokens missing!')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrls["getnotifications"]!),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'X-CSRFToken': csrfToken,
          'Cookie': 'csrftoken=$csrfToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          notifications = data['notifications'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

   Future<void> sendnotification(int receiver_id, String message) async{
     SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    String? csrfToken = prefs.getString('csrf_token');
    if (token == null || csrfToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication token missing!')),
      );
      return;
    }
    try{
      final response = await http.post(
        Uri.parse(apiUrls["sendnotification"]!),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'X-CSRFToken': csrfToken,
          'Cookie': 'csrftoken=$csrfToken',
        },
        body: json.encode({
          'receiver_id': receiver_id,
          'message': message,
        }),
      );
       if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          // Show success message or proceed with UI updates
          print('Notification sent successfully');
        } else {
          // Handle failure response from backend
          print('Error: ${responseData['message']}');
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    }catch(e){
        print('Error sending notification: $e');
    }
  }

 Future<Map<String, dynamic>?> loadUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');

  if (token == null) {
    print('Token missing!');
    return null; // Return null if token is missing
  }

  final response = await http.get(
    Uri.parse(apiUrls["getplayer"]!), // Fetch logged-in player
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    final currentUser = responseData['user']; // Gets logged-in player details

    // Check if user exists and return the name and user_id as int
    if (currentUser != null) {
      return {
        'user_id': currentUser['user_id'] is int
            ? currentUser['user_id']
            : int.parse(currentUser['user_id'].toString()), // Convert to int if needed
        'name': currentUser['name'],
      };
    } else {
      print('User data is missing');
      return null; // Return null if user data is not found
    }
  } else {
    print('Failed to load user data');
    return null; // Return null if API call fails
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade300),
        ),
        title: Text("Notifications", style: TextStyle(color: Colors.grey.shade300)),
        backgroundColor: Color(0xFF1B2A41),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.9,
                  colors: [Color(0xFF1B2A41), Color(0xFF23395B), Color(0xFF2D4A69)],
                  stops: [0.3, 0.7, 1.0],
                ),
              ),
            ),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : notifications.isEmpty
                    ? Center(
                        child: Text(
                          "No notifications",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return Card(
                            color: Color(0xFF1E3A5F),
                            margin: EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification['message'],
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        notification['timestamp'],
                                        style: TextStyle(fontSize: 12, color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () async{
                                          var userData = await loadUserData();
                                          if(userData !=null){
                                            print(userData['user_id']);
                                            print(userData['name']);
                                          sendnotification(notification['sender_id'], '${userData['name']} has accepted request');
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text("Accept"),
                                      ),
                                      ElevatedButton(
                                          onPressed: () async{
                                          var userData = await loadUserData();
                                          if(userData !=null){
                                          sendnotification(notification['sender_id'], '${userData['name']} has rejected request');
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text("Reject"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
