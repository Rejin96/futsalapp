import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:playerconnect/src/pages/create_request/timeslot/timeslot_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/urls.dart';

class CreateRequest extends StatefulWidget {
  @override
  _CreateRequestState createState() => _CreateRequestState();
}

class _CreateRequestState extends State<CreateRequest> {
  List venues = [];
  List<Map<String, dynamic>> futsalVenues = [];
  bool isLoading = true;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // Get user's live location
  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Now that we have user's location, we can call the API
    _fetchNearbyFutsalVenues(position.latitude, position.longitude);
  }

  Future<void> _fetchNearbyFutsalVenues(
      double latitude, double longitude) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? csrfToken = prefs.getString('csrf_token');

    if (csrfToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSRF token is missing')),
      );
      return;
    }

    if (latitude == 0.0 || longitude == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid location data')),
      );
      return;
    }

    print("Latitude: $latitude, Longitude: $longitude");

    try {
      final response = await http.post(
       Uri.parse(apiUrls["nearBy"]!),
       //Uri.parse('http://192.168.1.198:8000/near_by/'),
        // Uri.parse('http://10.0.2.2:8000/near_by/'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRFToken': csrfToken,
          'Cookie': 'csrftoken=$csrfToken',
        },
        body: json.encode({
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        }),
      );
      print('Request Sent: ${response.statusCode}');
      print("CSRF Token: $csrfToken");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Check if data['data'] is not null and it's an array
        List venues = data['data'] ?? [];

        if (venues.isNotEmpty) {
          setState(() {
            futsalVenues = venues.map((venue) {
              return {
                "name": venue['name'] ?? 'Unnamed Venue',
                "location": venue['location'] ?? 'Unknown Location',
                "distance": venue['distance'] ?? 0.0,
                "phone_number": venue['phone_number'] ?? 'N/A',
              };
            }).toList();
            isLoading = false; // Set loading state to false
          });
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No venues found nearby')),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to load futsal venues: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _pickDate() async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(Duration(days: 30)), // Limit selection to next 30 days
  );

  if (pickedDate != null) {
    setState(() {
      selectedDate = pickedDate;
    });
  }
}
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
       body: isLoading
    ? Center(child: CircularProgressIndicator())
    : Container(
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
            // Date Picker Button
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                onPressed: _pickDate,
                icon: Icon(Icons.calendar_today, color: Colors.white),
                label: Text(
                  selectedDate == null
                      ? "Select Date"
                      : "${selectedDate!.toLocal()}".split(' ')[0],
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
      
            // Venue List
            Expanded(
              child: futsalVenues.isEmpty
                  ? Center(child: Text("No futsal venues found"))
                  : ListView.builder(
                      itemCount: futsalVenues.length,
                      itemBuilder: (context, index) {
                        final venue = futsalVenues[index];
                        return GestureDetector(
                          onTap: () {
                            if (selectedDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please select a date')),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return TimeSlotPage(
                                    venue: venue["name"],
                                    selectedDate: selectedDate!,
                              
                                  );
                                },
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        venue["name"],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "Distance: ${venue["distance"].toStringAsFixed(2)} km",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                      SizedBox(height: 5),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
    ),

      ),
    );
  }

  // Widget _buildVenueList(List<Map<String, dynamic>> venues) {
  //   return ListView.builder(
  //     itemCount: venues.length,
  //     itemBuilder: (context, index) {
  //       final venue = venues[index];
  //       return GestureDetector(
  //         onTap: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) {
  //                 return TimeSlotPage(venue: venue["name"]);
  //               },
  //             ),
  //           );
  //         },
  //         child: Container(
  //           margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  //           padding: EdgeInsets.all(15),
  //           decoration: BoxDecoration(
  //             color: Color(0xFF1E3A5F),
  //             borderRadius: BorderRadius.circular(12),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.2),
  //                 blurRadius: 8,
  //                 spreadRadius: 2,
  //                 offset: Offset(0, 4),
  //               ),
  //             ],
  //           ),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     venue["name"],
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   SizedBox(height: 5),
  //                   Text(
  //                     venue["location"],
  //                     style:
  //                         TextStyle(color: Colors.grey.shade400, fontSize: 14),
  //                   ),
  //                   SizedBox(height: 5),
  //                   Text(
  //                     "Distance: ${venue["distance"].toStringAsFixed(2)} km",
  //                     style: TextStyle(color: Colors.white, fontSize: 14),
  //                   ),
  //                   SizedBox(height: 5),
  //                   Text(
  //                     "Phone: ${venue["phone_number"]}",
  //                     style: TextStyle(color: Colors.white, fontSize: 14),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
