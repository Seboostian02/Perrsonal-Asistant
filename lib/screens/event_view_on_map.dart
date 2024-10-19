import 'package:calendar/widgets/zoom_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:geocoding/geocoding.dart';

class EventView extends StatefulWidget {
  final List<calendar.Event> events;

  const EventView({super.key, required this.events});

  @override
  EventViewState createState() => EventViewState();
}

class EventViewState extends State<EventView> {
  final List<Marker> _markers = [];
  final MapController _mapController = MapController();

  static LatLng _initialPosition = LatLng(47.1585, 27.6014);

  @override
  void initState() {
    super.initState();
    _setMarkers();
  }

  Future<void> _setMarkers() async {
    _markers.clear();
    for (var event in widget.events) {
      if (event.location != null && event.location!.isNotEmpty) {
        try {
          List<Location> locations = await locationFromAddress(event.location!);
          if (locations.isNotEmpty) {
            final latLng =
                LatLng(locations[0].latitude, locations[0].longitude);
            setState(() {
              _markers.add(
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
            });
          }
        } catch (e) {
          print("Error retrieving location for event ${event.summary}: $e");
        }
      }
    }
    setState(() {});
  }

  Future<void> setMarkers(List<calendar.Event> events) async {
    widget.events.clear();
    widget.events.addAll(events);

    await _setMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _initialPosition,
            zoom: 10.0,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(markers: _markers),
          ],
        ),
        ZoomControls(mapController: _mapController),
      ],
    );
  }
}
