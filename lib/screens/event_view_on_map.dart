import 'package:TimeBuddy/utils/colors.dart';
import 'package:TimeBuddy/widgets/route_draw.dart';

import 'package:TimeBuddy/widgets/event_card.dart';
import 'package:TimeBuddy/widgets/zoom_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:TimeBuddy/services/event_service.dart';
import 'package:TimeBuddy/services/location_service.dart';
import 'package:TimeBuddy/env/env.dart';

class EventView extends StatefulWidget {
  final List<calendar.Event> events;
  final bool showBackArrow;
  final bool showCurrLocation;
  final bool showRoute;

  const EventView(
      {Key? key,
      required this.events,
      this.showBackArrow = false,
      this.showCurrLocation = false,
      required this.showRoute})
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

  void _showEventCardDialog(BuildContext context, calendar.Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: EventCard(
                    event: event,
                    showLocation: false,
                    expandMode: true,
                  ),
                ),
                // Positioned(
                //   top: 30,
                //   right: 10,
                //   child: IconButton(
                //     icon: const Icon(Icons.close),
                //     onPressed: () {
                //       Navigator.of(context).pop();
                //     },
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Obține locația curentă
      Position position = await LocationService().getCurrentLocation();

      if (position != null) {
        setState(() {
          // Setează coordonatele locației curente
          _currentLocationLatLng =
              LatLng(position.latitude, position.longitude);

          // Actualizează markerul pentru locația curentă
          _markers
              .removeWhere((marker) => marker.point == _currentLocationLatLng);
          _markers.add(
            Marker(
              point: _currentLocationLatLng!,
              builder: (context) => const Icon(
                Icons.my_location,
                color: AppColors.primaryColor,
                size: 40.0,
              ),
              anchorPos: AnchorPos.align(AnchorAlign.top),
            ),
          );

          // Mișcă harta la locația curentă dacă sunt mai multe evenimente
          if (widget.events.length > 1) {
            _mapController.move(_currentLocationLatLng!, 15.0);
          } else {
            // Mișcă harta doar către locația curentă dacă sunt doar evenimente unice
            _mapController.move(_currentLocationLatLng!, 15.0);
          }
        });
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
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
          color: AppColors.primaryColor,
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
                    // Apel direct la _showEventCardDialog
                    _showEventCardDialog(context, event);
                  },
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.locationMarkerColor,
                    size: 40.0,
                  ),
                ),
                anchorPos: AnchorPos.align(AnchorAlign.top),
              ),
            );

            if (widget.events.length == 1 && widget.showRoute == true) {
              _selectedEventLatLng = latLng;
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
                        'https://api.tomtom.com/map/1/tile/basic/main/{z}/{x}/{y}.png?key=${Env.tomTomKey}',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(markers: _markers),
                ],
              ),
              ZoomControls(mapController: _mapController),
            ],
          ),
        ),
        if (widget.showRoute && _selectedEventLatLng != null)
          RouteDrawer(
            currentLocation: _currentLocationLatLng!,
            destination: _selectedEventLatLng!,
          ),
      ],
    );
  }
}
