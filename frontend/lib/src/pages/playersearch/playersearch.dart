import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Playersearch extends StatefulWidget {
  const Playersearch({super.key});

  @override
  State<Playersearch> createState() => _PlayersearchState();
}

class _PlayersearchState extends State<Playersearch> {
  List<dynamic> players = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlayers();
  }

  Future<void> fetchPlayers() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:8000/players/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          players = data['players'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load players');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.grey.shade300,
          ),
        ),
        title: Text(
          "Players",
          style: TextStyle(color: Colors.grey.shade300),
        ),
        backgroundColor: Color(0xFF1B2A41),
        foregroundColor: Colors.grey.shade300,
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
                  colors: [
                    Color(0xFF1B2A41),
                    Color(0xFF23395B),
                    Color(0xFF2D4A69),
                  ],
                  stops: [0.3, 0.7, 1.0],
                ),
              ),
            ),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : players.isEmpty
                    ? Center(
                        child: Text(
                          "No players found.",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 20.0),
                        itemCount: players.length,
                        itemBuilder: (context, index) {
                          final player = players[index];
                          return Card(
                            color: Color(0xFF1E3A5F),
                            margin: EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  // Profile Picture
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/futsaluser.jpeg'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Player Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          player['name'] ?? 'No Name',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Location: ${player['location'] ?? 'Unknown'}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Contact: ${player['phone number'] ?? 'N/A'}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
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
