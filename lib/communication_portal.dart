import 'package:flutter/material.dart';

class CommunicationPortalPage extends StatefulWidget {
  @override
  _CommunicationPortalPageState createState() =>
      _CommunicationPortalPageState();
}

class _CommunicationPortalPageState extends State<CommunicationPortalPage> {
  List<ChatMessage> _chatMessages = [];

  void _sendMessage(ChatMessage message) {
    setState(() {
      _chatMessages.add(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Communication Portal'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                return _chatMessages[index];
              },
            ),
          ),
          _ChatInputArea(
            onMessageSent: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _ChatInputArea extends StatefulWidget {
  final Function(ChatMessage) onMessageSent;

  _ChatInputArea({required this.onMessageSent});

  @override
  __ChatInputAreaState createState() => __ChatInputAreaState();
}

class __ChatInputAreaState extends State<_ChatInputArea> {
  TextEditingController _textEditingController = TextEditingController();
  String _message = '';

  void _sendMessage() {
    if (_message.isNotEmpty) {
      ChatMessage chatMessage = ChatMessage(
        message: _message,
        isUser: true,
      );

      widget.onMessageSent(chatMessage);

      _textEditingController.clear();
      setState(() {
        _message = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textEditingController,
              onChanged: (value) {
                setState(() {
                  _message = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Type your message...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String message;
  final bool isUser;

  ChatMessage({required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CommunicationPortalPage(),
  ));
}
