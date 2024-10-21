import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:calendar/services/location_service.dart';

import 'package:geocoding/geocoding.dart';

class MapService {
  final LocationService _locationService = LocationService();

  Future<List<Marker>> createMarkers(
      List<calendar.Event> events, LatLng currentLocation) async {
    List<Marker> markers = [];

    markers.add(
      Marker(
        point: currentLocation,
        builder: (context) => const Icon(
          Icons.my_location,
          color: Colors.blue,
          size: 40.0,
        ),
        anchorPos: AnchorPos.align(AnchorAlign.top),
      ),
    );

    for (var event in events) {
      if (event.location != null && event.location!.isNotEmpty) {
        List<Location> locations =
            await _locationService.getLocationFromAddress(event.location!);
        if (locations.isNotEmpty) {
          final latLng = LatLng(locations[0].latitude, locations[0].longitude);
          markers.add(
            Marker(
              point: latLng,
              builder: (context) => const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40.0,
              ),
              anchorPos: AnchorPos.align(AnchorAlign.top),
            ),
          );
        }
      }
    }

    return markers;
  }
}
