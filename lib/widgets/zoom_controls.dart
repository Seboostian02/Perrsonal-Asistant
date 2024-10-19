import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class ZoomControls extends StatelessWidget {
  final MapController mapController;

  const ZoomControls({
    super.key,
    required this.mapController,
  });

  void _zoomIn() {
    mapController.move(mapController.center, mapController.zoom + 1);
  }

  void _zoomOut() {
    mapController.move(mapController.center, mapController.zoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      right: 20,
      child: Column(
        children: [
          FloatingActionButton(
            onPressed: _zoomIn,
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _zoomOut,
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
