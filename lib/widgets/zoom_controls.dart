import 'package:calendar/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class ZoomControls extends StatelessWidget {
  final MapController mapController;

  const ZoomControls({
    super.key,
    required this.mapController,
  });

  void _zoomIn() {
    if (mapController.zoom < 18) {
      mapController.move(mapController.center, mapController.zoom + 1);
    }
  }

  void _zoomOut() {
    mapController.move(mapController.center, mapController.zoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 160,
      right: 20,
      child: Column(
        children: [
          FloatingActionButton(
            onPressed: _zoomIn,
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.iconColor,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _zoomOut,
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.iconColor,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
