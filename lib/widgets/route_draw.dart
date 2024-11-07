import 'package:calendar/env/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:calendar/widgets/zoom_controls.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    final String? apiKey = Env.opsKey; // OpenRouteService key

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

    final routeUrl =
        'https://api.openrouteservice.org/v2/directions/$mode?api_key=$apiKey&start=${widget.currentLocation.longitude},${widget.currentLocation.latitude}&end=${widget.destination.longitude},${widget.destination.latitude}';

    // HERE Traffic API URL
    String your_api_key = "JExNxMop8Ape0rFQ54bzD_FUSih2_QKSGuM3cNT-m2k";

    final trafficUrl =
        'https://traffic.ls.hereapi.com/traffic/6.2/flow.json?apiKey=${your_api_key}&bbox=${widget.currentLocation.latitude},${widget.currentLocation.longitude},${widget.destination.latitude},${widget.destination.longitude}'; //traffic.ls.hereapi.com/traffic/6.2/flow.json?apiKey=JExNxMop8Ape0rFQ54bzD_FUSih2_QKSGuM3cNT-m2k&bbox=${widget.currentLocation.latitude},${widget.currentLocation.longitude},${widget.destination.latitude},${widget.destination.longitude}';
    print("traffic url----------");
    print(trafficUrl);
    try {
      // Request route data
      final routeResponse = await http.get(
        Uri.parse(routeUrl),
        headers: {
          'Accept':
              'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
        },
      );

      if (routeResponse.statusCode == 200) {
        final routeData = json.decode(routeResponse.body);
        if (routeData['features'] != null && routeData['features'].isNotEmpty) {
          final coordinates =
              (routeData['features'][0]['geometry']['coordinates'] as List)
                  .map((coord) => LatLng(coord[1], coord[0]))
                  .toList();

          setState(() {
            routePoints = coordinates;
          });
        }
      } else {
        print('Failed to fetch route data: ${routeResponse.statusCode}');
      }

      // Request traffic data from HERE API
      final trafficResponse = await http.get(Uri.parse(trafficUrl));
      if (trafficResponse.statusCode == 200) {
        final trafficData = json.decode(trafficResponse.body);
        print('Traffic Data: $trafficData');

        // Procesăm datele de trafic pentru a vizualiza aglomerația, dacă este necesar
        if (trafficData['flow'] != null) {
          // Puteți să utilizați datele de trafic pentru a vizualiza congestia pe traseu
          // De exemplu, actualizează traseul sau colorează traseul pe baza condițiilor de trafic
        }
      } else {
        print('Failed to fetch traffic data: ${trafficResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching route or traffic data: $e');
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
                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', // Use OpenStreetMap tiles
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
