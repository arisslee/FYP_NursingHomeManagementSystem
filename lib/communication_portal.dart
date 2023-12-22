import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class CommunicationPortalPage extends StatefulWidget {
  @override
  _CommunicationPortalPageState createState() =>
      _CommunicationPortalPageState();
}

bool _isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

class DateSeparator extends StatelessWidget {
  final DateTime date;

  DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Text(
        DateFormat('dd MMMM yyyy').format(date),
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CommunicationPortalPageState extends State<CommunicationPortalPage> {
  List<ChatMessage> _chatMessages = [];
  List<Widget> _filteredMessages = [];
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Initialize Firestore
  String _currentChatId = '';
  String _currentUserId = '';

  void _sendMessage(ChatMessage message) {
    setState(() {
      _chatMessages.add(message);
      _filteredMessages.add(message);
    });

    // Scroll to the bottom and slightly beyond to ensure the latest message is visible.
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    // Store the text message in Firestore with the user ID as chat ID
    _firestore
        .collection('user_chat')
        .doc(_currentUserId) // Use user ID as chat ID
        .collection('messages')
        .add({
      'message': message.message,
      'isUser': message.isUser,
      'timestamp': Timestamp.fromDate(message.timestamp),
      'isImage': false,
    }).then((value) {
      print("Text message added to Firestore with ID: ${value.id}");
    }).catchError((error) {
      print("Error adding text message to Firestore: $error");
    });
  }

  @override
  void initState() {
    super.initState();
    _currentUserId = _getUserId(); // Retrieve the user ID after login
    _currentChatId = 'common_chat'; // Set a common chat ID
    _fetchChatHistory();
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollToBottom();
    });
  }

  // Function to retrieve the user ID after login
  String _getUserId() {
    // Use Firebase Authentication to get the current user's UID
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? 'default_user_id';
  }

  // Function to generate a unique chat ID
  String _generateUniqueChatId() {
    // Implement your logic to create a unique ID (e.g., user IDs, timestamp, etc.)
    return 'unique_chat_id'; // Replace with your logic
  }

  // Scroll to the bottom of the chat list
  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _fetchChatHistory() {
    _firestore
        .collection('user_chat')
        .doc(_currentUserId) // Use user ID as chat ID
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen(
      (snapshot) {
        _chatMessages.clear();
        _filteredMessages.clear();
        DateTime? currentDate;

        for (var messageSnapshot in snapshot.docs) {
          final messageData = messageSnapshot.data() as Map<String, dynamic>;
          final chatMessage = ChatMessage(
            id: messageSnapshot.id,
            message: messageData['message'],
            isUser: messageData['isUser'],
            timestamp: (messageData['timestamp'] as Timestamp).toDate(),
            isImage: messageData['isImage'],
            onDelete: () {},
          );

          // Check if the date has changed, and add DateSeparator accordingly
          if (currentDate == null ||
              !_isSameDay(currentDate, chatMessage.timestamp)) {
            currentDate = chatMessage.timestamp;
            final dateSeparator = DateSeparator(date: currentDate!);
            _filteredMessages.add(dateSeparator);
          }

          _filteredMessages.add(chatMessage);
        }
        setState(() {
          // Update the UI with fetched messages
        });

        // Scroll to the bottom
        _scrollToBottom();
      },
    );
  }

  void _deleteMessage(int index) {
    final messageToDelete = _chatMessages[index]; // Get the message to delete

    setState(() {
      _chatMessages.removeAt(index);
      _filteredMessages
          .removeAt(index); // Remove the message from filtered messages
    });

    // Delete the message from Firestore using its document ID
    _firestore
        .collection('user_chat')
        .doc(messageToDelete.id)
        .delete()
        .then((_) {
      print('Message deleted from Firestore');
    }).catchError((error) {
      print('Error deleting message from Firestore: $error');
    });
  }

  // Implement a search functionality
  void _searchMessages(String query) {
    setState(() {
      _filteredMessages = _chatMessages
          .where((message) => message.message.contains(query))
          .toList();
    });
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      // Add the message to Firestore with the chat ID
      DocumentReference docRef = await _firestore
          .collection('user_chat')
          .doc(_currentChatId)
          .collection('messages')
          .add({
        'message': pickedImage.path,
        'isUser': true,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'isImage': true,
      });

      ChatMessage chatMessage = ChatMessage(
        id: docRef.id, // Use the ID generated by Firestore
        message: pickedImage.path,
        isUser: true,
        timestamp: DateTime.now(),
        isImage: true,
        onDelete: () =>
            _deleteMessage(_chatMessages.length), // Provide onDelete callback
      );

      // Send the message to the UI and add it to the lists
      if (!chatMessage.isImage) {
        _sendMessage(chatMessage);
      }
    }
  }

  Widget _buildMessageOrSeparator(int index) {
    final item = _filteredMessages[index];
    if (item is ChatMessage) {
      return item;
    } else if (item is DateSeparator) {
      return item;
    }
    return Container(); // You can customize this part based on your requirements
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/background.png', // Replace with your image path
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Column(
            children: [
              // Add a search bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: _searchMessages,
                  decoration: InputDecoration(
                    hintText: 'Search messages...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _filteredMessages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageOrSeparator(index);
                  },
                ),
              ),
              ChatInputArea(
                onMessageSent: _sendMessage,
                onImagePick: _pickImage,
                onDelete: () => _deleteMessage(_chatMessages.length),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatInputArea extends StatefulWidget {
  final Function(ChatMessage) onMessageSent;
  final Function() onImagePick;
  final Function() onDelete; // Add onDelete here

  ChatInputArea(
      {required this.onMessageSent,
      required this.onImagePick,
      required this.onDelete});

  @override
  _ChatInputAreaState createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  TextEditingController _textEditingController = TextEditingController();
  String _message = '';
  String _id = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // IconButton(
            //   icon: Icon(Icons.photo),
            //   onPressed: widget.onImagePick,
            // ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: _textEditingController,
                  onChanged: (value) {
                    setState(() {
                      _message = value;
                    });
                  },
                  onSubmitted: (value) {
                    if (_message.isNotEmpty) {
                      ChatMessage chatMessage = ChatMessage(
                        id: _id,
                        message: _message,
                        isUser: true,
                        timestamp: DateTime.now(),
                        onDelete: () => widget.onDelete(),
                      );

                      widget.onMessageSent(chatMessage);

                      _textEditingController.clear();
                      setState(() {
                        _message = '';
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                if (_message.isNotEmpty) {
                  ChatMessage chatMessage = ChatMessage(
                    id: _id,
                    message: _message,
                    isUser: true,
                    timestamp: DateTime.now(),
                    onDelete: () => widget.onDelete(),
                  );

                  widget.onMessageSent(chatMessage);

                  _textEditingController.clear();
                  setState(() {
                    _message = '';
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class ChatMessage extends StatelessWidget {
  String id; // Add this line
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final bool isImage;
  final VoidCallback onDelete;

  ChatMessage({
    required this.id, // Add this line
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.isImage = false,
    required this.onDelete,
  });

  void _viewImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(''),
            ),
            body: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PhotoView(
                      imageProvider: FileImage(File(message)),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                      backgroundDecoration: BoxDecoration(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: Text(
                    DateFormat('HH:mm').format(timestamp),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Message'),
          content: Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                onDelete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _showDeleteConfirmation(context);
      },
      onTap: () {
        if (isImage) {
          _viewImage(context);
        }
      },
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isImage)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isUser
                      ? Color.fromARGB(255, 159, 212, 255)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(message),
              ),
            ),
          if (isImage)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Image.file(
                File(message),
                width: 150,
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: isUser
                    ? const EdgeInsets.only(right: 16.0)
                    : const EdgeInsets.only(left: 16.0),
                child: Text(
                  DateFormat('HH:mm').format(timestamp),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CommunicationPortalPage(),
  ));
}
