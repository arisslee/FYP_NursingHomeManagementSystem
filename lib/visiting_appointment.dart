import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class VisitingAppointmentPage extends StatefulWidget {
  @override
  _VisitingAppointmentPageState createState() =>
      _VisitingAppointmentPageState();
}

class _VisitingAppointmentPageState extends State<VisitingAppointmentPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  TimeOfDay _selectedTimeStart = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _selectedTimeEnd = TimeOfDay(hour: 0, minute: 0);
  ValueNotifier<List<Event>> _selectedEvents = ValueNotifier([]);

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: _selectedTimeStart,
    );

    if (startTime != null) {
      TimeOfDay? endTime = await showTimePicker(
        context: context,
        initialTime: _selectedTimeEnd,
      );

      if (endTime != null) {
        setState(() {
          _selectedTimeStart = startTime;
          _selectedTimeEnd = endTime;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              TableCalendar(
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible:
                      false, // This will remove the "2 weeks" label
                ),
                firstDay: DateTime.utc(2021, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return !day.isBefore(DateTime.now()) &&
                      isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  selectedTextStyle: TextStyle(color: Colors.white),
                  todayTextStyle: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  markersMaxCount: 1,
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(color: Colors.black),
                  outsideTextStyle: TextStyle(color: Colors.grey),
                  outsideDecoration: BoxDecoration(
                    color:
                        Colors.grey.shade300, // Gray box for dates before today
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                title: Text('Visiting Time'),
                subtitle: Text(
                  '${_selectedTimeStart.format(context)} - ${_selectedTimeEnd.format(context)}',
                ),
                trailing: Icon(Icons.edit),
                onTap: () {
                  _selectTime(context);
                },
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    // Logic to submit appointment
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Book Appointment',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Event {
  final String title;
  final DateTime date;

  Event(this.title, this.date);
}
