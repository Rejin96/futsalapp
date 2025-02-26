import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:playerconnect/src/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowRequest extends StatelessWidget {
  final List<dynamic> gameRequests;

  const ShowRequest({super.key, required this.gameRequests});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B2A41),
      appBar: AppBar(
        title: Text("Game Requests"),
        backgroundColor: Color(0xFF1B2A41),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: gameRequests.isEmpty
            ? Center(
                child: Text(
                  "No game requests found!",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: gameRequests.length,
                itemBuilder: (context, index) {
                  var request = gameRequests[index];

                  return Card(
                    color: Colors.blueGrey[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(request['name'] ?? 'Unknown',
                              style: TextStyle(color: Colors.white70)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                        "Date: ${request['start_time']} - ${request['end_time']}",
                        style: TextStyle(color: Colors.white),
                      ),
                          Text("Location: ${request['address'] ?? 'Unknown'}",
                              style: TextStyle(color: Colors.white70)),
                          Text("Player Count: ${request['player_count']}",
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                      trailing: Icon(Icons.sports_soccer, color: Colors.white),
                      onTap: () {
                        // Handle onTap to join the request
                        joinRequest(context, request['request_id']);
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

 Future<void> joinRequest(BuildContext context, int requestId) async {
  // Get JWT token from SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');  // Assuming the JWT token is saved in SharedPreferences
  String? csrfToken = prefs.getString('csrf_token');

   if(csrfToken == null){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSRF token is missing')),
      );
      return;
    }

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("No JWT token found. Please login again.")),
    );
    return;
  }

  // Prepare the body of the request
  Map<String, dynamic> body = {
    'request_id': requestId,
  };

  try {
    final response = await http.post(
     // Uri.parse('http://192.168.1.198:8000/join_request/'),
      //Uri.parse('http://192.168.1.68:8000/join_request/'),
      Uri.parse('http://10.0.2.2:8000/join_request/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',  // Send JWT token in Authorization header
        'X-CSRFToken': csrfToken,
        'Cookie' : 'csrftoken=$csrfToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Joined the request successfully!")),
        );
        // Navigate back to the homepage
        Navigator.push(context, MaterialPageRoute(builder: (context)=> My_HomePage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to join the request.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to join the request.")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}

}
