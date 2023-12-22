import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffShowLinkBook extends StatelessWidget {
  final String residentName;
  final String residentId;

  StaffShowLinkBook({required this.residentName, required this.residentId});

  @override
  Widget build(BuildContext context) {
    // Create a stream that listens to changes in 'link_resident_user' collection
    Stream<DocumentSnapshot<Map<String, dynamic>>> linkResidentUserStream =
        FirebaseFirestore.instance
            .collection('link_resident_user')
            .doc(residentId) // Assuming residentId is the document ID
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Resident Details'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: linkResidentUserStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No data found for Resident ID: $residentId',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          // Access the fields from the 'link_resident_user' document
          Map<String, dynamic> linkResidentUserData =
              snapshot.data!.data() as Map<String, dynamic>;

          // Access the 'selectedUsers' array field
          List<dynamic> selectedUsers =
              linkResidentUserData['selectedUsers'] ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resident Name: $residentName',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Resident ID: $residentId',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  Divider(), // Horizontal line
                  SizedBox(height: 16),
                  if (selectedUsers.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Linked Users:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        for (var user in selectedUsers)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name: ${user['name']}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Gender: ${user['gender']}'),
                                  Text(
                                      'Contact Number: ${user['contactNumber']}'),
                                  Text(
                                      'User ID: ${user['userId']}'), // Add this line
                                ],
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
