import 'package:calendar/widgets/event_card.dart';
import 'package:calendar/widgets/zoom_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:geocoding/geocoding.dart';

class EventView extends StatefulWidget {
  final List<calendar.Event> events;
  final bool showBackArrow;

  const EventView({Key? key, required this.events, this.showBackArrow = false})
      : super(key: key);

  @override
  EventViewState createState() => EventViewState();
}

class EventViewState extends State<EventView> {
  final List<Marker> _markers = [];
  final MapController _mapController = MapController();
  calendar.Event? _selectedEvent;
  LatLng? _selectedEventLatLng;

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

  calendar.Event createNonNullEvent(calendar.Event? event) {
    return calendar.Event(
      summary: event?.summary ?? "Default Title",
      location: event?.location ?? "Default Location",
      description: event?.description ?? "Default Description",
      start: event?.start ?? calendar.EventDateTime(dateTime: DateTime.now()),
      end: event?.end ??
          calendar.EventDateTime(
              dateTime: DateTime.now().add(Duration(hours: 1))),
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
                  center: _initialPosition,
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
        if (widget.showBackArrow)
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
              onPressed: () {
                print("popped");

                Navigator.of(context).pop();
              },
            ),
          ),
        if (_selectedEvent != null && _selectedEventLatLng != null)
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 150,
            top: MediaQuery.of(context).size.height / 2 - 200,
            child: Stack(
              children: [
                EventCard(
                  event: createNonNullEvent(_selectedEvent),
                  showLocation: false,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedEvent = null;
                        _selectedEventLatLng = null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
