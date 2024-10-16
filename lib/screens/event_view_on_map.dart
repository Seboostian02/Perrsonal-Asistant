import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:geocoding/geocoding.dart';

class EventView extends StatefulWidget {
  final List<calendar.Event> events;

  const EventView({Key? key, required this.events}) : super(key: key);

  @override
  _EventViewState createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  late GoogleMapController _controller;
  final Set<Marker> _markers = {};

  static const LatLng _initialPosition = LatLng(45.521563, -122.677433);

  @override
  void initState() {
    super.initState();
    _setMarkers();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  Future<void> _setMarkers() async {
    for (var event in widget.events) {
      print("events-------------------");
      print(event);
      if (event.location != null && event.location!.isNotEmpty) {
        try {
          List<Location> locations = await locationFromAddress(event.location!);
          if (locations.isNotEmpty) {
            final latLng =
                LatLng(locations[0].latitude, locations[0].longitude);
            _markers.add(
              Marker(
                markerId: MarkerId(event.id!),
                position: latLng,
                infoWindow: InfoWindow(
                  title: event.summary,
                  snippet: event.description ?? '',
                ),
              ),
            );
          }
        } catch (e) {
          print("Error retrieving location for event ${event.summary}: $e");
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _initialPosition,
        zoom: 10.0,
      ),
      markers: _markers,
    );
  }
}
