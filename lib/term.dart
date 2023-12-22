import 'package:flutter/material.dart';

class TermPage extends StatelessWidget {
  // Define a custom text style with the desired line spacing
  final TextStyle customTextStyle = TextStyle(
    fontSize: 16.0,
    color: Colors.black, // Set font color to black
    height: 1.5, // Set line height to 1.5
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '1. Introduction',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Set font color to black
              ),
            ),
            SizedBox(height: 8.0),
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: customTextStyle, // Apply custom text style
                children: <TextSpan>[
                  TextSpan(
                    text: '1.1 Overview\n',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Set font color to black
                    ),
                  ),
                  TextSpan(
                    text:
                        'These terms and conditions outline the rules and regulations for the use of our Nursing Home Management App. By accessing or using the app, you agree to comply with and be bound by these terms and conditions. If you do not agree with any part of these terms, you may not use the app.\n\n',
                  ),
                  TextSpan(
                    text: '1.2 Purpose\n',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Set font color to black
                    ),
                  ),
                  TextSpan(
                    text:
                        'The purpose of these terms is to set clear guidelines for using our Nursing Home Management App to ensure the safety, security, and well-being of residents and users.\n\n',
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              '2. Acceptance of Terms',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Set font color to black
              ),
            ),
            SizedBox(height: 8.0),
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: customTextStyle, // Apply custom text style
                children: <TextSpan>[
                  TextSpan(
                    text:
                        'By accessing or using the app, you agree to be bound by these terms and conditions. If you do not agree with any part of these terms, you may not use the app. Your continued use of the app following the posting of changes to these terms will mean that you accept those changes.\n\n',
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              '3. User Content and Responsibilities',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Set font color to black
              ),
            ),
            SizedBox(height: 8.0),
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: customTextStyle, // Apply custom text style
                children: <TextSpan>[
                  TextSpan(
                    text: '3.1 Content Responsibility\n',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Set font color to black
                    ),
                  ),
                  TextSpan(
                    text:
                        'You are solely responsible for any content you contribute to the app, including text, images, and other materials. You agree not to post or share any offensive, harmful, or unlawful content. This includes, but is not limited to, content that may invade the privacy of residents, promote discrimination, or violate any applicable laws.\n\n',
                  ),
                  TextSpan(
                    text: '3.2 User Conduct\n',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Set font color to black
                    ),
                  ),
                  TextSpan(
                    text:
                        'You agree to use the app in a manner consistent with all applicable laws and regulations. You shall not engage in any activity that disrupts or interferes with the functioning of the app or the use of the app by others. This includes, but is not limited to, attempting to gain unauthorized access to the app or its data, or using the app for any illegal or unauthorized purpose.\n\n',
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              '4. Privacy Policy',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Set font color to black
              ),
            ),
            SizedBox(height: 8.0),
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: customTextStyle, // Apply custom text style
                children: <TextSpan>[
                  TextSpan(
                    text: '4.1 Data Collection and Usage\n',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Set font color to black
                    ),
                  ),
                  TextSpan(
                    text:
                        'We are committed to protecting your privacy and the privacy of residents. Our Privacy Policy outlines how your personal information and resident data are collected, used, and secured. By using the app, you consent to the data practices described in our Privacy Policy.\n\n',
                  ),
                ],
              ),
            ),
            // Add more sections and content as needed
          ],
        ),
      ),
    );
  }
}
