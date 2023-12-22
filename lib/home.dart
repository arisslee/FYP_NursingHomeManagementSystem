import 'package:flutter/material.dart';
import 'visiting_appointment.dart';
import 'medical_records.dart';
import 'communication_portal.dart';
import 'profile.dart';
import 'linked_resident.dart';
import 'main.dart';
import 'term.dart';
import 'faq.dart';
import 'contact.dart';
import 'visitor_pass.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
    'Visitor Pass',
    'Medical Records',
    'Communication Portal',
  ];

  static List<Widget> _pages = [
    VisitingAppointmentPage(),
    VisitorPassPage(),
    MedicalRecordsPage(),
    CommunicationPortalPage(),
  ];

  void _logout(BuildContext context) {
    _showLogoutConfirmationDialog(context);
  }

  Future<String?> fetchProfilePictureUrl() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid;

      if (userId != null) {
        final storage = FirebaseStorage.instance;
        final Reference storageRef =
            storage.ref().child('profile_pictures').child(userId);

        final String downloadURL = await storageRef.getDownloadURL();
        return downloadURL;
      } else {
        return null; // User not logged in or UID is null
      }
    } catch (e) {
      print('Error fetching profile picture URL: $e');
      return null;
    }
  }

  Future<String?> fetchUserName() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final QuerySnapshot userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser.email)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          final userData = userQuery.docs[0].data() as Map<String, dynamic>;
          final name = userData['name'] ?? 'Name not available';
          return name;
        }
      }
      return null; // Return null if user not found or not logged in
    } catch (e) {
      print('Error fetching user name: $e');
      return null; // Handle errors by returning null
    }
  }

  Future<String?> fetchUserEmail() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final QuerySnapshot userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser.email)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          final userData = userQuery.docs[0].data() as Map<String, dynamic>;
          final email = userData['email'] ?? 'Email not available';
          return email;
        }
      }
      return null; // Return null if user not found or not logged in
    } catch (e) {
      print('Error fetching user email: $e');
      return null; // Handle errors by returning null
    }
  }

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
              _logout(context); // Pass the BuildContext
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              color: Colors.blue, // Background color
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: FutureBuilder<String?>(
                future: fetchProfilePictureUrl(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || snapshot.data == null) {
                    // Handle error or no profile picture available
                    return Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/default_profile_pic.jpg'),
                            radius: 55.0, // Adjust the radius to make it larger
                          ),
                          SizedBox(height: 10.0), // Add some spacing
                          FutureBuilder<String?>(
                            future: fetchUserName(),
                            builder: (context, userNameSnapshot) {
                              String? userName = userNameSnapshot.data;
                              return Text(
                                userName ?? 'Name not available',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.0,
                                ),
                              );
                            },
                          ),
                          FutureBuilder<String?>(
                            future: fetchUserEmail(),
                            builder: (context, userEmailSnapshot) {
                              String? userEmail = userEmailSnapshot.data;
                              return Text(
                                userEmail ?? 'Email not available',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Display the profile picture using the fetched URL
                    return Center(
                      child: Column(
                        children: [
                          SizedBox(height: 30.0),
                          CircleAvatar(
                            backgroundImage: NetworkImage(snapshot.data!),
                            radius: 55.0, // Adjust the radius to make it larger
                          ),
                          SizedBox(height: 10.0), // Add some spacing
                          FutureBuilder<String?>(
                            future: fetchUserName(),
                            builder: (context, userNameSnapshot) {
                              String? userName = userNameSnapshot.data;
                              return Text(
                                userName ?? 'Name not available',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.0,
                                ),
                              );
                            },
                          ),
                          FutureBuilder<String?>(
                              future: fetchUserEmail(),
                              builder: (context, userEmailSnapshot) {
                                String? userEmail = userEmailSnapshot.data;
                                return Text(
                                  userEmail ?? 'Email not available',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                );
                              })
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 10.0),
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
              leading: Icon(Icons.people), // Icon for Terms of Service
              title: Text('Linked Resident'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => LinkedResidentPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.description), // Icon for Terms of Service
              title: Text('Terms of Service'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => TermPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('FAQ'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FAQPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Contact Us'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ContactUsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                _logout(context);
              },
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
            icon: Icon(Icons.credit_card),
            label: 'Visitor Pass',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'Medical',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Communication',
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
