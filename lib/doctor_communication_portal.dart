import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class DoctorCommunicationPortalPage extends StatefulWidget {
  final String userName;
  final String userUID;

  DoctorCommunicationPortalPage({
    required this.userName,
    required this.userUID,
  });

  @override
  _DoctorCommunicationPortalPageState createState() =>
      _DoctorCommunicationPortalPageState();
}

class _DoctorCommunicationPortalPageState
    extends State<DoctorCommunicationPortalPage> {
  List<ChatMessage> _chatMessages = [];
  List<dynamic> _filteredMessages = [];

  String _currentUserId = '';
  final ScrollController _scrollController = ScrollController();

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  void initState() {
    super.initState();
    _currentUserId = 'doctor'; // Set a unique ID for the doctor
    _fetchChatHistory();
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollToBottom();
    });
  }

  // Add this method
  // Add this method
  void _fetchChatHistory() {
    FirebaseFirestore.instance
        .collection('user_chat')
        .doc(widget.userUID)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen((snapshot) {
      _chatMessages.clear();
      _filteredMessages.clear();
      DateTime? currentDate;

      for (var messageSnapshot in snapshot.docs) {
        final messageData = messageSnapshot.data() as Map<String, dynamic>;
        final chatMessage = ChatMessage(
          message: messageData['message'],
          isUser: messageData['isUser'],
          timestamp: (messageData['timestamp'] as Timestamp).toDate(),
          isImage: messageData['isImage'],
          onDelete: () {},
        );

        _chatMessages.add(chatMessage);

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
    });
  }

  // Add this method
  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _sendMessage(ChatMessage message) {
    setState(() {
      _chatMessages.add(message);
      _filteredMessages
          .add(message); // Add the message to filtered messages as well
    });

    // Scroll to the bottom and slightly beyond to ensure the latest message is visible.
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    // Store the text message in Firestore with the user UID as chat ID
    FirebaseFirestore.instance
        .collection('user_chat')
        .doc(widget.userUID) // Use user UID as chat ID
        .collection('messages')
        .add({
      'message': message.message,
      'isUser': false, // Set isUser to false for messages sent by the doctor
      'timestamp': Timestamp.fromDate(message.timestamp),
      'isImage': message.isImage,
    }).then((value) {
      print("Text message added to Firestore with ID: ${value.id}");
    }).catchError((error) {
      print("Error adding text message to Firestore: $error");
    });
  }

  void _deleteMessage(int index) {
    setState(() {
      _chatMessages.removeAt(index);
      _filteredMessages
          .removeAt(index); // Remove the message from filtered messages
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
      ChatMessage chatMessage = ChatMessage(
        message: pickedImage.path,
        isUser: true,
        timestamp: DateTime.now(),
        isImage: true,
        onDelete: () => _deleteMessage(_chatMessages.length),
      );
      _sendMessage(chatMessage);
    }
  }

  Widget _buildMessageOrSeparator(int index) {
    final message = _filteredMessages[index];

    if (message is DateSeparator) {
      return DateSeparator(date: message.date);
    } else if (message is ChatMessage) {
      return ChatMessage(
        message: message.message,
        isUser: message.isUser,
        timestamp: message.timestamp,
        isImage: message.isImage,
        onDelete: () => _deleteMessage(index),
      );
    } else {
      return Container(); // Return an empty container if the type is unknown
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userName}'),
        //title: Text('${widget.userName} - ${widget.userUID}'),
      ),
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
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final bool isImage;
  final VoidCallback onDelete;

  ChatMessage({
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
                    bottom: 8.0,
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
            isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          if (!isImage)
            Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Color.fromARGB(255, 159, 212, 255)
                              : Color.fromARGB(255, 209, 208, 208),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message,
                          style: TextStyle(
                            color: isUser ? Colors.black : Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                      bottom: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(timestamp),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (isImage)
            Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: EdgeInsets.all(8),
                        child: Image.file(
                          File(message),
                          width: 150,
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                      bottom: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(timestamp),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void main() {
    runApp(MaterialApp(
      home: DoctorCommunicationPortalPage(
        userName: 'John Doe',
        userUID: '123',
      ),
    ));
  }
}
