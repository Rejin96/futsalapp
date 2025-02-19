import 'package:flutter/material.dart';
import 'package:playerconnect/src/pages/create_request/timeslot/timeslot_page.dart';

class CreateRequest extends StatelessWidget {
  CreateRequest({super.key});

  // Sample futsal venue data (Replace with actual data from backend)
  final List<Map<String, String>> futsalVenues = [
    {
      "name": "City Futsal",
      "location": "Kathmandu",
    },
    {
      "name": "Goal Arena",
      "location": "Lalitpur",
    },
    {
      "name": "Kick Off Futsal",
      "location": "Bhaktapur",
    },
    {
      "name": "Hello futsal",
      "location": "Lalitpur",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey.shade300),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text("Select Futsal Venues",
              style: TextStyle(color: Colors.grey.shade300)),
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
          child: ListView.builder(
            itemCount: futsalVenues.length,
            itemBuilder: (context, index) {
              final venue = futsalVenues[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        // Check if the venue's name is null or empty before passing it
                        if (venue["name"] != null &&
                            venue["name"]!.isNotEmpty) {
                          return TimeSlotPage(venue: venue["name"]!);
                        } else {
                          // Handle the error (you can return a fallback widget or show a message)
                          return Scaffold(
                            body: Center(
                                child: Text('Error: Venue name is missing')),
                          );
                        }
                      },
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Color(0xFF1E3A5F),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            venue["name"]!,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            venue["location"]!,
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 14),
                          ),
                        ],
                      ),
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
