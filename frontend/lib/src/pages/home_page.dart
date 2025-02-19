import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:playerconnect/src/pages/playersearch/playersearch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playerconnect/src/pages/create_request/create_request.dart';
import 'package:playerconnect/src/pages/editprofile/editprofile.dart';
import 'package:playerconnect/src/pages/join_request/join_request.dart';
import 'package:playerconnect/src/features/authentication/screens/login/login_page.dart';
import 'package:playerconnect/src/pages/map_page.dart';
import '../features/shared_preferences/shared_prefs.dart';
import 'dart:io';

class My_HomePage extends StatefulWidget {
  const My_HomePage({super.key});

  @override
  _My_HomePageState createState() => _My_HomePageState();
}

class _My_HomePageState extends State<My_HomePage> {
  String _isOnline = "offline";
  String userName = "Guest";
  String userEmail = "No Email";
  String userPhone = "No Phone";
  String userLocation = "No Location";
  String? profilePicturePath;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      print('Token missing!');
      return;
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/getplayer/'), // Fetch logged in player
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      final currentUser = responseData['user']; //gives logged in player detail

      // Get the logged-in user's email from SharedPreferences (set during login)
      String? email = prefs.getString('email');
      print('Logged-in emai:$email');

      // Filter the player matching the logged-in user's email
      if (currentUser != null &&
          currentUser['email'].toLowerCase().trim() ==
              email?.toLowerCase().trim()) {
        setState(() {
          userName = currentUser['name'] ?? "Guest";
          userEmail = currentUser['email'] ?? "No Email";
          userPhone = currentUser['phone_number'] ?? "No Phone";
          userLocation = currentUser['location'] ?? "No Location";
          profilePicturePath = currentUser['image'] ?? "default_image_path";

          _isOnline = currentUser['status'] ?? 'offline';
        });
      } else {
        print('User not found or email mismatch');
      }
    } else {
      print('Failed to load user data');
    }
  }

  void toggleOnlineStatus(bool value) async {
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
      Uri.parse('http://10.0.2.2:8000/change_state/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'X-CSRFToken': csrfToken,
        'Cookie': 'csrftoken=$csrfToken',
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print(responseData);
      // Update _isOnline with the string "online" or "offline"
      setState(() {
        _isOnline = value ? 'online' : 'offline';
      });
    } else {
      print('Failed to change status');
    }
  }

  Future<void> logout() async {
    await SharedPrefs.clearUserData();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Loginpage()), // Redirect to login
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PopupMenuButton<String>(
          icon: Icon(Icons.dashboard), // Dashboard icon
          onSelected: (value) {
            if (value == 'edit_profile') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(),
                ),
              ).then((_) {
                // Refresh the homepage data after editing
                loadUserData();
              });
            } else if (value == 'logout') {
              SharedPrefs.clearUserData(); // Clear stored user data
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Loginpage()), // Navigate to login screen
              );
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: 'edit_profile',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.black54),
                  SizedBox(width: 8),
                  Text("Edit Profile"),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text("Logout"),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapPage(),
                ),
              );
            },
            icon: Icon(Icons.group),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapPage(),
                ),
              );
            },
            icon: Icon(Icons.location_on),
          ),
        ],
        backgroundColor: Color(0xFF1B2A41), // Dark greenish background
        foregroundColor: Colors.grey.shade300,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Gradient background with green variations
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

            // Profile Card
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Profile Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18.0),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.8,
                        colors: [
                          Color(0xFF23395B),
                          Color(0xFF2D4A69),
                        ],
                        stops: [0.3, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 3,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Picture
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            image: profilePicturePath != null &&
                                    File(profilePicturePath!).existsSync()
                                ? DecorationImage(
                                    image: FileImage(File(profilePicturePath!)),
                                    fit: BoxFit.cover,
                                  )
                                : DecorationImage(
                                    image: AssetImage(
                                        'assets/images/futsaluser.jpeg'),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // User Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$userName",
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1.5, 1.5),
                                      blurRadius: 4,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Location: ${userLocation}",
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Contact: ${userPhone}",
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Toggle for Online/Offline Status
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _isOnline == 'online' ? "Online" : "Offline",
                                    style: TextStyle(
                                      fontFamily: 'Kanit',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Switch(
                                    value: _isOnline == 'online',
                                    onChanged: toggleOnlineStatus,
                                    activeColor:
                                        Color(0xFF65A3B8), // Online color
                                    inactiveTrackColor: Color(0xFF4C6D7A),
                                    inactiveThumbColor: Colors.white,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Buttons Section
                  Column(
                    children: [
                      _buildSteamStyledButton(
                        context,
                        "Create Request",
                        Icons.add_circle_outline,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateRequest(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildSteamStyledButton(
                        context,
                        "Join Request",
                        Icons.person_add,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JoinRequest(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      _buildSteamStyledButton(
                        context,
                        "Search for players",
                        Icons.search,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Playersearch(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSteamStyledButton(BuildContext context, String title,
      IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF65A3B8),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: const BorderSide(color: Colors.white, width: 2),
        shadowColor: Colors.black,
        elevation: 10,
        minimumSize: const Size(double.infinity, 60),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
