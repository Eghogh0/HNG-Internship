import 'package:flutter/material.dart';
import '../../models/recurrence.dart';

class RecurringInput extends StatefulWidget {
  final Function(Recurrence?) onRecurrenceSelected;
  
  const RecurringInput({super.key, required this.onRecurrenceSelected});

  @override
  State<RecurringInput> createState() => _RecurringInputState();
}

class _RecurringInputState extends State<RecurringInput> {
  bool _isRecurring = false;
  RecurrenceType _type = RecurrenceType.weekly;
  int _frequency = 1;
  final List<int> _selectedWeekdays = [DateTime.monday];
  final List<int> _selectedMonthDays = [1];
  DateTime _startDate = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Recurring Transaction'),
          value: _isRecurring,
          onChanged: (value) {
            setState(() => _isRecurring = value);
            widget.onRecurrenceSelected(value ? _buildRecurrence() : null);
          },
        ),
        if (_isRecurring) ...[
          DropdownButtonFormField<RecurrenceType>(
            initialValue: _type,
            items: RecurrenceType.values.map((type) {
              return DropdownMenuItem(value: type, child: Text(type.displayName));
            }).toList(),
            onChanged: (value) {
              setState(() => _type = value!);
              widget.onRecurrenceSelected(_buildRecurrence());
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _frequency.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Every (days/weeks/months)'),
                  onChanged: (val) {
                    _frequency = int.tryParse(val) ?? 1;
                    widget.onRecurrenceSelected(_buildRecurrence());
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_type == RecurrenceType.weekly
              ? [
                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (index) {
                      final day = index + 1; // Monday = 1
                      return FilterChip(
                        label: Text(_weekdayName(day)),
                        selected: _selectedWeekdays.contains(day),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedWeekdays.add(day);
                            } else {
                              _selectedWeekdays.remove(day);
                            }
                          });
                          widget.onRecurrenceSelected(_buildRecurrence());
                        },
                      );
                    }),
                  )
                ]
              : _type == RecurrenceType.monthly
                  ? [
                      Wrap(
                        spacing: 8,
                        children: List.generate(31, (index) {
                          final day = index + 1;
                          return FilterChip(
                            label: Text('$day'),
                            selected: _selectedMonthDays.contains(day),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedMonthDays.add(day);
                                } else {
                                  _selectedMonthDays.remove(day);
                                }
                              });
                              widget.onRecurrenceSelected(_buildRecurrence());
                            },
                          );
                        }),
                      )
                    ]
                  : [const SizedBox.shrink()]),
          ListTile(
            title: const Text('Start Date'),
            subtitle: Text('${_startDate.year}-${_startDate.month}-${_startDate.day}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              );
              if (date != null) {
                setState(() => _startDate = date);
                widget.onRecurrenceSelected(_buildRecurrence());
              }
            },
          ),
        ],
      ],
    );
  }
  
  Recurrence _buildRecurrence() {
    return Recurrence(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type,
      frequency: _frequency,
      weekdays: _type == RecurrenceType.weekly ? _selectedWeekdays : null,
      monthDays: _type == RecurrenceType.monthly ? _selectedMonthDays : null,
      startDate: _startDate,
    );
  }
  
  String _weekdayName(int day) {
    switch (day) {
      case DateTime.monday: return 'Mon';
      case DateTime.tuesday: return 'Tue';
      case DateTime.wednesday: return 'Wed';
      case DateTime.thursday: return 'Thu';
      case DateTime.friday: return 'Fri';
      case DateTime.saturday: return 'Sat';
      case DateTime.sunday: return 'Sun';
      default: return '';
    }
  }
}