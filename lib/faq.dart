import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQ'),
      ),
      body: ListView(
        children: <Widget>[
          FAQItem(
            question: 'What is LifeSpring about?',
            answer:
                'This app is designed to help manage nursing homes and ensure the well-being of residents.',
          ),
          FAQItem(
            question: 'How do I schedule a visiting appointment?',
            answer:
                'To schedule a visiting appointment, go to the bottom navigation bar and select "Visiting Appointment." Choose a date and time that is convenient for you.',
          ),
          FAQItem(
            question: 'How do I view my approved visitor pass?',
            answer:
                'To view your approved visitor pass, go to the bottom navigation bar and select "Viitor Pass." Select a pass and you need to do biometric authentication before getting the pass.',
          ),
          FAQItem(
            question: 'How do I access my medical records?',
            answer:
                'Accessing your medical records is easy. Visit the "Medical Records" section in the app. Here, you can view all medical records uploaded by the doctor. This information is vital for tracking your health and treatment history.',
          ),
          FAQItem(
            question: 'How can I communicate with a doctor?',
            answer:
                'To communicate with a doctor, use the "Communication Portal" in the app. You can send messages, ask questions, and discuss medical concerns securely. Doctors will respond to your queries through this platform, ensuring convenient healthcare access.',
          ),
          FAQItem(
            question:
                'What should I do if I encounter technical issues or need support?',
            answer:
                'If you encounter technical issues or require support, please visit the "Contact Us" section in the app. Here, you will find contact information for our support team. Reach out to us, and we will assist you promptly.',
          ),
          FAQItem(
            question: 'Is my personal information secure?',
            answer:
                'Yes, we take your privacy seriously. Your personal information is securely stored and protected. We adhere to strict data security measures to ensure the confidentiality of your data and compliance with privacy regulations.',
          ),
          FAQItem(
            question: 'How can I update my profile information?',
            answer:
                'To update your profile, go to the upper left corner and select "Profile." Here, you can edit your personal information, contact details, and preferences. Keeping your profile up to date helps us provide you with better service.',
          ),
        ],
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(answer),
        ),
      ],
    );
  }
}
