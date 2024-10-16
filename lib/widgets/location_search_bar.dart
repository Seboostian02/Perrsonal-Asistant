import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';

class LocationSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final List<AutocompletePrediction> predictions;
  final Function(String) onPredictionSelected;

  const LocationSearchBar({
    Key? key,
    required this.controller,
    required this.onSearch,
    required this.predictions,
    required this.onPredictionSelected,
  }) : super(key: key);

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
            onChanged: (text) {
              onSearch(text);
              print("---------------------");
              print(
                  'Predictions: ${predictions.map((p) => p.description).toList()}');
            },
          ),
        ),
        if (predictions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 5),
            color: Colors.white,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                final prediction = predictions[index];
                return ListTile(
                  title: Text(prediction.description ?? ''),
                  onTap: () {
                    onPredictionSelected(prediction.placeId!);
                    controller.clear();
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
