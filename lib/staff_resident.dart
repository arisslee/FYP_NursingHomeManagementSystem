import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'staff_add_resident.dart';
import 'staff_edit_resident.dart';
import 'staff_link_user_resident.dart';

class Resident {
  final String id;
  final String name;
  final String gender;
  final DateTime birthDate;
  final int age;
  final String icNumber;
  final String phoneNumber;
  final String address;
  final String? profilePictureUrl;
  bool isSelected;

  Resident({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.age,
    required this.icNumber,
    required this.phoneNumber,
    required this.address,
    this.profilePictureUrl,
    this.isSelected = false, // Initialize isSelected to false
  });
}

bool isSelected = false; // Add this line

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StaffResidentPage(),
    );
  }
}

class StaffResidentPage extends StatefulWidget {
  @override
  _StaffResidentPageState createState() => _StaffResidentPageState();
}

class _StaffResidentPageState extends State<StaffResidentPage> {
  List<Resident> residents = [];
  List<Resident> filteredResidents = [];
  TextEditingController searchController = TextEditingController();
  List<User> selectedUsers = [];
  List<Resident> selectedResidents = [];

  @override
  void initState() {
    super.initState();
    residents = []; // Initialize residents list
    filteredResidents = []; // Initialize filteredResidents list

    // Fetch data from Firestore and populate the residents list.
    FirebaseFirestore.instance
        .collection('resident')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        final data = doc.data();
        final resident = Resident(
          id: doc.id,
          name: data['name'],
          gender: data['gender'],
          birthDate: data['birthDate'].toDate(),
          age: data['age'],
          icNumber: data['icNumber'],
          phoneNumber: data['phoneNumber'],
          address: data['address'],
        );
        setState(() {
          residents.add(resident);
        });
      });

      // Sort residents by name
      residents.sort((a, b) => a.name.compareTo(b.name));
      filteredResidents = List.from(residents);
    });

    // Set up a listener for changes in the search bar
    searchController.addListener(() {
      filterResidents(searchController.text);
    });
  }

  void _updateResidentAndUser(
      BuildContext context, List<Resident> selectedResidents) async {
    if (selectedResidents.isNotEmpty) {
      String residentId = selectedResidents[0]
          .id; // Assuming you want the ID of the first selected resident
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StaffLinkUserResident(
            selectedResidents: selectedResidents,
            residentId:
                residentId, // Pass the residentId to StaffLinkUserResident
            onResidentsAndUsersUpdated: (selectedResidents, selectedUsers) {
              // Handle the update logic if needed
            },
          ),
        ),
      );
    }
  }

  void addResident(Resident newResident) {
    setState(() {
      residents.add(newResident);
      residents.sort((a, b) => a.name.compareTo(b.name));
      filteredResidents = List.from(residents);
    });
  }

  void _updateResident(Resident updatedResident) {
    final index = residents.indexWhere((r) => r.id == updatedResident.id);
    if (index != -1) {
      setState(() {
        residents[index] = updatedResident;
        filteredResidents = List.from(residents);
      });
    }
  }

  void filterResidents(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredResidents = List.from(residents);
      } else {
        filteredResidents = residents
            .where((resident) =>
                resident.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Residents',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: filteredResidents.length,
                itemBuilder: (context, index) {
                  final resident = filteredResidents[index];
                  IconData genderIcon = Icons.person;
                  Color iconColor = Colors.black;

                  if (resident.gender == 'Male') {
                    iconColor = Color.fromARGB(255, 108, 183, 244);
                  } else if (resident.gender == 'Female') {
                    iconColor = const Color.fromARGB(255, 230, 113, 152);
                  }

                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: () async {
                        final updatedResident = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditResidentPage(
                              resident: resident,
                              onResidentUpdated: (updatedResident) {
                                setState(() {
                                  residents[index] = updatedResident;
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: Dismissible(
                        key: Key(resident.id),
                        confirmDismiss: (DismissDirection direction) async {
                          final shouldDelete = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm Deletion'),
                                content: Text(
                                    'Are you sure you want to delete ${resident.name}?'),
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

                          if (shouldDelete) {
                            await FirebaseFirestore.instance
                                .collection('resident')
                                .doc(resident.id)
                                .delete();

                            setState(() {
                              residents.removeAt(index);
                              filteredResidents.removeAt(index);
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Deleted ${resident.name}'),
                              ),
                            );
                          }

                          return shouldDelete;
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                resident.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Age: ${resident.age ?? 'N/A'}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          leading: Icon(
                            genderIcon,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddResidentPage(),
            ),
          ).then((newResident) {
            if (newResident != null) {
              addResident(newResident);
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
