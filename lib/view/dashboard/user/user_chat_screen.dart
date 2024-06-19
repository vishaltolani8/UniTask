import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class UserChatScreen extends StatefulWidget {
  final String classId;
  final String studentId;

  UserChatScreen({required this.classId, required this.studentId});

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _messages = [];
  final ImagePicker _picker = ImagePicker();

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

  void _sendMessage({String? imageUrl}) {
    String message = _messageController.text;
    if (message.isNotEmpty || imageUrl != null) {
      String sender = 'user'; // Replace with dynamic user identification
      String messageId = ref.child('chats/${widget.classId}/${widget.studentId}').push().key!;
      ref.child('chats/${widget.classId}/${widget.studentId}/$messageId').set({
        'message': message,
        'sender': sender,
        'timestamp': DateTime.now().toIso8601String(),
        'imageUrl': imageUrl ?? '',
      }).then((_) {
        _messageController.clear();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      _uploadImage(imageFile);
    }
  }

  Future<void> _uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('chat_images/$fileName');

      final TaskSnapshot snapshot = await storageRef.putFile(image);

      String downloadUrl = await snapshot.ref.getDownloadURL();
      _sendMessage(imageUrl: downloadUrl);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Chat'),
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
                bool isSenderUser = message['sender'] == 'user';
                return Align(
                  alignment: isSenderUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Card(
                    color: isSenderUser ? Colors.green[100] : Colors.grey[200],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: isSenderUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                IconButton(
                  icon: Icon(Icons.photo, color: Colors.orange),
                  onPressed: _pickImage,
                ),
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
                  onPressed: () => _sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
