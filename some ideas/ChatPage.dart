import 'package:chatappdemocracy/Services/chat_service.dart';
import 'package:chatappdemocracy/components/my_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  final String receiverUserNickname;

  ChatPage({
    Key? key,
    required this.receiverUserEmail,
    required this.receiverUserID,
    required this.receiverUserNickname,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}


class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserID, _messageController.text);
      // Clear the text controller after sending the message
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract the part before "@" from the receiverUserEmail
    String appBarTitle = widget.receiverUserNickname;


    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle), // Set the extracted part as the title
        backgroundColor: Colors.deepPurple,
      ),

      backgroundColor: Color(0xFFC986FF), // Set the background color here
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          // user input
          _buildMessageInput(),
        ],
      ),
    );
  }


  // build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          widget.receiverUserID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading..');
        }

        return ListView(
          children: snapshot.data!.docs
              .map((DocumentSnapshot document) =>
              _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    final isCurrentUser = data['senderId'] == _firebaseAuth.currentUser!.uid;
    final senderNickname = data['senderNickname']; // Access sender's nickname

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: isCurrentUser ? Colors.deepOrangeAccent : Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: isCurrentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                data['message'], // Display sender's nickname
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // build message input
  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: Container( // Wrap your MyTextField with a Container
            decoration: BoxDecoration(
              color: Colors.black, // Set the background color
              borderRadius: BorderRadius.circular(10),
            ),
            child: MyTextField(
              controller: _messageController,
              hintText: 'New message',
              obscuretext: false, // Fix the typo here (obscureText)
            ),
          ),
        ),
        IconButton(
          onPressed: sendMessage,
          icon: Icon(Icons.send),
        ),
      ],
    );
  }
}
