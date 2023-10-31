import 'package:chatappdemocracy/pages/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CreateGroup.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Democracy Groups'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Color(0xFFC986FF),
      body: Stack(
        children: [
          Center(
            child: Text(
              'Your main content here',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Positioned(
            bottom: 120,
            left: 120,
            child: ElevatedButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  String currentUserId = user.uid;

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CreateGroupChatPage(currentUserId: currentUserId),
                    ),
                  );
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Create Group Chat",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}






