import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:calendar/env/env.dart';
import 'package:calendar/widgets/zoom_controls.dart';

class RouteDrawer extends StatefulWidget {
  final LatLng currentLocation;
  final LatLng destination;

  RouteDrawer({
    Key? key,
    required this.currentLocation,
    required this.destination,
  }) : super(key: key);

  @override
  _RouteDrawerState createState() => _RouteDrawerState();
}

class _RouteDrawerState extends State<RouteDrawer> {
  late MapController mapController;
  String selectedTransportMode = 'Driving';
  List<LatLng> routePoints = [];

  final Map<String, String> transportModes = {
    'Foot': 'foot-walking',
    'Bike': 'cycling-regular',
    'Driving': 'driving-hgv',
  };

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    final String? apiKey = Env.opsKey;

    if (widget.currentLocation.latitude == widget.destination.latitude &&
        widget.currentLocation.longitude == widget.destination.longitude) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Punctele de start și destinație sunt identice!'),
        ),
      );
      return;
    }

    final mode = transportModes[selectedTransportMode];

    final url =
        'https://api.openrouteservice.org/v2/directions/$mode?api_key=$apiKey&start=${widget.currentLocation.longitude},${widget.currentLocation.latitude}&end=${widget.destination.longitude},${widget.destination.latitude}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept':
              'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['features'] != null && data['features'].isNotEmpty) {
          final steps =
              data['features'][0]['properties']['segments'][0]['steps'];

          List<int> waypoints = [];
          for (var step in steps) {
            if (step['way_points'] != null) {
              waypoints.addAll(List<int>.from(step['way_points']));
            }
          }

          setState(() {
            routePoints =
                (data['features'][0]['geometry']['coordinates'] as List)
                    .map((coord) => LatLng(coord[1], coord[0]))
                    .toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  List<Polyline> _generateRoutes() {
    return [
      Polyline(
        points: routePoints,
        strokeWidth: 4.0,
        color: Colors.blue,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            center: widget.currentLocation,
            zoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://api.tomtom.com/map/tiles/road/maps?key=${Env.tomTomKey}&tileSize=256&zoom={z}&x={x}&y={y}',
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: widget.currentLocation,
                  builder: (context) => const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 40.0,
                  ),
                ),
                Marker(
                  point: widget.destination,
                  builder: (context) => const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40.0,
                  ),
                ),
              ],
            ),
            PolylineLayer(
              polylines: _generateRoutes(),
            ),
          ],
        ),
        ZoomControls(mapController: mapController),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: DropdownButton<String>(
                value: selectedTransportMode,
                underline: Container(),
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                items: transportModes.keys
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedTransportMode = newValue;
                      _fetchRoute();
                    });
                  }
                },
              ),
            ),
          ),
        ),
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
      ],
    );
  }
}
