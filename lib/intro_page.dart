import 'package:flutter/material.dart';
import 'home.dart'; // Import the HomePage
import 'package:carousel_slider/carousel_slider.dart'; // Import the carousel_slider package

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  double opacity = 0.0; // Initial opacity
  int _currentPage = 0;

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

  Widget _buildPage(String imagePath) {
    return Container(
      child: Transform.scale(
        scale: 1.0,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to LifeSpring'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: _buildIntroPageContent(context),
        ),
      ),
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
                width: 250,
                height: 250,
              ),
            ),
            // Fade-in animation for the text
            AnimatedOpacity(
              duration: Duration(seconds: 1),
              opacity: opacity,
              child: Text(
                'Your Trusted Nursing Home Management System',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),

            // Fade-in animation for the CarouselSlider
            AnimatedOpacity(
              duration: Duration(seconds: 1),
              opacity: opacity,
              child: CarouselSlider(
                items: [
                  _buildPage('assets/welcome_surrounding.png'),
                  _buildPage('assets/welcome_staff.png'),
                  _buildPage('assets/welcome_activities.png'),
                  _buildPage('assets/welcome_medical.png'),
                ],
                options: CarouselOptions(
                  height: 330,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                ),
              ),
            ),

            // Add animation and transition for the "Get Started" button
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
