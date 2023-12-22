import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StaffAddVisitorPage extends StatefulWidget {
  @override
  _StaffAddVisitorPageState createState() => _StaffAddVisitorPageState();
}

class _StaffAddVisitorPageState extends State<StaffAddVisitorPage> {
  TextEditingController nameController = TextEditingController();
  String selectedGender = '';
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController residentNameController = TextEditingController();
  TextEditingController residentRelationshipController =
      TextEditingController();
  File? _image;
  final picker = ImagePicker();
  bool isEditMode = true;

  String nameError = '';
  String contactNumberError = '';
  String residentNameError = '';
  String residentRelationshipError = '';

  // Function to handle image selection
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Visitor'),
        actions: [],
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfilePicturePicker(),
                SizedBox(height: 20),
                _buildSectionHeader('📝 Personal Information 📝'),
                SizedBox(height: 10),
                _buildTextField('Name', nameController, nameError),
                SizedBox(height: 10),
                _buildGenderSelection(),
                SizedBox(height: 10),
                _buildTextField('Contact Number', contactNumberController,
                    contactNumberError),
                SizedBox(height: 20),
                _buildSectionHeader('👴🏻 Residential Information 👵🏻'),
                SizedBox(height: 10),
                _buildTextField(
                    'Resident Name', residentNameController, residentNameError),
                SizedBox(height: 10),
                _buildTextField('Relationship to Resident',
                    residentRelationshipController, residentRelationshipError),
                SizedBox(height: 20),
                _buildAddButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String errorText) {
    Color inputFillColor = Colors.white;

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
        TextField(
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
            enabled: isEditMode,
            errorText: errorText.isNotEmpty
                ? errorText
                : null, // Show the error message in red
            errorStyle: TextStyle(
              color: Colors.red, // Set error text color to red
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
    String genderError =
        selectedGender.isEmpty ? '   Please select a gender' : '';

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
                minimumSize: Size(MediaQuery.of(context).size.width * 0.4, 50),
              ),
              child: Text('🚹 Male',
                  style: TextStyle(
                      fontFamily: "SairaCondensed", color: maleTextColor)),
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
                minimumSize: Size(MediaQuery.of(context).size.width * 0.4, 50),
              ),
              child: Text('🚺 Female',
                  style: TextStyle(
                      fontFamily: "SairaCondensed", color: femaleTextColor)),
            ),
          ],
        ),
        if (genderError.isNotEmpty) SizedBox(height: 10),
        Text(genderError, style: TextStyle(color: Colors.red, fontSize: 12)),
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
              // Handle selecting a profile picture when tapped
              _pickImage(); // Invoke the image picker
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
                child: _image == null
                    ? Icon(
                        Icons.add_a_photo, // Replace with the desired icon
                        size: 60, // Adjust the size as needed
                        color: Colors.grey, // Add your preferred color
                      )
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

  Widget _buildAddButton() {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = screenWidth * 0.8;

    return Center(
      child: Container(
        width: buttonWidth,
        child: ElevatedButton(
          onPressed: () {
            // Handle the submission of data here
            final String name = nameController.text;
            final String contactNumber = contactNumberController.text;
            final String residentName = residentNameController.text;
            final String residentRelationship =
                residentRelationshipController.text;

            // Input validation
            setState(() {
              nameError = name.isEmpty
                  ? 'Name is required'
                  : !_validateName(name)
                      ? 'Name should contain only alphabets'
                      : '';
              contactNumberError = contactNumber.isEmpty
                  ? 'Contact Number is required'
                  : _validateContactNumber(contactNumber)
                      ? ''
                      : 'Contact Number should contain only numbers';
              residentNameError = residentName.isEmpty
                  ? 'Resident Name is required'
                  : !_validateName(residentName)
                      ? 'Resident Name should contain only alphabets'
                      : '';
              residentRelationshipError = residentRelationship.isEmpty
                  ? 'Relationship is required'
                  : !_validateName(residentRelationship)
                      ? 'Relationship should contain only alphabets'
                      : '';
            });

            if (nameError.isEmpty &&
                selectedGender.isNotEmpty &&
                contactNumberError.isEmpty &&
                residentNameError.isEmpty &&
                residentRelationshipError.isEmpty) {
              // All data is valid, you can proceed
              if (_image != null) {
                // Upload the selected image
              }
              // Proceed with other actions
            }
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
            onPrimary: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('Add', style: TextStyle(fontSize: 18.0)),
          ),
        ),
      ),
    );
  }

  bool _validateName(String value) {
    final namePattern = RegExp(r'^[a-zA-Z]+$');
    return namePattern.hasMatch(value);
  }

  bool _validateContactNumber(String value) {
    final phonePattern = RegExp(r'^[0-9]+$');
    return phonePattern.hasMatch(value);
  }
}
