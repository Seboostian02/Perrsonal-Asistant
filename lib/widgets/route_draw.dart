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

  final Map<String, String> transportModes = {
    'Pedestrian': 'pedestrian',
    'Bike': 'bicycle',
    'Driving': 'car'
  };

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _fetchRoute();
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
          isTrafficLayerVisible =
              (mode == 'car'); // Show traffic for driving only
        });
      } else {
        print('Failed to fetch route: ${response.statusCode}');
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

  String createMapUrl() {
    String baseURL = 'https://api.tomtom.com';
    String versionNumber = '1';
    String resourceVersion = '20.3.4-6'; // Alege versiunea dorită
    String mapStyle = 'basic_main'; // Stilul hărții
    String trafficIncidentStyle = 'incidents_day'; // Stilul incidentelor
    String trafficFlowStyle = 'flow_absolute'; // Stilul fluxului de trafic
    String poiStyle = 'poi_main'; // Stilul punctelor de interes (POI)
    print(
        "$baseURL/style/$versionNumber/style/$resourceVersion?key=${Env.tomTomKey}&map=$mapStyle&traffic_incidents=$trafficIncidentStyle&traffic_flow=$trafficFlowStyle&poi=$poiStyle");
    return '$baseURL/style/$versionNumber/style/$resourceVersion?key=${Env.tomTomKey}&map=$mapStyle&traffic_incidents=$trafficIncidentStyle&traffic_flow=$trafficFlowStyle&poi=$poiStyle';
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
            // Base map layer
            TileLayer(
              urlTemplate:
                  'https://api.tomtom.com/map/1/tile/basic/main/{z}/{x}/{y}.png?key=${Env.tomTomKey}',
              subdomains: ['a', 'b', 'c'],
              // Poți încerca un alt provider de tile-uri
            ),
            TileLayer(
              urlTemplate:
                  'https://api.tomtom.com/traffic/map/4/tile/flow/relative0/{z}/{x}/{y}.png?key=${Env.tomTomKey}',
              subdomains: ['a', 'b', 'c'],
              // tileProvider: NonCachingNetworkTileProvider(),
            ),
            // Traffic overlay layer with higher zoom and transparency
            // if (isTrafficLayerVisible)
            //   ColorFiltered(
            //     colorFilter: ColorFilter.mode(
            //       Colors.black.withOpacity(0.1), // Adjust opacity here
            //       BlendMode.srcATop,
            //     ),
            //     child: TileLayer(
            //       urlTemplate:
            //           'https://api.tomtom.com/traffic/map/4/tile/flow/relative0/{z}/{x}/{y}.png?key=${Env.tomTomKey}',
            //     ),
            //   ),
            // Marker for current location and destination
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
            // Route line
            PolylineLayer(
              polylines: _generateRoutes(),
            ),
          ],
        ),
        // Zoom controls
        ZoomControls(mapController: mapController),
        // Back button
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
        // Dropdown for selecting travel mode
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
      ],
    );
  }
}
