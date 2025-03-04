import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../api/urls.dart';

class JoinedGameDetails extends StatefulWidget {
  const JoinedGameDetails({super.key});

  @override
  State<JoinedGameDetails> createState() => _JoinedGameDetailsState();
}

class _JoinedGameDetailsState extends State<JoinedGameDetails> {
  List<dynamic> joinedGames = [];
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    fetchJoinedGames();
  }

  Future<void> fetchJoinedGames() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    String? csrfToken = prefs.getString('csrf_token');
    if (token == null) {
      print('Token missing!');
      return;
    }
    if (csrfToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSRF token is missing!')),
      );
      return;
    }

      final response = await http.post(
        Uri.parse(apiUrls["seegamedetails"]!),
        headers: {
          'Authorization': 'Bearer $token',
          'X-CSRFToken': csrfToken,
          'Content-Type': 'application/json',
          'Cookie': 'csrftoken=$csrfToken',
        },
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            joinedGames = data['game_details'];
            isLoading = false;
          });
        } else {
          print("API Error: ${data['message']}");
        }
      } else {
        print("Failed to fetch data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching joined games: $e");
    }
  }

  // Function to get the color based on participant status
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.yellow;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.grey.shade300),
          ),
          title: Text("Joined Games", style: TextStyle(color: Colors.grey.shade300)),
          backgroundColor: Color(0xFF1B2A41),
          elevation: 0,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.9,
              colors: [
                Color(0xFF1B2A41),
                Color(0xFF23395B),
                Color(0xFF2D4A69),
              ],
              stops: [0.3, 0.7, 1.0],
            ),
          ),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : joinedGames.isEmpty
                  ? Center(child: Text("No joined games", style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      itemCount: joinedGames.length,
                      itemBuilder: (context, index) {
                        final game = joinedGames[index];
                        return Card(
                          margin: EdgeInsets.all(10),
                          color: Color(0xFF1B2A41),
                          child: ListTile(
                            title: Text(game['futsal_name'], style: TextStyle(color: Colors.white, fontSize: 18)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Creator: ${game['creator_name']}", style: TextStyle(color: Colors.grey)),
                                Text("Time: ${game['start_time']} - ${game['end_time']}", style: TextStyle(color: Colors.grey)),
                                Text("Status: ${game['game_status']}", style: TextStyle(color: Colors.green)),
                                Text(
                                  "Participant Status: ${game['participant_status']}",
                                  style: TextStyle(color: getStatusColor(game['participant_status'])),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.map, color: Colors.blueAccent),
                              onPressed: () async {
                                Uri url = Uri.parse(game['google_map_location']);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                } else {
                                  print("Could not launch URL");
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
