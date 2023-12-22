import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'staff_edit_visitor.dart';
//import 'staff_add_visitor.dart';

// Define your User class including the email field
class User {
  final String id;
  final String name;
  final String email;
  final String? gender; // Make gender optional

  User({
    required this.id,
    required this.name,
    required this.email,
    this.gender, // Include gender as an optional field
  });
  // Add other fields as needed
}

class StaffVisitorPage extends StatefulWidget {
  @override
  _StaffVisitorPageState createState() => _StaffVisitorPageState();
}

class _StaffVisitorPageState extends State<StaffVisitorPage> {
  TextEditingController searchController = TextEditingController();
  List<User> allUsers = [];
  List<User> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();

    searchController.addListener(() {
      filterUsers(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<String?> getVisitorIdByName(String name) async {
    final QuerySnapshot userCollection = await FirebaseFirestore.instance
        .collection('profile')
        .where('name', isEqualTo: name)
        .get();

    if (userCollection.docs.isNotEmpty) {
      // Assuming that there's only one matching document, you can return its ID
      return userCollection.docs.first.id;
    }

    return null; // Name not found in the database
  }

  Future<void> fetchUserData() async {
    QuerySnapshot userCollection =
        await FirebaseFirestore.instance.collection('users').get();

    List<User> users = [];

    for (QueryDocumentSnapshot userDoc in userCollection.docs) {
      final userData = userDoc.data() as Map<String, dynamic>;
      String? name = userData['name'] as String?;

      if (name != null) {
        QuerySnapshot profileCollection = await FirebaseFirestore.instance
            .collection('profile')
            .where('name', isEqualTo: name)
            .get();

        if (profileCollection.docs.isNotEmpty) {
          final gender = profileCollection.docs.first['gender'] as String?;
          final user = User(
            id: userDoc.id,
            name: name,
            email: userData['email'] as String,
            gender: gender,
          );

          users.add(user);
        }
      }
    }

    setState(() {
      allUsers = users;
      filteredUsers = users;
    });
  }

  void filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredUsers = List.from(allUsers);
      } else {
        filteredUsers = allUsers
            .where((user) =>
                user.name.toLowerCase().contains(query.toLowerCase()) ||
                user.email.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<bool> showConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this user?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if allUsers is empty and show loading indicator
    if (allUsers.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Visitors',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    String? visitorName = filteredUsers[index].name;
                    String? visitorId = await getVisitorIdByName(visitorName);

                    if (visitorId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StaffEditVisitorPage(visitorId: visitorId),
                        ),
                      );
                    } else {
                      // Handle the case where the name was not found in the database
                      // You can display an error message or take appropriate action.
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Visitor Not Found'),
                            content: Text(
                                'The selected visitor does not exist in the database.'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Card(
                    elevation: 3,
                    margin: EdgeInsets.all(8),
                    child: UserListItem(user: filteredUsers[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => StaffAddVisitorPage(),
      //       ),
      //     );
      //   },
      //   child: Icon(Icons.add), // Icon for the button
      // ),
    );
  }
}

class UserListItem extends StatelessWidget {
  final User user;

  UserListItem({required this.user});

  @override
  Widget build(BuildContext context) {
    // Determine the gender icon and color based on the user's gender
    IconData genderIcon = Icons.person;
    Color iconColor = Colors.yellow; // Default color

    if (user.gender == 'Male') {
      iconColor = Color.fromARGB(255, 108, 183, 244);
    } else if (user.gender == 'Female') {
      iconColor = const Color.fromARGB(255, 230, 113, 152);
    }

    return ListTile(
      title: Text(user.name),
      subtitle: Text(user.email), // Display the email as a subtitle
      leading: Icon(
        genderIcon,
        color: iconColor,
      ),
      // Add more ListTile properties to display user data
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: StaffVisitorPage(),
  ));
}
