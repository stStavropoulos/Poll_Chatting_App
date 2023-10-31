import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateGroupChatPage extends StatelessWidget {
  final String currentUserId;
  CreateGroupChatPage({Key? key, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a New Group Chat'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!.docs;
          List<Widget> availableUsers = [];

          for (var user in users) {
            if (user['uid'] != currentUserId) {
              final nickname = user['nickname'];
              availableUsers.add(
                ListTile(
                  title: Text(nickname),
                  onTap: () {
                    // Handle selecting the user for the group chat
                  },
                ),
              );
            }
          }

          return ListView(
            children: availableUsers,
          );
        },
      ),
    );
  }
}