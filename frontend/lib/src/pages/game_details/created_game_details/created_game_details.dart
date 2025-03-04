import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../api/urls.dart';

class CreatedGameDetails extends StatefulWidget {
  const CreatedGameDetails({super.key});

  @override
  State<CreatedGameDetails> createState() => _CreatedGameDetailsState();
}

class _CreatedGameDetailsState extends State<CreatedGameDetails> {
  List<dynamic> createdGames = [];

  @override
  void initState() {
    super.initState();
    fetchCreatedGameDetails();
  }

  // Fetch game details from API
  Future<void> fetchCreatedGameDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    String? csrfToken = prefs.getString('csrf_token');

    if (token != null && csrfToken != null) {
      var response = await http.post(
        Uri.parse(apiUrls["createdgamedetails"]!),
        headers: {
          'Authorization': 'Bearer $token',
          'X-CSRFToken': csrfToken,
            'Content-Type': 'application/json',
          'Cookie': 'csrftoken=$csrfToken',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          createdGames = data['created_game_details'];
        });
      } else {
        print("Failed to load game details");
      }
    } else {
      print("Missing JWT or CSRF token");
    }
  }

  // Function to launch the Google Maps location
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false);
    } else {
      throw 'Could not launch $url';
    }
  }

   // Function to send confirm/cancel request to API
  Future<void> handleParticipation(String action, String requestId, String participantUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    String? csrfToken = prefs.getString('csrf_token');

    if (token != null && csrfToken != null) {
      var response = await http.post(
        Uri.parse(apiUrls["handleparticipation"]!),
        headers: {
          'Authorization': 'Bearer $token',
          'X-CSRFToken': csrfToken,
          'Content-Type': 'application/json',
          'Cookie': 'csrftoken=$csrfToken',
        },
        body: json.encode({
          'request_id': requestId,
          'participant_user_id': participantUserId,
          'action': action,  // "confirm" or "cancel"
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          // Handle success (show a success message, update the UI)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
          setState(() {
            // Refresh the game details after the action is performed
            fetchCreatedGameDetails();
          });
        } else {
          // Handle error (show an error message)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else {
        // Handle API failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to perform action')),
        );
      }
    } else {
      print("Missing JWT or CSRF token");
    }
  }

  // Function to display participant status color
  Color _getParticipantStatusColor(String status) {
    if (status == 'pending') {
      return Colors.yellow;
    } else if (status == 'confirmed') {
      return Colors.green;
    } else if (status == 'cancelled') {
      return Colors.red;
    }
    return Colors.black;
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
              icon: Icon(
                Icons.arrow_back,
                color: Colors.grey.shade300,
              )),
          title: Text(
            "Created Games",
            style: TextStyle(color: Colors.grey.shade300),
          ),
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
          child: createdGames.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: createdGames.length,
                  itemBuilder: (context, index) {
                    var game = createdGames[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      color: Color(0xFF23395B), // Same card color as background
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              game['futsal_name'],
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            SizedBox(height: 8),
                            Text("Players: ${game['num_players']}", style: TextStyle(color: Colors.white)),
                            SizedBox(height: 8),
                            Text("Start Time: ${game['start_time']}", style: TextStyle(color: Colors.white)),
                            Text("End Time: ${game['end_time']}", style: TextStyle(color: Colors.white)),
                            SizedBox(height: 8),
                            Text("Game Status: ${game['game_status']}", style: TextStyle(color: Colors.white)),
                            SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                _launchURL(game['google_map_location']);
                              },
                              child: Text(
                                "Google Map Location",
                                style: TextStyle(
                                    color: Colors.blue, decoration: TextDecoration.underline),
                              ),
                            ),
                            SizedBox(height: 12),
                            if (game['participants'].isNotEmpty)
                              ...game['participants'].map<Widget>((participant) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(participant['participant_name'], style: TextStyle(color: Colors.white)),
                                      SizedBox(height: 8), // Move buttons below the name
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            participant['participant_status'],
                                            style: TextStyle(
                                              color: _getParticipantStatusColor(participant['participant_status']),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              handleParticipation(
                                                  'confirm', // action: confirm or cancel
                                                  game['request_id'].toString(), // request_id from the game data
                                                  participant['participant_id'].toString(), // participant_user_id
                                              );
                                            },
                                            child: Text('Confirm'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              handleParticipation(
                                                  'cancel', // action: confirm or cancel
                                                  game['request_id'].toString(), // request_id from the game data
                                                  participant['participant_id'].toString(), // participant_user_id
                                              );
                                            },
                                            child: Text('Cancel'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          ],
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
