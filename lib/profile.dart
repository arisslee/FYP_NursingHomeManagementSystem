import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DateTime? selectedDate = DateTime.now();
  TextEditingController dobController = TextEditingController();
  TextEditingController visitorIdController = TextEditingController();
  TextEditingController residentIdController = TextEditingController();
  TextEditingController residentNameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String selectedGender = '';
  bool _isEditing = false;
  final Map<TextEditingController, String> originalValues = {};
  File? _image; // Holds the selected image file
  final picker = ImagePicker();

  void _toggleEditing() {
    setState(() {
      if (_isEditing) {
        // Save changes logic here
        _isEditing = false;

        // Update the original values after saving changes
        originalValues[visitorIdController] = visitorIdController.text;
        originalValues[residentIdController] = residentIdController.text;
        originalValues[residentNameController] = residentNameController.text;
        originalValues[contactNumberController] = contactNumberController.text;
        originalValues[emailController] = emailController.text;
        originalValues[passwordController] = passwordController.text;
        // ... (update other fields as needed)
      } else {
        _isEditing = true;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate!,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate)
      dobController.text = "${picked.toLocal()}".split(' ')[0];
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    // ... (existing code)
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
                // Save changes logic here
                _toggleEditing(); // Exit edit mode after saving
              } else {
                _toggleEditing(); // Enter edit mode
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
            _buildTextField(
                '**Visitor ID (For Staff Use Only)', visitorIdController,
                isVisitorOrResidentID: true),
            SizedBox(height: 10),
            _buildTextField('Name', TextEditingController()),
            SizedBox(height: 10),
            _buildGenderSelection(), // Use the new method for gender selection
            SizedBox(height: 10),
            _buildDateOfBirthPicker(context),
            SizedBox(height: 10),
            _buildTextField('Contact Number', TextEditingController()),
            SizedBox(height: 20),
            _buildSectionHeader('🔒 Account Information 🔒'),
            SizedBox(height: 10),
            _buildTextField('Email', TextEditingController()),
            SizedBox(height: 10),
            _buildPasswordField('Password', TextEditingController()),
            SizedBox(height: 20),
            _buildSectionHeader('👴🏻 Residential Information 👵🏻'),
            SizedBox(height: 10),
            _buildTextField(
                '**Resident ID (For Staff Use Only)', residentIdController,
                isVisitorOrResidentID: true),
            SizedBox(height: 10),
            _buildTextField('Resident Name', residentNameController),
            SizedBox(height: 10),
            _buildTextField(
                'Relationship to Resident', TextEditingController()),
            SizedBox(height: 20),
            _buildSectionHeader('✨ Additional Information ✨'),
            SizedBox(height: 10),
            _buildTextField('Emergency Contact Name', TextEditingController()),
            SizedBox(height: 10),
            _buildTextField(
                'Emergency Contact Number', TextEditingController()),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController? controller,
      {bool isPassword = false, bool isVisitorOrResidentID = false}) {
    Color inputFillColor = isVisitorOrResidentID
        ? Colors.grey[400]!
        : Colors.white; // Adjust the fill color for Visitor ID and Resident ID
    double inputWidth =
        400.0; // Adjust the width to match the other input fields
    double inputHeight = 53.0; // Set the common input height

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
            enabled: _isEditing, // Enable editing based on _isEditing state
            readOnly: !_isEditing, // Disable editing if not in editing mode
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
        if (showDivider) Divider(), // Optional divider
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
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
                color: inputFillColor,
              ),
              child: Center(
                child: _image == null
                    ? Text(
                        'Upload Profile Picture',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: "SairaCondensed"),
                      )
                    : ClipRRect(
                        borderRadius:
                            BorderRadius.circular(profilePictureSize / 2),
                        child: Image.file(_image!),
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDateOfBirthPicker(BuildContext context) {
    Color inputFillColor = Colors.white;
    double inputWidth = 400.0;
    double inputHeight = 53.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date of Birth', style: TextStyle(fontFamily: "SairaCondensed")),
        SizedBox(height: 5),
        Container(
          width: inputWidth,
          height: inputHeight,
          child: GestureDetector(
            onTap: _isEditing ? () => _selectDate(context) : null,
            child: AbsorbPointer(
              absorbing: !_isEditing,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey),
                  color: inputFillColor,
                ),
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dobController.text,
                      style: TextStyle(fontFamily: "SairaCondensed"),
                    ),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController? controller) {
    return TextField(
      controller: controller,
      enabled: _isEditing, // Enable editing based on _isEditing state
      readOnly: !_isEditing, // Disable editing if not in editing mode
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.all(10),
      ),
    );
  }

  Widget _buildGenderSelection() {
    Color maleButtonColor =
        selectedGender == 'Male' ? Colors.blue : Colors.grey;
    Color femaleButtonColor =
        selectedGender == 'Female' ? Colors.pink : Colors.grey;

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
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(buttonWidth, 50),
              ),
              child: Text('🚹    Male',
                  style: TextStyle(fontFamily: "SairaCondensed")),
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
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(buttonWidth, 50),
              ),
              child: Text('🚺    Female',
                  style: TextStyle(fontFamily: "SairaCondensed")),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProfilePage(),
  ));
}
