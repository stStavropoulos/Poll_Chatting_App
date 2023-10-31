import 'dart:math';
import 'package:chatappdemocracy/Services/auth_service.dart';
//import 'package:ChatPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:chatappdemocracy/Services/LoginOrRgister.dart';
//import 'package:chatappdemocracy/pages/GroupChatPage.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> selectedUsers = [];

  get createGroupChat => null;

  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();

    // Navigate to the sign-in page after signing out
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginOrRegister(),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchUserListFromFirestore() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
    List<Map<String, dynamic>> allUsers = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    return allUsers;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("Welcome to Democracy"),
        actions: [
          IconButton(onPressed: signOut, icon: Icon(Icons.logout)),
        ],
      ),
      backgroundColor: Color(0xFFC986FF),
      body: Column(
        children: [
          Expanded(
            child: _buildUserList(),
          ),
          Container(
            alignment: Alignment.center, // Set the desired alignment
            child: Padding(
              padding: EdgeInsets.only(bottom: 100), // Adjust the padding to control the position
              child: ElevatedButton(
                onPressed: createGroupChat,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16), // Adjust the padding to increase the size
                  child: Text(
                    "Create Group Chat",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        List<Widget> userItems = snapshot.data!.docs
            .map<Widget>((doc) => _buildUserListItem(doc, context))
            .toList();

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: userItems,
          ),
        );
      },
    );
  }

  final _random = Random();

  Color getRandomColor() {
    return Color.fromRGBO(
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
      1.0,
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document, BuildContext context) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    final currentUser = _auth.currentUser;

    if (currentUser != null && currentUser.email != data['email']) {
      String userNickname = data['nickname'] ?? 'No Nickname';
      print("Retrieved nickname: $userNickname");


      // Get a random background color
      Color randomColor = getRandomColor();

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverUserEmail: userNickname,
                receiverUserID: data['uid'],
                receiverUserNickname: userNickname, // Pass the nickname
              ),
            ),
          );
        },
        child: Container(
          width: 100, // Adjust the width as needed
          height: 100, // Adjust the height as needed
          decoration: BoxDecoration(
            color: randomColor, // Use the random color
            shape: BoxShape.circle,
          ),
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              userNickname, // Display the user's nickname or the default value
              style: TextStyle(
                fontSize: 30,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

}