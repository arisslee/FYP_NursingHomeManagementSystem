import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:LifeSpring/staff_resident.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'staff_link_user_resident.dart';
import 'staff_show_link_book.dart';
import 'dart:io';

class EditResidentPage extends StatefulWidget {
  final Resident resident;
  final Function(Resident) onResidentUpdated;

  EditResidentPage({required this.resident, required this.onResidentUpdated});

  @override
  _EditResidentPageState createState() => _EditResidentPageState();
}

class _EditResidentPageState extends State<EditResidentPage> {
  String? profilePictureUrl;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _icNumberController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  File? _image;
  bool _isEditing = false;

  final TextStyle _viewModeTextStyle = TextStyle(color: Colors.grey);

  // Create a Future that will fetch the profile picture URL from Firestore
  Future<String?> _fetchProfilePictureUrl() async {
    final document = await FirebaseFirestore.instance
        .collection('resident')
        .doc(widget.resident.id)
        .get(GetOptions(source: Source.server));

    final data = document.data() as Map<String, dynamic>?;
    if (data != null && data.containsKey('profilePictureUrl')) {
      final url = data['profilePictureUrl'] as String;
      print("Profile Picture URL: $url"); // Add this line for debugging
      return url;
    } else {
      return null;
    }
  }

  Future<void> _linkUserToResident() async {
    final residentName = _nameController.text;
    final residentId = await getResidentIdFromName(residentName);

    if (residentId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StaffLinkUserResident(
            selectedResidents: [],
            residentId: residentId,
            onResidentsAndUsersUpdated: (selectedResidents, selectedUsers) {
              // Handle the update logic if needed
            },
          ),
        ),
      );
    } else {
      // Handle the case where residentId is null (resident not found)
    }
  }

  Future<String?> getResidentIdFromName(String name) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('resident')
          .where('name', isEqualTo: name)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Assuming there is only one resident with the given name
        return snapshot.docs.first.id;
      } else {
        // Handle the case where no resident is found with the given name
        return null;
      }
    } catch (e) {
      // Handle any errors that might occur during the query
      print('Error getting residentId: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch the profile picture URL and store it in the state
    _fetchProfilePictureUrl().then((url) {
      setState(() {
        profilePictureUrl = url;
      });
    });

    _nameController.text = widget.resident.name;
    _genderController.text = widget.resident.gender;
    _birthDateController.text =
        widget.resident.birthDate.toString().split(' ')[0];
    _ageController.text = widget.resident.age.toString();
    _icNumberController.text = widget.resident.icNumber;
    _phoneController.text = widget.resident.phoneNumber;
    _addressController.text = widget.resident.address;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Resident'),
        actions: <Widget>[
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: _linkUserToResident,
              ),
              IconButton(
                icon: Icon(Icons.people),
                onPressed: () {
                  // Navigate to StaffShowLinkBook screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StaffShowLinkBook(
                        residentName:
                            _nameController.text, // Pass the resident name
                        residentId: widget.resident.id, // Pass the resident id
                      ),
                    ),
                  );
                },
              ),
              if (_isEditing)
                IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () => _saveResident(),
                ),
              IconButton(
                icon: Icon(_isEditing ? Icons.close : Icons.edit),
                onPressed: () => setState(() => _isEditing = !_isEditing),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            FutureBuilder<String?>(
              future: _fetchProfilePictureUrl(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final profilePictureUrl = snapshot.data;

                return GestureDetector(
                  onTap: () {
                    if (_isEditing) {
                      _selectImage();
                    }
                  },
                  child: AbsorbPointer(
                    absorbing: !_isEditing,
                    child: Column(
                      children: [
                        _buildProfilePicturePicker(profilePictureUrl),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
            _buildTextField(
              controller: _nameController,
              labelText: 'Name',
              icon: Icons.person,
              enabled: _isEditing,
            ),
            _buildTextField(
              controller: _genderController,
              labelText: 'Gender',
              icon: Icons.wc,
              enabled: _isEditing,
            ),
            GestureDetector(
              onTap: () {
                if (_isEditing) {
                  _selectDate(context);
                }
              },
              child: AbsorbPointer(
                absorbing: !_isEditing,
                child: _buildTextField(
                  controller: _birthDateController,
                  labelText: 'Birth Date',
                  icon: Icons.cake,
                  style: _isEditing ? null : _viewModeTextStyle,
                ),
              ),
            ),
            _buildTextField(
              controller: _ageController,
              labelText: 'Age',
              icon: Icons.hourglass_empty,
              enabled: _isEditing,
            ),
            _buildTextField(
              controller: _icNumberController,
              labelText: 'IC Number',
              icon: Icons.credit_card,
              enabled: _isEditing,
            ),
            _buildTextField(
              controller: _phoneController,
              labelText: 'Phone Number',
              icon: Icons.phone,
              enabled: _isEditing,
            ),
            _buildTextField(
              controller: _addressController,
              labelText: 'Address',
              icon: Icons.home,
              enabled: _isEditing,
              maxLines: 3,
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool enabled = true,
    TextStyle? style,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: labelText,
              prefixIcon: Icon(icon),
              enabled: enabled,
              enabledBorder: _isEditing
                  ? UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    )
                  : UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
            ),
            style: style,
            maxLines: maxLines,
          ),
        ],
      ),
    );
  }

  Future<void> _selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid;

      if (userId != null) {
        final residentId = widget.resident.id;
        final storage = FirebaseStorage.instance;
        final Reference storageRef = storage
            .ref()
            .child('profile_pictures_resident')
            .child(userId)
            .child(residentId);

        final UploadTask uploadTask = storageRef.putFile(File(image.path));

        try {
          await uploadTask.whenComplete(() async {
            final String downloadURL = await storageRef.getDownloadURL();

            await FirebaseFirestore.instance
                .collection('resident')
                .doc(widget.resident.id)
                .update({'profilePictureUrl': downloadURL});

            setState(() {
              profilePictureUrl = downloadURL;
            });
          });
        } catch (e) {
          print("Error uploading image: $e");
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthDateController.text = picked.toLocal().toString().split(' ')[0];

        final today = DateTime.now();
        final age = today.year -
            picked.year -
            ((today.month > picked.month ||
                    (today.month == picked.month && today.day >= picked.day))
                ? 0
                : 1);
        _ageController.text = age.toString();
      });
    }
  }

  void _saveResident() {
    final String name = _nameController.text;
    final String gender = _genderController.text;
    final String birthDateString = _birthDateController.text;
    final String ageString = _ageController.text;
    final String icNumber = _icNumberController.text;
    final String phoneNumber = _phoneController.text;
    final String address = _addressController.text;

    final DateTime birthDate = DateTime.parse(birthDateString);
    final int age = int.tryParse(ageString) ?? 0;

    if (age == 0) {
      setState(() {
        // Handle the case where age is not a valid number.
      });
    } else {
      final updatedResident = Resident(
        id: widget.resident.id,
        name: name,
        gender: gender,
        birthDate: birthDate,
        age: age,
        icNumber: icNumber,
        phoneNumber: phoneNumber,
        address: address,
        profilePictureUrl: profilePictureUrl,
      );

      _updateResidentInFirestore(updatedResident);

      widget.onResidentUpdated(updatedResident);

      // Refresh the data to ensure it's up-to-date
      _refreshData();

      // Pass the updated resident back as a result to the previous screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EditResidentPage(
            resident: updatedResident,
            onResidentUpdated: (resident) {
              _updateResident(resident); // Update the local state
            },
          ),
        ),
      );
    }
  }

  void _refreshData() {
    _fetchProfilePictureUrl().then((url) {
      setState(() {
        profilePictureUrl = url;
      });
    });

    // Refresh other data
    FirebaseFirestore.instance
        .collection('resident')
        .doc(widget.resident.id)
        .get(GetOptions(source: Source.server))
        .then((document) {
      final data = document.data() as Map<String, dynamic>?;
      if (data != null) {
        setState(() {
          _nameController.text = data['name'] ?? '';
          _genderController.text = data['gender'] ?? '';
          final birthDate = data['birthDate']?.toDate();
          _birthDateController.text =
              birthDate != null ? birthDate.toString().split(' ')[0] : '';
          _ageController.text = data['age']?.toString() ?? '';
          _icNumberController.text = data['icNumber'] ?? '';
          _phoneController.text = data['phoneNumber'] ?? '';
          _addressController.text = data['address'] ?? '';
        });
      }
    });
  }

  void _updateResident(Resident resident) {
    setState(() {
      // Update the local state with the new resident data
      _nameController.text = resident.name;
      _genderController.text = resident.gender;
      _birthDateController.text = resident.birthDate.toString().split(' ')[0];
      _ageController.text = resident.age.toString();
      _icNumberController.text = resident.icNumber;
      _phoneController.text = resident.phoneNumber;
      _addressController.text = resident.address;
      profilePictureUrl = resident.profilePictureUrl;
    });
  }

  void _updateResidentInFirestore(Resident updatedResident) {
    final firestoreInstance = FirebaseFirestore.instance;

    Map<String, dynamic> residentData = {
      'name': updatedResident.name,
      'gender': updatedResident.gender,
      'birthDate': updatedResident.birthDate,
      'age': updatedResident.age,
      'icNumber': updatedResident.icNumber,
      'phoneNumber': updatedResident.phoneNumber,
      'address': updatedResident.address,
      'profilePictureUrl': updatedResident.profilePictureUrl,
    };

    firestoreInstance
        .collection('resident')
        .doc(updatedResident.id)
        .update(residentData)
        .then((value) {
      // Firestore update successful
    }).catchError((error) {
      print('Error updating resident in Firestore: $error');
      // Handle the error
    });
  }

  Widget _buildProfilePicturePicker(String? profilePictureUrl) {
    double profilePictureSize = 150.0;
    Color inputFillColor = Colors.white;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          InkWell(
            onTap: _isEditing ? () => _selectImage() : null,
            child: Container(
              width: profilePictureSize,
              height: profilePictureSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
                color: inputFillColor,
              ),
              child: Center(
                child: _image == null
                    ? (profilePictureUrl != null
                        ? ClipOval(
                            child: Image.network(
                              profilePictureUrl,
                              width: profilePictureSize,
                              height: profilePictureSize,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            'Upload Profile Picture',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: "SairaCondensed"),
                          ))
                    : ClipOval(
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                          width: profilePictureSize,
                          height: profilePictureSize,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
