import 'package:calendar/widgets/location_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class LocationPickerPage extends StatefulWidget {
  final Function(LatLng, String) onLocationSelected;

  const LocationPickerPage({super.key, required this.onLocationSelected});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  LatLng? _selectedLocation;
  List<Location> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  void _selectLocation(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  Future<void> _searchPlace(String input) async {
    try {
      final locations = await locationFromAddress(input);
      setState(() {
        _searchResults = locations;
      });
    } catch (e) {
      print('Error finding location: $e');
    }
  }

  void _selectPrediction(Location location) async {
    final latLng = LatLng(location.latitude, location.longitude);
    _mapController.move(latLng, 15.0);
    _selectLocation(latLng);

    String placeName =
        await _getPlaceName(location.latitude, location.longitude);

    widget.onLocationSelected(latLng, placeName);
  }

  Future<String> _getPlaceName(double latitude, double longitude) async {
    String address = '';
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        address =
            '${placemarks.first.name}, ${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.country}';
      }
    } catch (e) {
      print('Error getting place name: $e');
    }
    return address.isNotEmpty ? address : 'Unknown location';
  }

  void _zoomIn() {
    _mapController.move(_mapController.center, _mapController.zoom + 1);
  }

  void _zoomOut() {
    _mapController.move(_mapController.center, _mapController.zoom - 1);
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _selectedLocation ?? LatLng(45.0, 25.0),
              zoom: 5,
              onTap: (_, latLng) => _selectLocation(latLng),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: _selectedLocation != null
                    ? [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: _selectedLocation!,
                          builder: (ctx) =>
                              const Icon(Icons.location_pin, color: Colors.red),
                        ),
                      ]
                    : [],
              ),
            ],
          ),
          Positioned(
            top: 20,
            left: 15,
            right: 15,
            child: LocationSearchBar(
              controller: _searchController,
              onSearch: _searchPlace,
              predictions: _searchResults,
              onPredictionSelected: (index) =>
                  _selectPrediction(_searchResults[index]),
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
                    // Obține numele locației pentru a-l trimite înapoi
                    _getPlaceName(_selectedLocation!.latitude,
                            _selectedLocation!.longitude)
                        .then((placeName) {
                      widget.onLocationSelected(_selectedLocation!, placeName);
                      Navigator.pop(context);
                    });
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
          Positioned(
            bottom: 80,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _zoomIn,
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _zoomOut,
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
