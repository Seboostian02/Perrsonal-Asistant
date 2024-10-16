import 'package:calendar/widgets/location_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:flutter_config/flutter_config.dart';

class LocationPickerPage extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  const LocationPickerPage({super.key, required this.onLocationSelected});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  late GooglePlace _googlePlace;
  late GoogleMapController _mapController;
  LatLng? _selectedLocation;
  List<AutocompletePrediction> _predictions = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeGooglePlace();
  }

  Future<void> _initializeGooglePlace() async {
    await FlutterConfig.loadEnvVariables();
    String apiKey = FlutterConfig.get('GMS_API_KEY');
    setState(() {
      _googlePlace = GooglePlace(apiKey);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _selectLocation(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    widget.onLocationSelected(location);
  }

  void _searchPlace(String input) async {
    final result = await _googlePlace.autocomplete.get(input);
    setState(() {
      _predictions = result?.predictions ?? [];
    });
  }

  void _selectPrediction(String placeId) async {
    final details = await _googlePlace.details.get(placeId);
    if (details != null && details.result != null) {
      final lat = details.result!.geometry!.location!.lat;
      final lng = details.result!.geometry!.location!.lng;
      final newLocation = LatLng(lat!, lng!);

      _mapController.animateCamera(CameraUpdate.newLatLngZoom(newLocation, 15));
      _selectLocation(newLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pick a Location',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _selectedLocation ?? const LatLng(45.0, 25.0),
              zoom: 5,
            ),
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected-location'),
                      position: _selectedLocation!,
                    ),
                  }
                : {},
            onTap: _selectLocation,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 15,
            right: 15,
            child: LocationSearchBar(
              controller: _searchController,
              onSearch: _searchPlace,
              predictions: _predictions,
              onPredictionSelected: _selectPrediction,
            ),
          ),
          if (_selectedLocation != null)
            Positioned(
              bottom: 20,
              left: MediaQuery.of(context).size.width * 0.3,
              right: MediaQuery.of(context).size.width * 0.3,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onLocationSelected(_selectedLocation!);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Choose this location"),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
