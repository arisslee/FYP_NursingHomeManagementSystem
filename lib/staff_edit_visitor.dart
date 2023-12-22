import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

class StaffEditVisitorPage extends StatefulWidget {
  final String? visitorId;

  StaffEditVisitorPage({this.visitorId});

  @override
  _StaffEditVisitorPageState createState() => _StaffEditVisitorPageState();
}

class _StaffEditVisitorPageState extends State<StaffEditVisitorPage> {
  TextEditingController nameController = TextEditingController();
  String selectedGender = '';
  TextEditingController contactNumberController = TextEditingController();
  String? _profilePictureUrl; // Use String for profile picture URL
  File? _image; // Add this line for storing the picked image
  final picker = ImagePicker();
  bool isEditMode = false; // Track the current mode
  double buttonWidth = 150.0; // Define a smaller buttonWidth here

  @override
  void initState() {
    super.initState();
    // Fetch the visitor's data when the page is initialized
    fetchVisitorData(widget.visitorId);
  }

  void _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> fetchVisitorData(String? visitorId) async {
    if (visitorId != null) {
      // Replace with your Firebase database query
      final database = FirebaseFirestore.instance;
      final DocumentSnapshot document =
          await database.collection('profile').doc(visitorId).get();

      if (document.exists) {
        final data = document.data() as Map<String, dynamic>;
        nameController.text = data['name'];
        contactNumberController.text = data['contactNumber'];

        // Fetch gender and profilePictureUrl
        String? gender = data['gender'];
        _profilePictureUrl = data['profilePictureUrl']; // Assign the URL

        if (gender != null) {
          setState(() {
            selectedGender = gender;
          });
        }

        // Fetch and update more visitor data as needed
      }
    } else {
      // Handle the case when visitorId is null
      // You can choose to show an error message or navigate back to the previous page.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Visitor'),
        actions: [
          // Toggle the edit mode when the icon is pressed
          IconButton(
            icon: isEditMode ? Icon(Icons.save) : Icon(Icons.edit),
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
              });
              // If exiting edit mode, save changes here
              if (!isEditMode) {
                saveChanges();
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
            if (isEditMode) _buildGenderSelection(),
            if (!isEditMode) _buildGenderDisplay(),
            SizedBox(height: 10),
            _buildTextField('Contact Number', contactNumberController),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    Color inputFillColor = Colors.white;
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
              enabled:
                  isEditMode, // Disable the input field when not in edit mode
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Divider(),
      ],
    );
  }

  Widget _buildGenderSelection() {
    Color maleButtonColor =
        selectedGender == 'Male' ? Colors.blue : Colors.grey;
    Color femaleButtonColor =
        selectedGender == 'Female' ? Colors.pink : Colors.grey;
    Color maleTextColor =
        selectedGender == 'Male' ? Colors.black : Colors.white;
    Color femaleTextColor =
        selectedGender == 'Female' ? Colors.black : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: TextStyle(fontFamily: "SairaCondensed")),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedGender = 'Male';
                });
              },
              style: ElevatedButton.styleFrom(
                primary: maleButtonColor,
                onPrimary: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(buttonWidth, 50),
              ),
              child: Text('🚹 Male',
                  style: TextStyle(
                    fontFamily: "SairaCondensed",
                    color: maleTextColor,
                  )),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedGender = 'Female';
                });
              },
              style: ElevatedButton.styleFrom(
                primary: femaleButtonColor,
                onPrimary: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(buttonWidth, 50),
              ),
              child: Text('🚺 Female',
                  style: TextStyle(
                    fontFamily: "SairaCondensed",
                    color: femaleTextColor,
                  )),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildGenderDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: TextStyle(fontFamily: "SairaCondensed")),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: null, // Set onPressed to null to make it uneditable
              style: ElevatedButton.styleFrom(
                primary: selectedGender == 'Male' ? Colors.blue : Colors.grey,
                onPrimary: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(buttonWidth, 50),
              ),
              child: Text(
                '🚹 Male',
                style: TextStyle(
                  fontFamily: "SairaCondensed",
                  color: selectedGender == 'Male' ? Colors.black : Colors.white,
                ),
              ),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: null, // Set onPressed to null to make it uneditable
              style: ElevatedButton.styleFrom(
                primary: selectedGender == 'Female' ? Colors.pink : Colors.grey,
                onPrimary: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(buttonWidth, 50),
              ),
              child: Text(
                '🚺 Female',
                style: TextStyle(
                  fontFamily: "SairaCondensed",
                  color:
                      selectedGender == 'Female' ? Colors.black : Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
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
            onTap: () {
              // Fetch the image from the database when tapped
              if (_profilePictureUrl != null) {
                // Handle displaying the image here, e.g., open a dialog to show the image in full-screen.
              }
            },
            child: Container(
              width: profilePictureSize,
              height: profilePictureSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
                color: inputFillColor,
              ),
              child: Center(
                child: _profilePictureUrl == null
                    ? Text(
                        'No Profile Picture Available',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: "SairaCondensed"),
                      )
                    : ClipOval(
                        child: CachedNetworkImage(
                          // Use CachedNetworkImage to load the URL
                          imageUrl: _profilePictureUrl!,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
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

  // Function to save changes to the database
  void saveChanges() {
    String name = nameController.text;
    String contactNumber = contactNumberController.text;

    // Update the visitor's data in your database (e.g., Firebase Firestore)
    final database = FirebaseFirestore.instance;
    database.collection('profile').doc(widget.visitorId).update({
      'name': name,
      'contactNumber': contactNumber,

      'gender': selectedGender, // Add this line to update the gender
      // Update more fields as needed
    });
  }

  void main() {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StaffEditVisitorPage(
          visitorId: 'visitor_document_id'), // Provide the visitor ID here
    ));
  }
}
