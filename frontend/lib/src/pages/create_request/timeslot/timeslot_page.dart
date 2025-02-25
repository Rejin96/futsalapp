import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:playerconnect/src/pages/home_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TimeSlotPage extends StatefulWidget {
  final String venue;
  final DateTime selectedDate;
  const TimeSlotPage({required this.venue, required this.selectedDate});

  @override
  _TimeSlotPageState createState() => _TimeSlotPageState();
}

class _TimeSlotPageState extends State<TimeSlotPage> {
  List<Map<String, dynamic>> timeSlots = []; // Empty list initially

  bool isLoading = true;
  String errorMessage = '';
  int? selectedSlotId;
  int playerCount = 1; //default value

  @override
  void initState() {
    super.initState();
    _fetchTimeSlots(); // Fetch time slots when the page is loaded
  }

  // Fetch time slots from the backend
  Future<void> _fetchTimeSlots() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final url = Uri.parse('http://192.168.1.198:8000/show_time_slot/');
    String? csrfToken = prefs.getString('csrf_token');
    String? token = prefs.getString('auth_token');

    if (token == null) {
      print('Token missing!');
      return;
    }
    if (csrfToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSRF token is missing')),
      );
      return;
    }
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRFToken': csrfToken,
        'Cookie': 'csrftoken=$csrfToken',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'futsal_name': widget.venue,
        'date': widget.selectedDate.toIso8601String(),
      }),
      // Adding query parameters (futsal_name and date)
      // Assuming backend accepts futsal_name and date as query parameters
    );

    if (response.statusCode == 200) {
      // Successfully fetched data
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          timeSlots = List<Map<String, dynamic>>.from(data['timeslots']);
          isLoading = false;
          errorMessage = '';
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Error: ${data['message']}';
        });
        print("Error: ${data['message']}");
      }
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load time slots.';
      });
      print("Failed to load time slots.");
    }
  }

   Future<void> pickSlot(int slotId, int playerCount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final url = Uri.parse('http://192.168.1.198:8000/pick_time_slot/');
    String? csrfToken = prefs.getString('csrf_token');
    String? token = prefs.getString('auth_token');

    if (token == null || csrfToken == null) {
      print('Token or CSRF token missing!');
      return;
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRFToken': csrfToken,
        'Cookie': 'csrftoken=$csrfToken',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'slot_id': slotId,
        'player_count': playerCount,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request created successfully!')),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => My_HomePage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${data['message']}')),
        );
      }
    } else {
      print("Failed to create request.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Time Slots - ${widget.venue}"),
        backgroundColor: Color(0xFF1B2A41),
        foregroundColor: Colors.grey.shade300,
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
        child: Column(
          children: [
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (errorMessage.isNotEmpty)
              Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: timeSlots.length,
                  itemBuilder: (context, index) {
                    final slot = timeSlots[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSlotId = slot['slot_id']; // Set selected slot id
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: selectedSlotId == slot['slot_id']
                              ? Colors.green // Highlight selected slot
                              : Color(0xFF1E3A5F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${slot['startTime'] ?? 'No start time'} - ${slot['endTime'] ?? 'No end time'}",
                                style: TextStyle(color: Colors.white, fontSize: 18)),
                            SizedBox(height: 10),
                            Text("Slot ID: ${slot['slot_id'] ?? 'N/A'}", style: TextStyle(color: Colors.white, fontSize: 16)),
                            SizedBox(height: 5),
                            Text("State: ${slot['state'] ?? 'N/A'}", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 20),
            // Player count input field with buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        if (playerCount > 1) playerCount--;
                      });
                    },
                  ),
                  Container(
                    width: 60,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      decoration: InputDecoration(
                        labelText: 'Players',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onChanged: (value) {
                        setState(() {
                          playerCount = int.tryParse(value) ?? 1;
                          if (playerCount < 1) playerCount = 1; // Ensure minimum 1 player
                          if (playerCount > 15) playerCount = 15; // Ensure maximum 15 players
                        });
                      },
                      controller: TextEditingController(text: playerCount.toString()),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        if (playerCount < 15) playerCount++;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Confirm button
            ElevatedButton(
              onPressed: selectedSlotId != null
                  ? () {
                      pickSlot(selectedSlotId!, playerCount); // Call pickSlot function
                    }
                  : null,
              child: Text('Confirm Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1B2A41), // Use backgroundColor instead of primary
                foregroundColor: Colors.white, // Use foregroundColor instead of onPrimary
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 80),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
