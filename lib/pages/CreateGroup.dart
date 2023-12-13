import 'package:chatappdemocracy/pages/GroupChat.dart';
import 'package:chatappdemocracy/pages/HomePage.dart';
import 'package:chatappdemocracy/pages/PersonalInfo.dart';
import 'package:chatappdemocracy/pages/SearchPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateGroupChatPage extends StatefulWidget {
  final String currentUserId;

  CreateGroupChatPage({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _CreateGroupChatPageState createState() => _CreateGroupChatPageState();
}

class _CreateGroupChatPageState extends State<CreateGroupChatPage> {
  List<String> selectedUsers = [];
  late double buttonX;
  late double buttonY;

  @override
  void initState() {
    super.initState();
    // Initial position of the button (you can adjust this)
    buttonX = 250.0;
    buttonY = 700.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Participants'),
        backgroundColor: Colors.purple,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Color(0xFFC586FF),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;
          List<Widget> availableUsers = [];

          for (var user in users) {
            final nickname = user['nickname'] as String;
            final userId = user['uid'] as String;

            if (userId != widget.currentUserId) {
              availableUsers.add(_buildUserTile(user));
            }
          }

          if (selectedUsers.isEmpty) {
            selectedUsers.add(widget.currentUserId);
          }

          return Stack(
            children: [
              ListView(
                children: availableUsers,
              ),
              Positioned(
                left: buttonX,
                top: buttonY,
                child: ElevatedButton(
                  onPressed: () {
                    createGroupChat(selectedUsers);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurpleAccent,
                    padding: EdgeInsets.symmetric(horizontal: 150), // Adjust horizontal padding
                  ),
                  child: Center(
                    child: Text(
                      "Create Chat Room",
                      style: TextStyle(color: Colors.white),

                    ),
                  ),
                ),

              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.purple,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                // Navigate to the home page
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const HomePage(), // Replace HomePage with the actual class name of your home page
                  ),
                );
              },
              icon: Icon(Icons.home, color: Colors.white),
            ),

            IconButton(
              onPressed: () {
                // Logic for Search icon
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomSearchPage(),
                  ),
                );
              },
              icon: Icon(Icons.search),
              color: Colors.white,
            ),
            IconButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  String currentUserId = user.uid;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateGroupChatPage(currentUserId: currentUserId),
                    ),
                  );
                }
              },
              icon: Icon(Icons.add),
              color: Colors.deepPurple,
            ),

              IconButton(
                      onPressed: () {
                      // Logic for Person icon
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => PersonalInfoPage(), // Pass the actual user ID
                      ),
                      );
                      },
                    icon: Icon(Icons.person),
                    color: Colors.white,
                    ),
        ],
      ),
      ),
    );
  }

  Widget _buildUserTile(QueryDocumentSnapshot<Object?> user) {
    final nickname = user['nickname'] as String;
    final userId = user['uid'] as String;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedUsers.contains(userId)) {
            selectedUsers.remove(userId);
          } else {
            selectedUsers.add(userId);
          }
        });
      },
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0x9E7C4DFF),
            width: selectedUsers.contains(userId) ? 4 : 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          title: Text(nickname),
          leading: selectedUsers.contains(userId)
              ? Icon(Icons.check_circle, color: Color(0x9E7C4DFF))
              : null,
        ),
      ),
    );
  }

  Future<void> createGroupChat(List<String> selectedUsers) async {
    if (selectedUsers.length < 2) {
      // Show an alert or handle the case when less than 2 users are selected
      return;
    }
  }
}
    // Sort the selected users' IDs to ensure consistency in generating the group chat ID



