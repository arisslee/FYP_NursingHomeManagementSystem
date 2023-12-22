import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'home.dart';
import 'staff_home.dart';
import 'doctor_home.dart';
import 'intro_page.dart';
import 'visiting_appointment.dart';
import 'register.dart';

// Define dbRef here as a global variable
final dbRef = FirebaseDatabase.instance.reference().child("users");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? email;
  String? password;
  String? errorMessage = '';
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  void _login() async {
    email = emailController.text;
    password = passwordController.text;

    if (email != null && password != null) {
      if (email!.isEmpty && password!.isEmpty) {
        setState(() {
          errorMessage = 'Please enter your email and password';
        });
      } else if (email!.isEmpty) {
        setState(() {
          errorMessage = 'Please enter your email';
        });
      } else if (password!.isEmpty) {
        setState(() {
          errorMessage = 'Please enter your password';
        });
      } else {
        if (!email!.contains('@')) {
          setState(() {
            errorMessage = 'Invalid email format';
          });
        } else {
          // Check for the specific email and password for Doctor
          if (email == 'doctor@lifespring.com' && password == 'doctor') {
            // Navigate to DoctorHomePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorHomePage(),
              ),
            );
          }
          // Check for the specific email and password for Staff
          else if (email == 'staff@lifespring.com' && password == 'staff') {
            // Navigate to StaffHomePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StaffHomePage(),
              ),
            );
          }
          // For other cases, follow your existing logic
          else {
            try {
              var userCredential = await _auth.signInWithEmailAndPassword(
                email: email!,
                password: password!,
              );

              if (userCredential.user != null) {
                final User? user = await _auth.currentUser;
                final userID = user?.uid;

                try {
                  // Corrected curly brace location
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IntroPage(),
                    ),
                  );
                } catch (e) {
                  // Handle any errors that occurred during Firestore fetch.
                  print("Error fetching data: $e");
                }
              } else {
                setState(() {
                  errorMessage = 'Invalid email or password';
                });
              }
            } on FirebaseAuthException catch (e) {
              print("FirebaseAuthException: ${e.code}");
              if (e.code == 'user-not-found' || e.code == 'wrong-password') {
                setState(() {
                  errorMessage = 'Invalid email or password';
                });
              } else {
                setState(() {
                  errorMessage = 'Login failed';
                });
              }
            }
          }
        }
      }
    } else {
      setState(() {
        errorMessage = 'Please enter your email and password';
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/login.png', // Adjust the image file name
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment(0, 0.8),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    '❤️ LifeSpring ❤️',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: "MarckScript",
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildTextField('Email', emailController,
                      iconData: Icons.email),
                  SizedBox(height: 10),
                  _buildTextField('Password', passwordController,
                      isPassword: true, iconData: Icons.lock),
                  SizedBox(height: 20),
                  _buildButton(
                      context, 'Login', _login), // Use the _login method
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: "Register Now!",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterPage()),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false, IconData? iconData}) {
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

  Widget _buildButton(
    BuildContext context,
    String label,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
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
              label,
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
    );
  }
}
