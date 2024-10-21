import 'dart:convert';
import 'package:calendar/widgets/route_draw.dart';
import 'package:http/http.dart' as http;

import 'package:calendar/widgets/event_card.dart';
import 'package:calendar/widgets/zoom_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

import 'package:geocoding/geocoding.dart';

import 'package:geolocator/geolocator.dart';

class EventView extends StatefulWidget {
  final List<calendar.Event> events;
  final bool showBackArrow;
  final bool showCurrLocation;

  const EventView(
      {Key? key,
      required this.events,
      this.showBackArrow = false,
      this.showCurrLocation = false})
      : super(key: key);

  @override
  EventViewState createState() => EventViewState();
}

class EventViewState extends State<EventView> {
  final List<Marker> _markers = [];
  final MapController _mapController = MapController();
  calendar.Event? _selectedEvent;
  LatLng? _selectedEventLatLng;
  LatLng? _currentLocationLatLng;

  static LatLng _initialPosition = LatLng(47.1585, 27.6014);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _setMarkers();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Serviciul de locație este dezactivat.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permisiunea de locație a fost refuzată.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Permisiunea de locație este permanent refuzată, nu se poate solicita.');
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocationLatLng = LatLng(position.latitude, position.longitude);

      _markers.removeWhere((marker) => marker.point == _currentLocationLatLng);
      _markers.add(
        Marker(
          point: _currentLocationLatLng!,
          builder: (context) => const Icon(
            Icons.my_location,
            color: Colors.blue,
            size: 40.0,
          ),
          anchorPos: AnchorPos.align(AnchorAlign.top),
        ),
      );

      if (widget.events.length > 1) {
        _mapController.move(_currentLocationLatLng!, 15.0);
      }
    });
  }

  Future<void> _setMarkers() async {
    _markers.clear();

    Position position = await Geolocator.getCurrentPosition();
    _currentLocationLatLng = LatLng(position.latitude, position.longitude);
    _markers.add(
      Marker(
        point: _currentLocationLatLng!,
        builder: (context) => const Icon(
          Icons.my_location,
          color: Colors.blue,
          size: 40.0,
        ),
        anchorPos: AnchorPos.align(AnchorAlign.top),
      ),
    );

    for (var event in widget.events) {
      if (event.location != null && event.location!.isNotEmpty) {
        try {
          List<Location> locations = await locationFromAddress(event.location!);
          if (locations.isNotEmpty) {
            final latLng =
                LatLng(locations[0].latitude, locations[0].longitude);
            _markers.add(
              Marker(
                point: latLng,
                builder: (context) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedEvent = event;
                      _selectedEventLatLng = latLng;
                    });
                  },
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40.0,
                  ),
                ),
                anchorPos: AnchorPos.align(AnchorAlign.top),
              ),
            );

            if (widget.events.length == 1) {
              _mapController.move(latLng, 15.0);
            }
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

  calendar.Event createNonNullEvent(calendar.Event? event) {
    return calendar.Event(
      summary: event?.summary ?? "Default Title",
      location: event?.location ?? "Default Location",
      description: event?.description ?? "Default Description",
      start: event?.start ?? calendar.EventDateTime(dateTime: DateTime.now()),
      end: event?.end ??
          calendar.EventDateTime(
              dateTime: DateTime.now().add(const Duration(hours: 1))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: _selectedEvent != null,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _currentLocationLatLng ?? _initialPosition,
                  zoom: 10.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(markers: _markers),
                ],
              ),
              ZoomControls(mapController: _mapController),
            ],
          ),
        ),
        if (widget.showCurrLocation)
          Positioned(
            top: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              child: const Icon(Icons.my_location),
            ),
          ),
        if (widget.showBackArrow)
          Positioned(
            top: 50,
            left: 20,
            child: Material(
              elevation: 6,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        if (_selectedEventLatLng != null)
          RouteDrawer(
            currentLocation: _currentLocationLatLng!,
            destination: _selectedEventLatLng!,
          ),
      ],
    );
  }
}
