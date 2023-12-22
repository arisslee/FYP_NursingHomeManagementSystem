import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class MyUser {
  String? id; // Firestore document ID
  String name;
  String email;
  String phone;
  String password;

  MyUser({
    this.id, // Initialize it in the constructor
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }
}

class _RegisterPageState extends State<RegisterPage> {
  String? email;
  String? password;
  String? errorMessage;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  Future createUser(String name, String email, String phone, String password,
      String userUID) async {
    await FirebaseFirestore.instance.collection('users').add({
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'userUID': userUID,
    });
  }

  Future _register() async {
    try {
      // Get input values from controllers
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final phone = phoneNumberController.text.trim();
      final password = passwordController.text.trim();

      // Check for input validation
      if (name.isEmpty || !name.contains(RegExp(r'^[a-zA-Z ]+$'))) {
        setState(() {
          errorMessage =
              'Name is required and should contain only alphabets and spaces';
        });
        return;
      }

      if (email.isEmpty || !email.contains('@')) {
        setState(() {
          errorMessage = 'Invalid email format';
        });
        return;
      }

      if (phone.isEmpty || !phone.contains(RegExp(r'^[0-9]+$'))) {
        setState(() {
          errorMessage =
              'Phone Number is required and should contain only numbers';
        });
        return;
      }

      if (password.isEmpty || password.length < 6) {
        setState(() {
          errorMessage =
              'Password is required and should be at least 6 characters long';
        });
        return;
      }

      var userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Registration successful, navigate back to the LoginPage
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account successfully registered!'),
            duration: Duration(seconds: 3),
          ),
        );

        // Extract userUID
        final userUID = userCredential.user!.uid;

        // Create User
        createUser(
          name,
          email,
          phone,
          password,
          userUID, // Pass the userUID
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'The account already exists';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Invalid email address';
        } else {
          errorMessage = 'An error occurred while registering';
        }
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Name', nameController),
              SizedBox(height: 10),
              _buildTextField('Email', emailController),
              SizedBox(height: 10),
              _buildTextField('Phone Number', phoneNumberController),
              SizedBox(height: 10),
              _buildTextField('Password', passwordController, isPassword: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _register(); // Pass the context
                }, // Use the _register method
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  elevation: 5,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _buildErrorMessage(), // Add this widget to display the error message
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    print("errorMessage: $errorMessage");
    if (errorMessage == null || errorMessage!.isEmpty) {
      return SizedBox.shrink();
    } else {
      return Center(
        // Wrap the error message with Center
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            errorMessage!,
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    // Define the icon data
    IconData? iconData;
    if (label == 'Name') {
      iconData = Icons.person;
    } else if (label == 'Email') {
      iconData = Icons.email;
    } else if (label == 'Phone Number') {
      iconData = Icons.phone;
    } else if (label == 'Password' && isPassword) {
      iconData = Icons.lock;
    }

    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.all(15),
        prefixIcon: iconData != null
            ? Icon(
                iconData,
                color: Colors.blue, // Set the color of the icon
              )
            : null,
      ),
    );
  }
}
