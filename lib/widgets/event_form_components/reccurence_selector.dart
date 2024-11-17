import 'package:calendar/utils/colors.dart';
import 'package:calendar/widgets/event_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecurrenceSelector extends StatefulWidget {
  final RecurrenceType recurrenceType;
  final DateTime? recurrenceEndDate;
  final ValueChanged<RecurrenceType?> onRecurrenceChanged;
  final ValueChanged<DateTime?> onEndDateChanged;

  const RecurrenceSelector({
    Key? key,
    required this.recurrenceType,
    required this.recurrenceEndDate,
    required this.onRecurrenceChanged,
    required this.onEndDateChanged,
  }) : super(key: key);

  @override
  _RecurrenceSelectorState createState() => _RecurrenceSelectorState();
}

class _RecurrenceSelectorState extends State<RecurrenceSelector> {
  Future<void> _selectRecurrenceEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.recurrenceEndDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      widget.onEndDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Aliniere la stânga pentru tot
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: 100), // Poți ajusta această lățime
              child: Text(
                'Select event recurrence: ', // Text explicativ
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600], // Gri pentru text explicativ
                ),
                softWrap: true, // Permite împărțirea textului pe două linii
              ),
            ),
            const SizedBox(width: 0), // Spațiu între text și dropdown
            Flexible(
              flex: 2,
              child: DropdownButtonFormField<RecurrenceType>(
                value: widget.recurrenceType,
                onChanged: widget.onRecurrenceChanged,
                items: RecurrenceType.values.map((RecurrenceType recurrence) {
                  return DropdownMenuItem<RecurrenceType>(
                    value: recurrence,
                    child: Text(
                      recurrence
                          .toString()
                          .split('.')
                          .last
                          .replaceAll('_', ' ')
                          .toUpperCase(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20), // Spațiu între dropdown și buton
        if (widget.recurrenceType != RecurrenceType.none)
          Center(
            child: ElevatedButton(
              onPressed: () => _selectRecurrenceEndDate(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.textColor, // Culoarea textului
                backgroundColor:
                    AppColors.primaryColor, // Culoarea fundalului (mov)
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10), // Fără colțuri rotunjite
                ),
              ),
              child: Text(
                widget.recurrenceEndDate == null
                    ? 'Select Recurrence End Date'
                    : 'Recurrence set to: ${DateFormat('dd MMM yyyy').format(widget.recurrenceEndDate!)}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
      ],
    );
  }
}
