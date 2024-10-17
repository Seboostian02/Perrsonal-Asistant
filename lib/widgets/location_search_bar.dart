import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class LocationSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final List<Location> predictions;
  final Function(int) onPredictionSelected;

  const LocationSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.predictions,
    required this.onPredictionSelected,
  });

  Future<String> _getPlaceName(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        return placemarks.first.name ?? 'Unknown location';
      }
    } catch (e) {
      print('Error getting place name: $e');
    }
    return 'Unknown location';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Search location...',
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
            ),
            onChanged: (text) => onSearch(text),
          ),
        ),
        if (predictions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 5),
            color: Colors.white,
            child: FutureBuilder<List<String>>(
              future: Future.wait(predictions.map((prediction) async {
                return await _getPlaceName(
                    prediction.latitude, prediction.longitude);
              })),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final names = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: names.length,
                    itemBuilder: (context, index) {
                      final name = names[index];
                      return ListTile(
                        title: Text(name),
                        onTap: () {
                          onPredictionSelected(index);
                          controller.clear();
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
      ],
    );
  }
}
