import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_communication_portal.dart';

class DoctorChatListPage extends StatefulWidget {
  @override
  _DoctorChatListPageState createState() => _DoctorChatListPageState();
}

class _DoctorChatListPageState extends State<DoctorChatListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<DocumentSnapshot> users;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Chat by User ID',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                users = snapshot.data!.docs;

                return UserListView(users, searchQuery: searchQuery);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserListView extends StatefulWidget {
  final List<DocumentSnapshot> users;
  final String searchQuery;

  UserListView(this.users, {required this.searchQuery});

  @override
  _UserListViewState createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  @override
  Widget build(BuildContext context) {
    List<DocumentSnapshot> filteredUsers = widget.users
        .where((user) => user['userUID']
            .toString()
            .toLowerCase()
            .contains(widget.searchQuery.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        var user = filteredUsers[index];
        var userUID = user['userUID'];
        var name = user['name'];

        return GestureDetector(
          onTap: () {
            // Pass name and userUID to DoctorCommunicationPortalPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorCommunicationPortalPage(
                  userName: name,
                  userUID: userUID,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
                color: Colors.white,
              ),
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'User ID: $userUID',
                      style: TextStyle(fontSize: 13.0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: DoctorChatListPage(),
  ));
}
