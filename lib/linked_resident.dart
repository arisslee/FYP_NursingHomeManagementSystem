import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LinkedResidentPage extends StatefulWidget {
  @override
  _LinkedResidentPageState createState() => _LinkedResidentPageState();
}

class _LinkedResidentPageState extends State<LinkedResidentPage> {
  late User _user; // Variable to hold the current user
  List<Map<String, dynamic>> linkedResidentsData = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    // Retrieve the current user from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        _user = user;
      });
      _fetchLinkedResidents();
    } else {
      // Handle the case where the user is not logged in
      // You may want to navigate to the login screen or take appropriate action
    }
  }

  Future<void> _fetchLinkedResidents() async {
    try {
      final linkResidentUserCollection =
          FirebaseFirestore.instance.collection('link_resident_user');

      // Query 'link_resident_user' collection to find documents where selectedUsers contain user UID
      final querySnapshot = await linkResidentUserCollection.get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          linkedResidentsData = querySnapshot.docs
              .where((doc) => (doc['selectedUsers'] as List)
                  .any((user) => user['userId'] == _user.uid))
              .map((doc) {
            return {
              'residentId': doc['residentId'],
              'residentName': doc['residentName'],
            };
          }).toList();
        });
      }
    } catch (e) {
      // Handle errors here
      print('Error fetching linked residents: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Linked Residents'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Text('User UID: ${_user.uid}'), // Display the user UID
            SizedBox(height: 20),
            if (linkedResidentsData.isNotEmpty)
              Column(
                children: linkedResidentsData.map((residentData) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 201, 183, 251),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Linked Resident ID: ${residentData['residentId']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Resident Name: ${residentData['residentName']}',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            if (linkedResidentsData.isEmpty) Text('No linked residents found'),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LinkedResidentPage(),
  ));
}
