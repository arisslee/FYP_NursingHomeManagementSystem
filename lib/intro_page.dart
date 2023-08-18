import 'package:flutter/material.dart';
import 'home.dart'; // Import the HomePage

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  double opacity = 0.0; // Initial opacity

  @override
  void initState() {
    super.initState();
    // Trigger animation after a short delay (you can adjust the duration as needed)
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        opacity = 1.0; // Change opacity to 1 to trigger fade-in animation
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome Page'),
      ),
      body: _buildIntroPageContent(context), // Pass the context to the method
    );
  }

  Widget _buildIntroPageContent(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Fade-in animation for the image
            AnimatedOpacity(
              duration: Duration(seconds: 1),
              opacity: opacity,
              child: Image.asset(
                'assets/logo.png', // Replace with your image asset
                width: 320,
                height: 320,
              ),
            ),
            // Fade-in animation for the text
            AnimatedOpacity(
              duration: Duration(seconds: 1),
              opacity: opacity,
              child: Text(
                'Your Trusted Old Folks Home Management System',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            // Fade-in animation for the container
            AnimatedOpacity(
              duration: Duration(seconds: 1),
              opacity: opacity,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 135, 134, 134)
                          .withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey[500]!,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'LifeSpring is designed to provide comprehensive and efficient management for old folks homes.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'We always ensure seniors comfort and streamlining operations for enhanced care.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            // Add animation and transition
            AnimatedOpacity(
              duration: Duration(seconds: 1),
              opacity: opacity,
              child: AnimatedContainer(
                duration: Duration(seconds: 2),
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  },
                  child: Center(
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: IntroPage(),
  ));
}
