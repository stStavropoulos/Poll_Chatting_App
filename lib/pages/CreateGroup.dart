import 'package:chatappdemocracy/pages/HomePage.dart';
import 'package:chatappdemocracy/pages/PersonalInfo.dart';
import 'package:chatappdemocracy/pages/SearchPage.dart';
import 'package:chatappdemocracy/pages/Settings.dart';
import 'package:chatappdemocracy/pages/SelectChatPhotoPage.dart'; // Import the SelectChatPhotoPage
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
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: EdgeInsets.symmetric(horizontal: 150), // Adjust horizontal padding
                  ),
                  child: Center(
                    child: Text(
                      "Select Chat Photo",
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
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    // Navigate to the home page
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.home, color: Colors.white),
                  tooltip: 'Home',
                ),
                Text('Home', style: TextStyle(fontSize: 12, color: Colors.white)),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  tooltip: 'Search',
                ),
                Text('Search', style: TextStyle(fontSize: 12, color: Colors.white)),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () async {
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      String currentUserId = user.uid;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateGroupChatPage(currentUserId: currentUserId),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.add),
                  color: Colors.deepPurple,
                  tooltip: 'Add',
                ),
                Text('Add', style: TextStyle(fontSize: 12, color: Colors.deepPurple)),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    // Logic for Person icon
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalInfoPage(userId: ""),
                      ),
                    );
                  },
                  icon: Icon(Icons.person),
                  color: Colors.white,
                  tooltip: 'My Profile',
                ),
                Text('My Profile', style: TextStyle(fontSize: 12, color: Colors.white)),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    // Logic for Profile icon
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(), // Replace with your profile page
                      ),
                    );
                  },
                  icon: Icon(Icons.settings),
                  color: Colors.white,
                  tooltip: 'Settings',
                ),
                Text('Settings', style: TextStyle(fontSize: 12, color: Colors.white)),
              ],
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

    try {
      // Add the current user to the selected users if not already included
      if (!selectedUsers.contains(widget.currentUserId)) {
        selectedUsers.add(widget.currentUserId);
      }

      // Sort the list of user IDs to create a consistent chat room ID
      selectedUsers.sort();

      // Create a chat room ID based on the selected user IDs
      String chatRoomId = selectedUsers.join('_');

      // Check if the chat room already exists
      final existingChatRoom = await FirebaseFirestore.instance.collection('group_chats').doc(chatRoomId).get();

      if (existingChatRoom.exists) {
        // The chat room already exists, handle this case accordingly (e.g., show an alert)
        print('Chat room already exists');
        return;
      }

      // Create a new chat room in Firestore
      await FirebaseFirestore.instance.collection('group_chats').doc(chatRoomId).set({
        'participants': selectedUsers,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': widget.currentUserId,
        // Add any additional fields you need for your group chat
      });

      // Navigate to the SelectChatPhotoPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SelectChatPhotoPage(
            chatRoomId: chatRoomId,
            selectedUsers: selectedUsers,
          ),
        ),
      );
    } catch (e) {
      print('Error creating group chat: $e');
      // Handle the error, show an alert, etc.
    }
  }
}
