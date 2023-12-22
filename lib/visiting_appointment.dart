import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'appointment_history.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class VisitingAppointmentPage extends StatefulWidget {
  @override
  _VisitingAppointmentPageState createState() =>
      _VisitingAppointmentPageState();
}

Future<List<DocumentSnapshot>> getUpcomingAppointments() async {
  final CollectionReference appointments = FirebaseFirestore.instance
      .collection('upcoming_appointment'); // Firestore reference

  final now = DateTime.now();

  try {
    final QuerySnapshot upcomingAppointments = await appointments
        .where('date', isGreaterThanOrEqualTo: now) // Filter by date
        .orderBy('date')
        .get();

    return upcomingAppointments.docs;
  } catch (e) {
    print('Error retrieving upcoming appointments: $e');
    return [];
  }
}

class _VisitingAppointmentPageState extends State<VisitingAppointmentPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  TimeOfDay _selectedTimeStart = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _selectedTimeEnd = TimeOfDay(hour: 0, minute: 0);
  ValueNotifier<List<Event>> _selectedEvents = ValueNotifier([]);
  CalendarFormat _calendarFormat = CalendarFormat.month;
  User? user; // Declare user as nullable

  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Get the current user (if logged in)
    user = auth.currentUser;
  }

  Future<void> _selectTime(BuildContext context) async {
    // Create DateTime objects for 9:00 AM and 5:00 PM
    DateTime startTimeConstraint = DateTime(2023, 1, 1, 9, 0);
    DateTime endTimeConstraint = DateTime(2023, 1, 1, 17, 0);

    TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: _selectedTimeStart,
    );

    if (startTime != null) {
      DateTime selectedStartDateTime =
          DateTime(2023, 1, 1, startTime.hour, startTime.minute);

      // Check if the selected start time is within the allowed range
      if (selectedStartDateTime.isAfter(startTimeConstraint) &&
          selectedStartDateTime.isBefore(endTimeConstraint)) {
        TimeOfDay? endTime = await showTimePicker(
          context: context,
          initialTime: _selectedTimeEnd,
        );

        if (endTime != null) {
          DateTime selectedEndDateTime =
              DateTime(2023, 1, 1, endTime.hour, endTime.minute);

          // Check if the selected end time is within the allowed range
          if (selectedEndDateTime.isAfter(selectedStartDateTime) &&
              selectedEndDateTime.isBefore(endTimeConstraint)) {
            setState(() {
              _selectedTimeStart = startTime;
              _selectedTimeEnd = endTime;
            });
          } else {
            // Show an error message if the end time is outside the range
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Our opening hours are Mon - Fri  9AM - 5PM'),
              ),
            );
          }
        }
      } else {
        // Show an error message if the start time is outside the range
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Our opening hours are Mon - Fri  9AM - 5PM'),
          ),
        );
      }
    }
  }

  Future<void> bookAppointment(BuildContext context, String status) async {
    final User? user =
        FirebaseAuth.instance.currentUser; // Get the authenticated user

    // Check if the user is logged in
    if (user == null) {
      // User is not logged in; handle authentication first
      // You can redirect to a login screen or show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to book an appointment'),
        ),
      );
      return;
    }

    // Check if the selected time falls within the opening hours
    if (!isWithinOpeningHours()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Our opening hours are Mon - Fri 9AM - 5PM'),
        ),
      );
      return;
    }

    final CollectionReference appointments;

    if (status == 'Upcoming') {
      appointments =
          FirebaseFirestore.instance.collection('upcoming_appointment');
    } else if (status == 'Cancelled') {
      appointments =
          FirebaseFirestore.instance.collection('cancelled_appointment');
    } else if (status == 'Past') {
      appointments = FirebaseFirestore.instance.collection('past_appointment');
    } else {
      return; // Handle unknown status
    }

    try {
      await appointments.add({
        'date': _selectedDay,
        'startTime': _selectedTimeStart.format(context),
        'endTime': _selectedTimeEnd.format(context),
        'userUID': user.uid, // Pass the user's UID
        // You can add more fields here if needed
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment successfully booked!'),
        ),
      );

      // Navigate to the appointment history page after a short delay
      await Future.delayed(Duration(seconds: 1));
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AppointmentHistoryPage(
            date: _selectedDay,
            startTime: _selectedTimeStart.format(context),
            endTime: _selectedTimeEnd.format(context),
            userUID:
                user.uid, // Pass the user's UID to fetch their appointments
          ),
        ),
      );
    } catch (e) {
      print('Error booking appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error booking appointment: $e'),
        ),
      );
    }
  }

  bool isWithinOpeningHours() {
    // Create DateTime objects for opening and closing hours
    DateTime openingHour =
        DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 9, 0);
    DateTime closingHour = DateTime(
        _selectedDay.year, _selectedDay.month, _selectedDay.day, 17, 0);

    // Create DateTime objects for the selected times
    DateTime startDateTime = DateTime(_selectedDay.year, _selectedDay.month,
        _selectedDay.day, _selectedTimeStart.hour, _selectedTimeStart.minute);
    DateTime endDateTime = DateTime(_selectedDay.year, _selectedDay.month,
        _selectedDay.day, _selectedTimeEnd.hour, _selectedTimeEnd.minute);

    // Check if both start and end times are within opening hours
    return startDateTime.isAfter(openingHour) &&
        endDateTime.isBefore(closingHour);
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
                  // Check if the selected day is a weekend (Saturday or Sunday)
                  if (selectedDay.weekday == DateTime.saturday ||
                      selectedDay.weekday == DateTime.sunday) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Our opening hours are Mon - Fri  9AM - 5PM'),
                      ),
                    );
                    return; // Prevent selection
                  }

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
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    bookAppointment(context,
                        'Upcoming'); // Change 'Upcoming' to the appropriate status
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Book Appointment',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Add the navigation code here
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AppointmentHistoryPage(
                        date: _selectedDay,
                        startTime: _selectedTimeStart.format(context),
                        endTime: _selectedTimeEnd.format(context),
                        userUID: user?.uid ??
                            '', // Provide an end time// Provide the end time
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 106, 188, 109),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'View My Appointment',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
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

void main() {
  runApp(MaterialApp(
    home: VisitingAppointmentPage(),
  ));
}
