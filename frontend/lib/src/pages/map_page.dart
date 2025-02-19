import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // GoogleMapController to control the map
  GoogleMapController? _controller;

  // Initial position for the camera
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(27.7172, 85.3240), // Example coordinates (Kathmandu)
    zoom: 14,
  );

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
        initialCameraPosition: _initialPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
        // You can add markers or customize the map here
        markers: {
          Marker(
            markerId: MarkerId('1'),
            position: LatLng(27.7172, 85.3240), // Example marker position
            infoWindow: InfoWindow(title: 'Kathmandu'),
          ),
        },
      ),
    );
  }
}
