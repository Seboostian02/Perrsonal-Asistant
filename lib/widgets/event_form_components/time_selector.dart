import 'package:TimeBuddy/utils/colors.dart';
import 'package:flutter/material.dart';

class TimeSelector extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Function(BuildContext, bool) onTimeSelected;

  const TimeSelector({
    Key? key,
    required this.startTime,
    required this.endTime,
    required this.onTimeSelected,
  }) : super(key: key);

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: InkWell(
            onTap: () => onTimeSelected(context, true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Text(
                    'Oră începere',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.secondaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(startTime),
                    style: const TextStyle(
                      fontSize: 28,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () => onTimeSelected(context, false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Text(
                    'Oră terminare',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.secondaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(endTime),
                    style: const TextStyle(
                      fontSize: 28,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
