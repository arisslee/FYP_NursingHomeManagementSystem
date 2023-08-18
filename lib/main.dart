//import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'home.dart';
import 'intro_page.dart';
import 'visiting_appointment.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
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

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                        fontFamily: "MarckScript"),
                  ),
                  SizedBox(height: 20),
                  _buildTextField('Email', emailController,
                      iconData: Icons.email),
                  SizedBox(height: 10),
                  _buildTextField('Password', passwordController,
                      isPassword: true, iconData: Icons.lock),
                  SizedBox(height: 20),
                  _buildButton(context, 'Login', () {
                    // Replace this with your login logic
                    // For demonstration purposes, let's assume the login is successful and we navigate to the IntroPage:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              IntroPage()), // Navigate to IntroPage
                    );
                  }),
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
      BuildContext context, String label, VoidCallback onPressed) {
    return ElevatedButton(
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
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void _register() {
    // Add your registration logic here
    // For demonstration purposes, let's assume the registration is successful

    // Navigate back to the LoginPage
    Navigator.pop(context);
  }

  @override
  void dispose() {
    fullNameController.dispose();
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
              _buildTextField('Full Name', fullNameController),
              SizedBox(height: 10),
              _buildTextField('Email', emailController),
              SizedBox(height: 10),
              _buildTextField('Phone Number', phoneNumberController),
              SizedBox(height: 10),
              _buildTextField('Password', passwordController, isPassword: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register, // Call the registration function
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    // Define the icon data
    IconData? iconData;
    if (label == 'Full Name') {
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

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
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
      ),
    );
  }
}
