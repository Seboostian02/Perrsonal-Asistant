import 'package:TimeBuddy/screens/location_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSelector extends StatelessWidget {
  final LatLng? selectedLocation;
  final Function(LatLng) onLocationSelected;

  const LocationSelector({
    super.key,
    required this.selectedLocation,
    required this.onLocationSelected,
    required String selectedLocationName,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final selectedLocation = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationPickerPage(
              onLocationSelected: (location, placeName) {
                final googleLatLng =
                    LatLng(location.latitude, location.longitude);
                onLocationSelected(googleLatLng);
              },
            ),
          ),
        );

        if (selectedLocation != null) {
          onLocationSelected(selectedLocation);
        }
      },
      child: Text(
        selectedLocation != null ? 'Location Selected' : 'Select Location',
      ),
    );
  }
}
