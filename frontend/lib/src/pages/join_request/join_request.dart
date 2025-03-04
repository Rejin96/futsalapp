import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:playerconnect/src/pages/join_request/show_request/show_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/urls.dart';

class JoinRequest extends StatefulWidget {
  const JoinRequest({super.key});

  @override
  State<JoinRequest> createState() => _JoinRequestState();
}

class _JoinRequestState extends State<JoinRequest> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    locationController.dispose();
    super.dispose();
  }

  // 🔹 Function to Fetch Data Based on Condition
  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? csrfToken = prefs.getString('csrf_token');
    if (csrfToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch CSRF token")),
      );
      return;
    }

    String date = dateController.text.trim();
    String time = timeController.text.trim();
    String? location = locationController.text.trim().isEmpty ? null : locationController.text.trim();

    if (date.isEmpty || time.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Date and Time are required")),
      );
      return;
    }

    Map<String, dynamic> body;

    if (location == null) {
      // 🔹 Get Location Coordinates if no location is provided
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      body = {
        "date": date,
        "time": time,
        "longitude": position.longitude.toString(),
        "latitude": position.latitude.toString(),
        "location": null
      };
    } else {
      // 🔹 Send Selected Location
      body = {
        "date": date,
        "time": time,
        "location": location
      };
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrls["showgamereq"]!),
        //Uri.parse('http://192.168.1.198:8000/show_game_req/'),
        // Uri.parse('http://10.0.2.2:8000/show_game_req/'),
        headers: {
          "Content-Type": "application/json",
          "X-CSRFToken": csrfToken,
          'Cookie': 'csrftoken=$csrfToken',
        },
        body: jsonEncode(body),
      );
      print("Request Body: ${jsonEncode(body)}");
      print("Selected Location: $location");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Reponse Data:$responseData");
        print("Type of status: ${responseData["status"].runtimeType}");  // Check the type
        print(responseData["status"]);
        print(responseData["distances"]);
        if (responseData["status"] != null && responseData["status"] == "success") {
          if(location == null){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShowRequest(gameRequests: responseData["distances"]),
            ),
          );}
          else{
             Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShowRequest(gameRequests: responseData["game_requests"]),
            ),
          );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No game requests found.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch game requests.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B2A41),
      appBar: AppBar(
        title: Text("Enter the Required Fields"),
        backgroundColor: Color(0xFF1B2A41),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextField("Enter Date (YYYY-MM-DD)", dateController, TextInputType.datetime),
            SizedBox(height: 16),
            buildTextField("Enter Time (HH:MM:SS)", timeController, TextInputType.datetime),
            SizedBox(height: 16),
            buildTextField("Enter Location (Optional)", locationController, TextInputType.text),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: fetchData, // Call fetchData when button is clicked
                child: Text("Search Requests"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, TextInputType keyboardType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white, fontSize: 16)),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.blueGrey[800],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            hintText: label,
            hintStyle: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
