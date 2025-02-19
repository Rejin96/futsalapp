import 'package:flutter/material.dart';

class TimeSlotPage extends StatefulWidget {
  final String venue;
  const TimeSlotPage({required this.venue});

  @override
  _TimeSlotPageState createState() => _TimeSlotPageState();
}

class _TimeSlotPageState extends State<TimeSlotPage> {
  String? selectedDay;
  int? selectedSlotIndex; // Track the selected slot index

  List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  List<Map<String, dynamic>> timeSlots = [
    {
      "startTime": "5:00 PM",
      "endTime": "6:00 PM",
      "occupySelected": false,
      "bookSelected": false,
    },
    {
      "startTime": "6:00 PM",
      "endTime": "7:00 PM",
      "occupySelected": false,
      "bookSelected": false,
    },
    {
      "startTime": "7:00 PM",
      "endTime": "8:00 PM",
      "occupySelected": false,
      "bookSelected": false,
    },
  ];

  Color _getButtonColor(
      bool isSelected, Color defaultColor, Color activeColor) {
    return isSelected ? activeColor : defaultColor;
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
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1E3A5F),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () async {
                  String? day = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Color(0xFF1B2A41),
                        title: Text("Select Day",
                            style: TextStyle(color: Colors.white)),
                        content: Container(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: days.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(days[index],
                                    style:
                                        TextStyle(color: Colors.grey.shade300)),
                                onTap: () {
                                  Navigator.pop(context, days[index]);
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                  if (day != null) {
                    setState(() {
                      selectedDay = day;
                    });
                  }
                },
                child: Text(
                  selectedDay ?? "Select Day",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  final slot = timeSlots[index];
                  return Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Color(0xFF1E3A5F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${slot['startTime']} - ${slot['endTime']}",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: (selectedSlotIndex == null ||
                                      selectedSlotIndex == index)
                                  ? () {
                                      setState(() {
                                        slot['occupySelected'] =
                                            !slot['occupySelected'];
                                        if (slot['occupySelected']) {
                                          slot['bookSelected'] = false;
                                          selectedSlotIndex = index;
                                        } else {
                                          selectedSlotIndex = null;
                                        }
                                      });
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getButtonColor(
                                  slot['occupySelected'],
                                  Color(0xFF1E3A5F),
                                  Colors.yellow,
                                ),
                                minimumSize: Size(140, 40),
                              ),
                              child: Text(
                                "Occupy",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: (selectedSlotIndex == null ||
                                      selectedSlotIndex == index)
                                  ? () {
                                      setState(() {
                                        slot['bookSelected'] =
                                            !slot['bookSelected'];
                                        if (slot['bookSelected']) {
                                          slot['occupySelected'] = false;
                                          selectedSlotIndex = index;
                                        } else {
                                          selectedSlotIndex = null;
                                        }
                                      });
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getButtonColor(
                                  slot['bookSelected'],
                                  Color(0xFF1E3A5F),
                                  Colors.green,
                                ),
                                minimumSize: Size(140, 40),
                              ),
                              child: Text(
                                "Book",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  if (selectedDay == null || selectedSlotIndex == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please select a day and a time slot."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Request Confirmed!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1B2A41),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text("Confirm", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
