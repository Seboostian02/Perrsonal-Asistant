import 'package:flutter/material.dart';

class PrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final ValueChanged<String?> onPriorityChanged;

  PrioritySelector({
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8), // Spațiu între text și dropdown
          Text(
            'Prioritate eveniment', // Textul care explică dropdown-ul
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600], // Culoare gri pentru text explicativ
            ),
          ),
          Container(
            width: 100, // Ajustează lățimea după cum este necesar
            child: DropdownButton<String>(
              isExpanded: true, // Asigură că dropdown-ul va ocupa toată lățimea
              value: selectedPriority,
              onChanged: onPriorityChanged,
              items: <String>['Low', 'Medium', 'High']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                        fontSize:
                            16), // Ajustează dimensiunea fontului dacă este necesar
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
