import 'package:calendar/widgets/location_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:googleapis/cloudfunctions/v2.dart';

class LocationPickerPage extends StatefulWidget {
  final Function(LatLng location)
      onLocationSelected; // Add this function to handle the location selection

  const LocationPickerPage({
    Key? key,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  late GoogleMapController _mapController;
  late GooglePlace googlePlace;
  List<AutocompletePrediction> _predictions = [];
  String _searchInput = '';

  @override
  void initState() {
    super.initState();
    // Initialize Google Place API (ensure you replace YOUR_API_KEY with your actual API key)
    googlePlace = GooglePlace("AIzaSyDZTD9rMwvZyxlrz4Gd0UG-2UR7zfZO1U4");
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _searchLocation(String input) async {
    if (input.isNotEmpty) {
      final response = await googlePlace.autocomplete.get(input);
      setState(() {
        _predictions = response?.predictions ?? []; // Use null-aware operator
      });
    } else {
      setState(() {
        _predictions = [];
      });
    }
  }

  Future<void> _selectLocation(String placeId) async {
    final details = await googlePlace.details.get(placeId);
    final location = details!.result!.geometry?.location;
    if (location != null) {
      final latLng = LatLng(location.lat!, location.lng!);
      widget.onLocationSelected(latLng); // Pass the selected location back
      Navigator.pop(context); // Close the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick a Location"),
      ),
      body: Column(
        children: [
          LocationSearchBar(
            onSearch: _searchLocation,
            predictions: _predictions,
            onPredictionSelected: _selectLocation,
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-23.5557714, -46.6395571), // Initial position
                zoom: 12,
              ),
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}
