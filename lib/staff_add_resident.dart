import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:LifeSpring/staff_resident.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'staff_resident.dart';
import 'staff_edit_resident.dart';

class AddResidentPage extends StatefulWidget {
  @override
  _AddResidentPageState createState() => _AddResidentPageState();
}

Future<String> _uploadProfilePicture(File imageFile, String residentId) async {
  final storage = FirebaseStorage.instance;
  final Reference storageRef = storage
      .ref()
      .child('profile_pictures_resident')
      .child(FirebaseAuth.instance.currentUser?.uid ?? '')
      .child(residentId);

  final UploadTask uploadTask = storageRef.putFile(imageFile);

  final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
  if (taskSnapshot.state == TaskState.success) {
    final String downloadURL = await storageRef.getDownloadURL();
    return downloadURL;
  } else {
    throw 'Failed to upload profile picture';
  }
}

Future<void> _addResidentToFirestore(
    Resident resident, File? selectedImage) async {
  final firestoreInstance = FirebaseFirestore.instance;

  String? downloadURL; // Declare downloadURL as nullable

  if (selectedImage != null) {
    downloadURL = await _uploadProfilePicture(selectedImage, resident.id);
  }

  // Create a new document reference with an auto-generated ID
  final DocumentReference documentReference =
      firestoreInstance.collection('resident').doc();

  Map<String, dynamic> residentData = {
    'name': resident.name,
    'gender': resident.gender,
    'birthDate': resident.birthDate,
    'age': resident.age,
    'icNumber': resident.icNumber,
    'phoneNumber': resident.phoneNumber,
    'address': resident.address,
    'profilePictureUrl': downloadURL, // Include the profile picture URL
  };

  // Set the data using the auto-generated ID
  documentReference.set(residentData).then((value) {
    print('Resident added to Firestore with ID: ${documentReference.id}');
  }).catchError((error) {
    print('Error adding resident to Firestore: $error');
  });
}

class _AddResidentPageState extends State<AddResidentPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _icNumberController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  File? _selectedImage;
  int? _age;
  String _nameError = '';
  String _genderError = '';
  String _birthDateError = '';
  String _ageError = '';
  String _icNumberError = '';
  String _phoneError = '';
  String _addressError = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Resident'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildProfilePicturePicker(), // Call a custom method for the profile picture widget

            _buildTextField(
              controller: _nameController,
              labelText: 'Name',
              icon: Icons.person,
              errorText: _nameError,
              inputType: TextInputType.text, // Allow only alphabets
            ),
            _buildTextField(
              controller: _genderController,
              labelText: 'Gender',
              icon: Icons.wc,
              errorText: _genderError,
            ),
            GestureDetector(
              onTap: () {
                _selectDate(context);
              },
              child: AbsorbPointer(
                child: _buildTextField(
                  controller: _birthDateController,
                  labelText: 'Birth Date',
                  icon: Icons.cake,
                  keyboardType: TextInputType.datetime,
                  errorText: _birthDateError,
                ),
              ),
            ),
            _buildTextField(
              controller: _ageController,
              labelText: 'Age',
              icon: Icons.hourglass_empty,
              keyboardType: TextInputType.number,
              enabled: false,
              errorText: _ageError,
            ),
            _buildTextField(
              controller: _icNumberController,
              labelText: 'IC Number',
              icon: Icons.credit_card,
              errorText: _icNumberError,
            ),
            _buildTextField(
              controller: _phoneController,
              labelText: 'Phone Number',
              icon: Icons.phone,
              errorText: _phoneError,
              inputType: TextInputType.phone, // Allow only integers
            ),
            _buildTextField(
              controller: _addressController,
              labelText: 'Address',
              icon: Icons.home,
              errorText: _addressError,
              inputType: TextInputType.text, // Allow any string
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final String name = _nameController.text;
                final String gender = _genderController.text;
                final String birthDateString = _birthDateController.text;
                final String ageString = _ageController.text;
                final String icNumber = _icNumberController.text;
                final String phoneNumber = _phoneController.text;
                final String address = _addressController.text;

                setState(() {
                  _nameError = !_validateName(name)
                      ? 'Name should contain only alphabets'
                      : '';
                  _genderError = (gender == 'Male' || gender == 'Female')
                      ? ''
                      : 'Please enter "Male" or "Female"';
                  _birthDateError =
                      birthDateString.isEmpty ? 'Birth Date is required' : '';
                  _ageError = ageString.isEmpty ? 'Age is required' : '';
                  _icNumberError = _validateICNumber(icNumber)
                      ? ''
                      : 'Please follow the format (xxxxxx-xx-xxxx)';
                  _phoneError = !_validatePhoneNumber(phoneNumber)
                      ? 'Phone Number should contain only digits'
                      : '';
                  _addressError = address.isEmpty ? 'Address is required' : '';
                });

                if (_validateName(name) &&
                    gender.isNotEmpty &&
                    birthDateString.isNotEmpty &&
                    ageString.isNotEmpty &&
                    _validatePhoneNumber(phoneNumber) &&
                    address.isNotEmpty &&
                    _validateICNumber(icNumber)) {
                  final DateTime birthDate = DateTime.parse(birthDateString);
                  final int age = int.tryParse(ageString) ?? 0;

                  if (age == 0) {
                    setState(() {
                      _ageError = 'Invalid Age';
                    });
                  } else {
                    _age = age;
                    final newResident = Resident(
                      id: DateTime.now().toString(),
                      name: name,
                      gender: gender,
                      birthDate: birthDate,
                      age: age,
                      icNumber: icNumber,
                      phoneNumber: phoneNumber,
                      address: address,
                    );

                    _addResidentToFirestore(newResident, _selectedImage);

                    Navigator.pop(context, newResident);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Background color
                onPrimary: Colors.white, // Text color
                elevation: 5, // Elevation
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8.0), // Button border radius
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                    12.0), // Padding around the button's text
                child:
                    Text('Add', style: TextStyle(fontSize: 18.0)), // Text style
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicturePicker() {
    double profilePictureSize = 150.0;
    Color inputFillColor = Colors.white;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              _selectImage();
            },
            child: ClipOval(
              child: Container(
                width: profilePictureSize,
                height: profilePictureSize,
                decoration: BoxDecoration(
                  color: inputFillColor,
                ),
                child: (_selectedImage != null)
                    ? Image.file(
                        _selectedImage!,
                        width: profilePictureSize,
                        height: profilePictureSize,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.add_a_photo,
                        size: 60,
                        color: Colors.grey,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    String errorText = '',
    TextInputType inputType = TextInputType.text, // Added this parameter
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          errorText: errorText.isNotEmpty ? errorText : null,
        ),
        keyboardType: inputType, // Use the specified input type
        enabled: enabled,
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Future<void> _selectImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
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
        _age = age;
        _ageController.text = _age.toString();
      });
    }
  }

  bool _validateName(String name) {
    // Regular expression to match alphabets only
    final namePattern = RegExp(r'^[a-zA-Z]+$');
    return namePattern.hasMatch(name);
  }

  bool _validatePhoneNumber(String phoneNumber) {
    // Regular expression to match digits only
    final phonePattern = RegExp(r'^[0-9]+$');
    return phonePattern.hasMatch(phoneNumber);
  }

  bool _validateICNumber(String icNumber) {
    if (icNumber.isEmpty) {
      return false;
    }

    final icPattern = RegExp(r'^\d{6}-\d{2}-\d{4}$');
    return icPattern.hasMatch(icNumber);
  }
}
