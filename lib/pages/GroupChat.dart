import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatappdemocracy/pages/HomePage.dart';
import 'package:chatappdemocracy/services/chat_service.dart';

class ChatRoomPage extends StatefulWidget {
  final List<String> selectedUsers;
  final String chatRoomId;
  final ChatService chatService = ChatService();

  ChatRoomPage({
    Key? key,
    required this.selectedUsers,
    required this.chatRoomId,
  }) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();

  late String _currentUserId; // To store the current user's ID

  @override
  void initState() {
    super.initState();
    _getCurrentUser(); // Get the current user's ID
  }

  void _getCurrentUser() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _currentUserId = currentUser.uid; // Get the current user's ID
      });
    } else {
      // Handle the case where the current user is not available
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<List<String>>(
          future: fetchUserNicknames(widget.selectedUsers),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            } else if (snapshot.hasError) {
              return const Text('Error');
            } else {
              final nicknames = snapshot.data ?? [];
              return Text(nicknames.join(', '));
            }
          },
        ),
        backgroundColor: Colors.purple,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            icon: const Icon(Icons.home),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.menu), // Replace with your options icon
          onPressed: () {
            // Add your code for handling options button press
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE5CCFF), // Light purple background color
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.chatService.getMessages(widget.chatRoomId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching messages'));
        } else {
          final messages = snapshot.data!.docs;
          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index].data() as Map<String, dynamic>;
              final senderId = message['senderId'];
              final isCurrentUser = senderId == _currentUserId; // Check against _currentUserId

              return FutureBuilder<String>(
                future: widget.chatService.getUserNickname(senderId),
                builder: (context, nicknameSnapshot) {
                  if (nicknameSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (nicknameSnapshot.hasData) {
                    final senderNickname = nicknameSnapshot.data!;

                    return _chatService.yourMessageWidget(
                      message: message['message'],
                      senderNickname: senderNickname,
                      isCurrentUser: isCurrentUser,
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              );
            },
          );
        }
      },
    );
  }

  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFDF86EF),
              border: Border(top: const BorderSide(color: Colors.black54)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _messageController,
                obscureText: false,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () async {
            String messageText = _messageController.text;
            widget.chatService.sendMessage(widget.chatRoomId, messageText);
            _messageController.clear();
          },
        ),
      ],
    );
  }

  Future<List<String>> fetchUserNicknames(List<String> userIDs) async {
    final userNicknameList = <String>[];

    for (var userID in userIDs) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userID).get();
      final userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('nickname')) {
        userNicknameList.add(userData['nickname']);
      }
    }

    return userNicknameList;
  }
}


