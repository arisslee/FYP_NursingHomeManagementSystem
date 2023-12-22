import 'package:flutter/material.dart';
import 'staff_appointment.dart'; // Import your staff-related pages
import 'staff_visitor_pass.dart';
import 'staff_visitor.dart';
import 'staff_resident.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StaffHomePage(),
    );
  }
}

class StaffHomePage extends StatefulWidget {
  @override
  _StaffHomePageState createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  int _selectedIndex = 0;
  List<String> _pageTitles = [
    'Manage Appointment',
    'Manage Visitor Pass',
    'Manage Visitor',
    'Manage Resident',
  ];

  static List<Widget> _pages = [
    StaffAppointmentPage(
        date: DateTime.now(), // Provide a DateTime value
        startTime: '9:00 AM', // Provide a start time
        endTime: '10:00 AM',
        userUID: 'user_id', // Replace 'user_id' with the actual user UID
        userInfo: {
          'name': 'John Doe',
          'phone': '123-456-7890'
        } // Provide an end time
        ),
    StaffVisitorPassPage(),
    StaffVisitorPage(),
    StaffResidentPage(),
  ];

  // Function to show the logout confirmation dialog
  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Are you sure you want to logout?'),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton(
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black87),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                    ),
                    onPressed: () {
                      // Perform logout logic here
                      Navigator.of(context).pop(); // Close the dialog
                      _navigateToLogin(context); // Navigate to login page
                    },
                    child: Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        );
      },
    );
  }

// Function to navigate to the login page
  void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoginPage()), // Replace with your login page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]), // Set the title dynamically
        actions: [
          // Add the logout button to the app bar
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmationDialog(context); // Pass the BuildContext
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Show the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Visitor Pass',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin),
            label: 'Visitor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Resident',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.blue,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
