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
  bool isTrafficLayerVisible = false;
  List<Marker> incidentMarkers = [];
  List<Polyline> trafficFlowPolylines = [];

  final Map<String, String> transportModes = {
    'Walking': 'pedestrian',
    'Bike': 'bicycle',
    'Driving': 'car'
  };

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _fetchRoute();
    _fetchTrafficIncidents();
    _fetchTrafficFlow();
  }

  Future<void> _fetchRoute() async {
    final String? apiKey = Env.tomTomKey;
    final mode = transportModes[selectedTransportMode] ?? 'car';

    if (widget.currentLocation == widget.destination) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Start and destination points are the same!')),
      );
      return;
    }

    final url = 'https://api.tomtom.com/routing/1/calculateRoute/'
        '${widget.currentLocation.latitude},${widget.currentLocation.longitude}:'
        '${widget.destination.latitude},${widget.destination.longitude}/json?'
        'travelMode=$mode&traffic=true&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates = data['routes'][0]['legs'][0]['points'];

        setState(() {
          routePoints = coordinates
              .map<LatLng>(
                  (point) => LatLng(point['latitude'], point['longitude']))
              .toList();
          isTrafficLayerVisible = (mode == 'car');
        });
      } else {
        print('Failed to fetch route: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  Future<void> _fetchTrafficIncidents() async {
    final String? apiKey = Env.tomTomKey;

    final String bbox =
        '4.8854592519716675,52.36934334773164,4.897883244144765,52.37496348620152';
    final String fields =
        '{incidents{type,geometry{type,coordinates},properties{iconCategory}}}';

    final url =
        'https://api.tomtom.com/traffic/services/5/incidentDetails?key=$apiKey&bbox=$bbox&fields=$fields&language=en-GB&t=1111&timeValidityFilter=present';
    print("url--------");
    print(url);
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<Marker> markers = [];
        for (var incident in data['incidents']) {
          final coordinates = incident['geometry']['coordinates'];

          if (coordinates is List && coordinates.isNotEmpty) {
            final incidentLon = coordinates[0][0];
            final incidentLat = coordinates[0][1];

            markers.add(Marker(
              point: LatLng(incidentLat, incidentLon),
              builder: (context) =>
                  Icon(Icons.warning, color: Colors.red, size: 40.0),
            ));
          }
        }

        setState(() {
          incidentMarkers = markers;
        });
      } else {
        print('Failed to fetch traffic incidents: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching incidents: $e');
    }
  }

  Future<void> _fetchTrafficFlow() async {
    final String? apiKey = Env.tomTomKey;

    // Bounding box for the area of interest (you can adjust this dynamically)
    final String bbox =
        '4.8854592519716675,52.36934334773164,4.897883244144765,52.37496348620152';

    // Fetching traffic flow tiles as polylines
    final url =
        'https://api.tomtom.com/traffic/services/5/trafficFlowTiles?key=$apiKey&bbox=$bbox';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<Polyline> trafficPolylines = [];
        for (var flow in data['flowData']) {
          final coordinates = flow['geometry']['coordinates'];

          // Converting coordinates to LatLng
          List<LatLng> flowPoints = coordinates
              .map<LatLng>((point) =>
                  LatLng(point[1], point[0])) // reverse lat/lng order
              .toList();

          trafficPolylines.add(Polyline(
            points: flowPoints,
            strokeWidth: 3.0,
            color: Colors.orange,
          ));
        }

        setState(() {
          trafficFlowPolylines = trafficPolylines;
        });
      } else {
        print('Failed to fetch traffic flow: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching traffic flow: $e');
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
                  'https://api.tomtom.com/map/1/tile/basic/main/{z}/{x}/{y}.png?key=${Env.tomTomKey}',
              subdomains: ['a', 'b', 'c'],
            ),
            if (isTrafficLayerVisible)
              TileLayer(
                urlTemplate:
                    'https://api.tomtom.com/traffic/map/4/tile/flow/relative0/{z}/{x}/{y}.png?key=${Env.tomTomKey}',
              ),
            MarkerLayer(
              markers: [
                Marker(
                  point: widget.currentLocation,
                  builder: (context) => const Icon(Icons.my_location,
                      color: Colors.blue, size: 40.0),
                ),
                Marker(
                  point: widget.destination,
                  builder: (context) => const Icon(Icons.location_on,
                      color: Colors.red, size: 40.0),
                ),
              ]..addAll(incidentMarkers),
            ),
            PolylineLayer(
              polylines: _generateRoutes() +
                  trafficFlowPolylines, // Adding traffic flow polylines
            ),
          ],
        ),
        ZoomControls(mapController: mapController),
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
                      value: value, child: Text(value));
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
      ],
    );
  }
}
