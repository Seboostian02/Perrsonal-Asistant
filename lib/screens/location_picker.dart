import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage(
      {super.key, required Null Function(LatLng location) onLocationSelected});

  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  late GoogleMapController _mapController;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Map"),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(-23.5557714, -46.6395571), // Poziția inițială
          zoom: 5,
        ),
        mapType: MapType
            .normal, // Poți schimba între MapType.normal, MapType.satellite, etc.
        myLocationEnabled: true, // Activăm MyLocation
        myLocationButtonEnabled: true, // Activăm butonul de localizare
      ),
    );
  }
}
