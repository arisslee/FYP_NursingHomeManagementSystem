import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'staff_resident.dart';
import 'staff_edit_resident.dart';
import 'staff_show_link_book.dart';

class StaffLinkUserResident extends StatefulWidget {
  final List<Resident> selectedResidents;
  final String residentId;
  final void Function(List<Resident>, List<User>) onResidentsAndUsersUpdated;

  StaffLinkUserResident({
    required this.selectedResidents,
    required this.residentId, // Include residentId
    required this.onResidentsAndUsersUpdated,
  });

  @override
  _StaffLinkUserResidentState createState() => _StaffLinkUserResidentState();
}

class _StaffLinkUserResidentState extends State<StaffLinkUserResident> {
  late Future<List<User>> users;
  List<User> selectedUsers = [];
  String residentName = "";

  @override
  void initState() {
    super.initState();
    users = fetchUsers();
    fetchResidentName();
  }

  String getResidentId(String residentName) {
    // Find the resident with the given name and return its ID
    for (Resident resident in widget.selectedResidents) {
      if (resident.name == residentName) {
        return resident.id;
      }
    }
    return '';
  }

  Future<void> fetchResidentName() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> residentDocSnapshot =
          await FirebaseFirestore.instance
              .collection('resident')
              .doc(widget.residentId)
              .get();

      if (residentDocSnapshot.exists) {
        setState(() {
          residentName = residentDocSnapshot.data()?['name'] ?? "";
        });
      }
    } catch (e) {
      print('Error fetching resident name: $e');
    }
  }

  Future<List<User>> fetchUsers() async {
    QuerySnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('profile').get();

    List<User> userList = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> userDoc
        in userSnapshot.docs) {
      Map<String, dynamic> userData = userDoc.data();

      User user = User(
        name: userData['name'],
        gender: userData['gender'],
        contactNumber: userData['contactNumber'],
        userId: userDoc.id,
        isSelected: false,
      );

      userList.add(user);
    }

    return userList;
  }

  List<Resident> get selectedResidents => widget.selectedResidents
      .where((resident) => resident.isSelected)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Link Resident to User'),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: Color.fromARGB(
                  255, 214, 219, 244), // Background color for the container
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resident ID:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Text color
                  ),
                ),
                Text(
                  '${widget.residentId}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black, // Text color
                  ),
                ),
                SizedBox(height: 20), // Add space between ID and Name
                Text(
                  'Resident Name:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Text color
                  ),
                ),
                Text(
                  residentName,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black, // Text color
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  UserList(
                    onSelectedUsersChanged: (users) {
                      setState(() {
                        selectedUsers = users;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SaveButton(
              selectedUsers: selectedUsers,
              selectedResidents: selectedResidents,
              residentId: widget.residentId,
              residentName: residentName, // Pass residentName here
            ),
          ),
        ],
      ),
    );
  }
}

class UserList extends StatefulWidget {
  final void Function(List<User>) onSelectedUsersChanged;

  UserList({required this.onSelectedUsersChanged});

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  late Future<List<User>> users;
  User? selectedUser;

  @override
  void initState() {
    super.initState();
    users = fetchUsers();
  }

  Future<List<User>> fetchUsers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance.collection('profile').get();

      List<User> userList = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> userDoc
          in userSnapshot.docs) {
        Map<String, dynamic> userData = userDoc.data();

        User user = User(
          name: userData['name'],
          gender: userData['gender'],
          contactNumber: userData['contactNumber'],
          userId: userDoc.id, // Set the userID as the document ID
          isSelected: false, // Set the default value for isChecked
        );

        userList.add(user);
      }

      return userList;
    } catch (e) {
      print('Error fetching users: $e');
      throw e; // Rethrow the error to handle it in the UI if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
        future: users,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<User> userList = snapshot.data!;

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: userList.length,
              itemBuilder: (context, index) {
                User user = userList[index];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      // Unselect the previously selected user
                      if (selectedUser != null) {
                        selectedUser!.isSelected = false;
                      }

                      // Toggle the isSelected property
                      user.isSelected = !user.isSelected;

                      if (user.isSelected) {
                        // Set the selected user
                        selectedUser = user;
                      } else {
                        // Clear the selected user
                        selectedUser = null;
                      }

                      widget.onSelectedUsersChanged(selectedUser != null
                          ? [selectedUser!]
                          : []); // Pass the selected user list
                    });
                  },
                  child: Card(
                    elevation: 4,
                    margin: EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: user.isSelected
                        ? Color.fromARGB(255, 171, 233, 173)
                        : null,
                    child: ListTile(
                      title: Text(user.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gender: ${user.gender}'),
                          Text('Contact Number: ${user.contactNumber}'),
                          SizedBox(height: 16.0),
                          Text('User ID: ${user.userId}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        });
  }
}

class User {
  final String name;
  final String gender;
  final String contactNumber;
  final String userId;
  bool isSelected;

  User({
    required this.name,
    required this.gender,
    required this.contactNumber,
    required this.userId,
    this.isSelected = false,
  });
}

// Inside SaveButton widget in _StaffLinkUserResidentState
void saveSelectedDataToDatabase(
  List<Resident> selectedResidents,
  List<User> selectedUsers,
  String residentId,
  String residentName,
  void Function(bool success) callback,
) async {
  try {
    // Get the user IDs from the selected users
    List<String> selectedUserIds =
        selectedUsers.map((user) => user.userId).toList();

    // Combine resident and user data in the same document
    Map<String, dynamic> data = {
      'residentId': residentId,
      'residentName': residentName,
      'selectedResidents': selectedResidents
          .map((resident) => {'name': resident.name, 'gender': resident.gender})
          .toList(),
      'selectedUsers': selectedUsers
          .map((user) => {
                'name': user.name,
                'gender': user.gender,
                'contactNumber': user.contactNumber,
                'userId': user.userId, // Include user ID in the selected users
              })
          .toList(),
    };

    // Check if the document exists in the 'link_resident_user' collection
    var document = await FirebaseFirestore.instance
        .collection('link_resident_user')
        .doc(residentId)
        .get();

    if (document.exists) {
      // Update the existing document in the 'link_resident_user' collection
      await FirebaseFirestore.instance
          .collection('link_resident_user')
          .doc(residentId)
          .update(data);
      print('Updated existing document in the database.');
    } else {
      // Create a new document in the 'link_resident_user' collection
      await FirebaseFirestore.instance
          .collection('link_resident_user')
          .doc(residentId)
          .set(data);
      print('Created a new document in the database with ID: $residentId');
    }

    // Update the user documents with the resident ID in the 'profile' collection
    for (String userId in selectedUserIds) {
      await FirebaseFirestore.instance
          .collection('profile')
          .doc(userId)
          .update({'residentId': residentId});
    }

    // Invoke the callback with success as true
    callback(true);
  } catch (e) {
    // Handle errors, e.g., print an error message
    print('Error saving data to the database: $e');
    // Invoke the callback with success as false
    callback(false);
  }
}

class SaveButton extends StatelessWidget {
  final List<User> selectedUsers;
  final List<Resident> selectedResidents;
  final String residentId;
  final String residentName;

  SaveButton({
    required this.selectedUsers,
    required this.selectedResidents,
    required this.residentId,
    required this.residentName,
  });

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToStaffShowLinkBook(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StaffShowLinkBook(
          residentId: residentId,
          residentName: residentName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          saveSelectedDataToDatabase(
            selectedResidents,
            selectedUsers,
            residentId,
            residentName,
            (success) {
              if (success) {
                _showSnackBar(context, 'Update successfully');
                _navigateToStaffShowLinkBook(context);
              } else {
                _showSnackBar(context, 'Update failed');
              }
            },
          );
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.blue,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Save',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
