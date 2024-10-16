import 'package:calendar/screens/location_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSelector extends StatelessWidget {
  final LatLng? selectedLocation;
  final Function(LatLng) onLocationSelected;

  const LocationSelector({
    Key? key,
    required this.selectedLocation,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final selectedLocation = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationPickerPage(
              onLocationSelected: onLocationSelected,
            ),
          ),
        );

        if (selectedLocation != null) {
          onLocationSelected(selectedLocation);
        }
      },
      child: Text(
        selectedLocation != null
            ? 'Selected Location: (${selectedLocation!.latitude}, ${selectedLocation!.longitude})'
            : 'Select Location',
      ),
    );
  }
}
