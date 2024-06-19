import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class AdminChatScreen extends StatefulWidget {
  final String classId;
  final String studentId;

  AdminChatScreen({required this.classId, required this.studentId});

  @override
  _AdminChatScreenState createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  void _fetchMessages() {
    ref.child('chats/${widget.classId}/${widget.studentId}').onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> messagesData = event.snapshot.value as Map;
        List<Map<String, dynamic>> messagesList = [];

        messagesData.forEach((messageId, messageInfo) {
          messagesList.add({
            'messageId': messageId,
            'message': messageInfo['message'],
            'sender': messageInfo['sender'],
            'timestamp': DateTime.parse(messageInfo['timestamp']),
            'imageUrl': messageInfo['imageUrl'],
          });
        });

        messagesList.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

        setState(() {
          _messages = messagesList;
        });
      }
    });
  }

  void _sendMessage() {
    String message = _messageController.text;
    if (message.isNotEmpty) {
      String sender = 'admin'; // Replace with dynamic user identification
      String messageId = ref.child('chats/${widget.classId}/${widget.studentId}').push().key!;
      ref.child('chats/${widget.classId}/${widget.studentId}/$messageId').set({
        'message': message,
        'sender': sender,
        'timestamp': DateTime.now().toIso8601String(),
        'imageUrl': '', // No image URL for text messages
      }).then((_) {
        _messageController.clear();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Chat'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(child: Text('No messages yet'))
                : ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isSenderAdmin = message['sender'] == 'admin';
                return Align(
                  alignment: isSenderAdmin ? Alignment.centerLeft : Alignment.centerRight,
                  child: Card(
                    color: isSenderAdmin ? Colors.blue[100] : Colors.grey[200],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: isSenderAdmin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                        children: [
                          if (message['imageUrl'] != null && message['imageUrl'].isNotEmpty)
                            Image.network(message['imageUrl']),
                          if (message['message'] != null && message['message'].isNotEmpty)
                            Text(
                              message['message'],
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          SizedBox(height: 5),
                          Text(
                            DateFormat('yyyy-MM-dd – kk:mm').format(message['timestamp']),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Enter your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.orange),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
