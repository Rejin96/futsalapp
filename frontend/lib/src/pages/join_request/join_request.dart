import 'package:flutter/material.dart';

class JoinRequest extends StatefulWidget {
  const JoinRequest({super.key});

  @override
  State<JoinRequest> createState() => _JoinRequestState();
}

class _JoinRequestState extends State<JoinRequest> {
  String? selectedDay;
  String? selectedTimeSlot;
  String? selectedLocation;

  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  final List<String> timeSlots = [
    "6 AM - 8 AM",
    "8 AM - 10 AM",
    "4 PM - 6 PM",
    "6 PM - 8 PM",
    "8 PM - 10 PM"
  ];
  final List<String> locations = ["Thankot", "Baneshwor", "Sankhamul", "Patan"];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.grey.shade300,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Enter the Required Fields",
            style: TextStyle(color: Colors.grey.shade300),
          ),
          backgroundColor: Color(0xFF1B2A41),
          elevation: 0,
        ),
        body: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDropdown("Select Day", days, selectedDay, (value) {
                setState(() {
                  selectedDay = value;
                });
              }),
              SizedBox(height: 16),
              buildDropdown("Select Time Slot", timeSlots, selectedTimeSlot,
                  (value) {
                setState(() {
                  selectedTimeSlot = value;
                });
              }),
              SizedBox(height: 16),
              buildDropdown("Select Location", locations, selectedLocation,
                  (value) {
                setState(() {
                  selectedLocation = value;
                });
              }),
              SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade400,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    if (selectedDay != null &&
                        selectedTimeSlot != null &&
                        selectedLocation != null) {
                      // Trigger filter logic here
                      print(
                          "Filtering requests for $selectedDay, $selectedTimeSlot at $selectedLocation");
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please fill all the fields.")),
                      );
                    }
                  },
                  child: Text(
                    "Search Requests",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDropdown(String label, List<String> items, String? selectedValue,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade500),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Color(0xFF23395B),
              value: selectedValue,
              hint: Text(
                "Choose $label",
                style: TextStyle(color: Colors.grey.shade400),
              ),
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade300),
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(color: Colors.grey.shade200),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
