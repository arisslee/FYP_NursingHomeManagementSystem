import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'staff_approve_pass.dart';

class StaffVisitorPassPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        // Fetch data from 'users' collection
        future: FirebaseFirestore.instance.collection('users').get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> usersSnapshot) {
          if (usersSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (usersSnapshot.hasError) {
            return Center(child: Text('Error: ${usersSnapshot.error}'));
          }

          // Extract user data
          final List<DocumentSnapshot> users = usersSnapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              // Extract userUID and name
              final String userUID = user['userUID'];
              final String userName = user['name'];

              return FutureBuilder(
                // Fetch data from 'profile' collection based on the 'name' field
                future: FirebaseFirestore.instance
                    .collection('profile')
                    .where('name', isEqualTo: userName)
                    .get(),
                builder:
                    (context, AsyncSnapshot<QuerySnapshot> profileSnapshot) {
                  if (profileSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          'Loading...',
                          style: TextStyle(fontSize: 16.0), // Adjust font size
                        ),
                      ),
                    );
                  }

                  if (profileSnapshot.hasError) {
                    return Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          'Error: ${profileSnapshot.error}',
                          style: TextStyle(fontSize: 16.0), // Adjust font size
                        ),
                      ),
                    );
                  }

                  // Extract gender from the 'profile' collection
                  final List<DocumentSnapshot> profiles =
                      profileSnapshot.data!.docs;
                  final String gender = profiles.isNotEmpty
                      ? profiles[0]['gender']
                      : 'Unknown Gender';

                  // Define the color for the person icon based on gender
                  Color iconColor = gender == 'Male'
                      ? Colors.blue
                      : gender == 'Female'
                          ? Colors.pink
                          : Colors.grey;

                  return GestureDetector(
                    onTap: () {
                      // Navigate to the new page and pass data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StaffApprovePassPage(
                            userUID: userUID,
                            userName: userName,
                            gender: gender,
                            approvalStatus: 'approve',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.person,
                          color: iconColor,
                        ),
                        title: Text(
                          '$userName',
                          style: TextStyle(fontSize: 18.0), // Adjust font size
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$userUID',
                              style:
                                  TextStyle(fontSize: 12.0), // Adjust font size
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
