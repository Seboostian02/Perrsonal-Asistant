import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';

class LocationSearchBar extends StatelessWidget {
  final Function(String) onSearch;
  final List<AutocompletePrediction> predictions;
  final Function(String) onPredictionSelected;

  LocationSearchBar({
    required this.onSearch,
    required this.predictions,
    required this.onPredictionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: (value) => onSearch(value),
          decoration: InputDecoration(
            hintText: "Search location",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        ...predictions.map(
          (p) => ListTile(
            title: Text(p.description ?? ''),
            onTap: () => onPredictionSelected(p.placeId!),
          ),
        ),
      ],
    );
  }
}
