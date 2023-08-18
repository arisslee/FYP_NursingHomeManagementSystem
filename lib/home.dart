import 'package:flutter/material.dart';
import 'visiting_appointment.dart';
import 'medical_records.dart';
import 'profile.dart'; // Import the ProfilePage
import 'resident_information.dart'; // Import the ResidentInformationPage
import 'main.dart'; // Import the LoginPage class

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<String> _pageTitles = [
    'Visiting Appointment',
    'Medical Records',
    'Communication Portal',
    'Resident Information',
  ];

  static List<Widget> _pages = [
    VisitingAppointmentPage(),
    MedicalRecordsPage(),
    Container(), // Placeholder for Communication Portal
    ResidentInformationPage(), // Display the ResidentInformationPage instead of a Container
  ];

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoginPage()), // Navigate to login page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]), // Set the title dynamically
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              accountName: Padding(
                padding: const EdgeInsets.only(top: 8.0), // Add top padding
                child: Text(
                  'Lee Xiao Qi', // Replace with the user's name
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              accountEmail: Padding(
                padding:
                    const EdgeInsets.only(bottom: 8.0), // Add bottom padding
                child: Text(
                  'leexiaoqi@gmail.com', // Replace with the user's email
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              currentAccountPicture: Padding(
                padding: const EdgeInsets.all(5), // Add padding all around
                child: CircleAvatar(
                  backgroundImage: AssetImage(
                      'assets/profile_pic.jpg'), // Replace with the user's profile picture
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('My Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage()), // Navigate to ProfilePage
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_support),
              title: Text('Contact Us'),
              onTap: () {
                // Navigate to Contact Us page
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: _logout, // Call the logout function
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex], // Show the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Medical',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Communication',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
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
