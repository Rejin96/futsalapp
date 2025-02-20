import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  late LatLng _currentLocation;

  // Initial position for the camera (can be changed once we get the live location)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(27.7172, 85.3240), // Example coordinates (Kathmandu)
    zoom: 14,
  );

  // Function to get current location
  Future<void> _getCurrentLocation() async {
    // Check if the user has granted permission for location services
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    // If permission is granted, get the current position
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
       print('Latitude: ${position.latitude}');
    print('Longitude: ${position.longitude}');

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      // Move the map camera to the user's location
      _controller?.animateCamera(CameraUpdate.newLatLng(_currentLocation));
    }
  }

  @override
  void initState() {
    super.initState();
    _currentLocation = _initialPosition.target; // Default location

    // Get the current location when the page loads
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLocation, // Use the current location
          zoom: 14,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
        markers: {
          Marker(
            markerId: MarkerId('1'),
            position: _currentLocation, // Show the user's live location
            infoWindow: InfoWindow(title: 'Your Location'),
          ),
        },
      ),
    );
  }
}
