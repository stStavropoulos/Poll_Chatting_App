import 'package:chatappdemocracy/pages/CreatePoll.dart';
import 'package:chatappdemocracy/pages/VotePage.dart';
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
  bool _showOptions = false;
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
      ),
      drawer: buildDrawer(), // Add the Drawer here
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
// Inside _buildMessageList method in ChatRoomPage
// Inside _buildMessageList method in ChatRoomPage
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
              final isCurrentUser = senderId == _currentUserId;
              final isPoll = message['isPoll'] ?? false;
              final options = (message['answers'] as List<dynamic>?)?.cast<String>() ?? [];
              final isSystemMessage = senderId == 'system';
              final isPollAnswer = message['isPollAnswer'] ?? false;

              return FutureBuilder<String>(
                future: widget.chatService.getUserNickname(senderId),
                builder: (context, nicknameSnapshot) {
                  if (nicknameSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (nicknameSnapshot.hasData) {
                    final senderNickname = nicknameSnapshot.data!;

                    if (isSystemMessage) {
                      // Render the system message (e.g., yourMessageWidget)
                      return widget.chatService.yourMessageWidget(
                        message: message['message'],
                        senderNickname: senderNickname,
                        isCurrentUser: isCurrentUser,
                      );
                    } else if (isPoll) {
                      // Render the poll message
                      return widget.chatService.renderPollMessage(
                        question: message['message'],
                        senderNickname: senderNickname,
                        options: options,
                        onVotePressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VotePage(
                                chatRoomId: widget.chatRoomId,
                                options: options,
                              ),
                            ),
                          );
                        },
                      );
                    } else if (isPollAnswer) {
                      // Render the vote message for poll answers
                      return widget.chatService.renderVoteMessage(
                        selectedAnswers: options,
                        voterNickname: message['voterNickname'],
                      );

                    } else {
                      // Render the regular message
                      return widget.chatService.yourMessageWidget(
                        message: message['message'],
                        senderNickname: senderNickname,
                        isCurrentUser: isCurrentUser,
                      );
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              );
            },
          );
        }
      },
    ); // Add a default return statement
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
            if (_showOptions) {
              // Handle the case when _showOptions is true
            } else {
              String messageText = _messageController.text;
              _chatService.sendMessage(widget.chatRoomId, messageText);
              _messageController.clear();
            }
          },
        ),
      ],
    );
  }

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.purple,
            ),
            child: Text(
              'Democracy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.poll),
            title: Text('Create a Poll'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Navigate to the CreatePollPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreatePollPage(
                    chatRoomId: widget.chatRoomId,
                    senderId: _currentUserId,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Leave Group'),
            onTap: () {
              // Handle leaving the group, for example, show a confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Leave Group"),
                    content: Text("Are you sure you want to leave this group?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context); // Close the dialog

                          // Implement the logic to leave the group
                          try {
                            // Get the current group chat document
                            final groupChatDoc = await FirebaseFirestore.instance.collection('groupchats').doc(widget.chatRoomId).get();

                            // Check if the document exists
                            if (groupChatDoc.exists) {
                              // Get the participants list
                              List<String> participants = List<String>.from(groupChatDoc.data()?['participants'] ?? []);

                              // Remove the current user from the participants list
                              participants.remove(_currentUserId);

                              // Update the participants in the Firestore document
                              await groupChatDoc.reference.update({'participants': participants});

                              // Navigate back to the home page
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => HomePage()),
                                    (Route<dynamic> route) => false, // Remove all routes from the stack
                              );
                            } else {
                              // Handle the case where the group chat document does not exist
                              // You may want to show an error message or take appropriate action
                            }
                          } catch (e) {
                            print('Error leaving group: $e');
                            // Handle the error as needed
                          }
                        },
                        child: Text("Leave"),
                      ),


                    ],
                  );
                },
              );
            },
          ),
          // Add more items as needed
        ],
      ),
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
