import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class UserProfile {
  final String name;
  final String gender;
  final String contactNumber;
  final String residentName;
  final String residentRelationship;

  UserProfile({
    required this.name,
    required this.gender,
    required this.contactNumber,
    required this.residentName,
    required this.residentRelationship,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gender': gender,
      'contactNumber': contactNumber,
      'residentName': residentName,
      'residentRelationship': residentRelationship,
    };
  }
}

class _ProfilePageState extends State<ProfilePage> {
  final nameController = TextEditingController();
  String selectedGender = '';
  final contactNumberController = TextEditingController();
  final residentNameController = TextEditingController();
  final residentRelationshipController = TextEditingController();

  bool _isEditing = false;
  bool _profileSaved = false; // Add a new state variable
  final Map<TextEditingController, String> originalValues = {};
  File? _image;
  final picker = ImagePicker();

  String originalGender = '';
  // Declare profilePictureUrl as a class-level variable
  String? profilePictureUrl;

  void _toggleEditing() {
    setState(() {
      if (_isEditing) {
        // Save changes logic here
        _isEditing = false;

        // Set the profileSaved flag to true
        _profileSaved = true;

        // Update the original values after saving changes
        originalValues[nameController] = nameController.text;
        originalValues[contactNumberController] = contactNumberController.text;
        originalValues[residentNameController] = residentNameController.text;
        originalValues[residentRelationshipController] =
            residentRelationshipController.text;

        // Create a UserProfile object with the updated data
        UserProfile userProfile = UserProfile(
          name: nameController.text,
          gender: selectedGender,
          contactNumber: contactNumberController.text,
          residentName: residentNameController.text,
          residentRelationship: residentRelationshipController.text,
        );

        // Save the UserProfile object to Firestore
        saveProfileToFirestore(userProfile);
      } else {
        _isEditing = true;
      }
    });
  }

  Future<void> fetchProfileData() async {
    try {
      // Get the current user
      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid;

      // Get a reference to the Firestore collection
      final userProfilesCollection =
          FirebaseFirestore.instance.collection('profile');

      // Fetch the user's profile data
      final userData = await userProfilesCollection.doc(userId).get();

      if (userData.exists) {
        // If data exists, update the UI with the fetched data
        final data = userData.data() as Map<String, dynamic>;
        setState(() {
          nameController.text = data['name'];
          selectedGender = data['gender'];
          contactNumberController.text = data['contactNumber'];
          residentNameController.text = data['residentName'];
          residentRelationshipController.text = data['residentRelationship'];

          // Fetch the profile picture URL from Firestore
          profilePictureUrl = data['profilePictureUrl'];
        });
      }
    } catch (e) {
      // Handle errors here
      print('Error fetching profile data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> saveProfileToFirestore(UserProfile userProfile) async {
    try {
      // Get a reference to the Firestore collection
      final userProfilesCollection =
          FirebaseFirestore.instance.collection('profile');

      // Use the current user's ID as the document ID (you should have access to the current user)
      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid;

      // Save the user's profile data to Firestore
      await userProfilesCollection.doc(userId).set(userProfile.toMap());

      // Profile data saved successfully
    } catch (e) {
      // Handle errors here
      print('Error saving profile data: $e');
    }
  }

  Future<List<String>> fetchResidents() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('resident').get();

      List<String> residents =
          querySnapshot.docs.map((doc) => doc['name'] as String).toList();

      return residents;
    } catch (e) {
      print('Error fetching residents: $e');
      return [];
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Upload the image to Firebase Storage
      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid;
      final storage = FirebaseStorage.instance;
      final Reference storageRef =
          storage.ref().child('profile_pictures').child(userId!);

      final UploadTask uploadTask = storageRef.putFile(
        _image!,
        SettableMetadata(
            contentType: 'image/jpeg'), // Set content type to image/jpeg
      );

      await uploadTask.whenComplete(() async {
        // Get the download URL of the uploaded image
        final String downloadURL = await storageRef.getDownloadURL();

        // Update the user's profile picture URL in Firestore
        await FirebaseFirestore.instance
            .collection('profile')
            .doc(userId)
            .update({'profilePictureUrl': downloadURL});
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    contactNumberController.dispose();
    residentNameController.dispose();
    residentRelationshipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _toggleEditing();
              } else {
                _toggleEditing();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfilePicturePicker(),
            SizedBox(height: 20),
            _buildSectionHeader('📝 Personal Information 📝'),
            SizedBox(height: 10),
            _buildTextField('Name', nameController),
            SizedBox(height: 10),
            _buildGenderSelection(),
            SizedBox(height: 10),
            _buildTextField('Contact Number', contactNumberController),
            SizedBox(height: 20),
            Text(
              '** Please note that according to PDPA, we will only use your personal data for business purpose.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false, bool isVisitorOrResidentID = false}) {
    Color inputFillColor =
        isVisitorOrResidentID ? Colors.grey[400]! : Colors.white;
    double inputWidth = 400.0;
    double inputHeight = 53.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontFamily: "SairaCondensed",
          ),
        ),
        SizedBox(height: 5),
        Container(
          width: inputWidth,
          height: inputHeight,
          child: TextField(
            controller: controller,
            enabled: _isEditing,
            readOnly: !_isEditing,
            obscureText: isPassword,
            style: TextStyle(
              fontSize: 16,
              fontFamily: "SairaCondensed",
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: EdgeInsets.all(10),
              filled: true,
              fillColor: inputFillColor,
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {bool showDivider = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        if (showDivider) Divider(),
      ],
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
          InkWell(
            onTap: _isEditing ? () => _pickImage() : null,
            child: Container(
              width: profilePictureSize,
              height: profilePictureSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle, // Set the shape to circular
                border: Border.all(color: Colors.grey),
                color: inputFillColor,
              ),
              child: Center(
                child: _image == null
                    ? (profilePictureUrl?.isNotEmpty ?? false
                        ? FutureBuilder(
                            // Use FutureBuilder to asynchronously load the image
                            future: precacheImage(
                                NetworkImage(profilePictureUrl!), context),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                // Once the image is loaded, display it
                                return ClipOval(
                                  child: Image.network(
                                    profilePictureUrl!,
                                    width: profilePictureSize,
                                    height: profilePictureSize,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              } else {
                                // While loading, you can display a loading indicator or a placeholder
                                return CircularProgressIndicator(); // Replace with your preferred loading indicator or placeholder
                              }
                            },
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
          )
        ],
      ),
    );
  }

  Widget _buildGenderSelection() {
    // Determine the colors for the Male and Female buttons based on the selectedGender
    Color maleButtonColor =
        selectedGender == 'Male' ? Colors.blue : Colors.grey;
    Color femaleButtonColor =
        selectedGender == 'Female' ? Colors.pink : Colors.grey;

    // Determine the text colors for the Male and Female buttons based on the selectedGender
    Color maleTextColor =
        selectedGender == 'Male' ? Colors.black : Colors.white;
    Color femaleTextColor =
        selectedGender == 'Female' ? Colors.black : Colors.white;

    double buttonWidth = MediaQuery.of(context).size.width * 0.4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: TextStyle(fontFamily: "SairaCondensed")),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isEditing
                  ? () {
                      setState(() {
                        selectedGender = 'Male';
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                primary: maleButtonColor,
                onPrimary: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(buttonWidth, 50),
              ),
              child: Text('🚹    Male',
                  style: TextStyle(
                    fontFamily: "SairaCondensed",
                    color: maleTextColor, // Use the determined text color
                  )),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: _isEditing
                  ? () {
                      setState(() {
                        selectedGender = 'Female';
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                primary: femaleButtonColor,
                onPrimary: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(buttonWidth, 50),
              ),
              child: Text('🚺    Female',
                  style: TextStyle(
                    fontFamily: "SairaCondensed",
                    color: femaleTextColor, // Use the determined text color
                  )),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }

  void main() {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfilePage(),
    ));
  }
}
