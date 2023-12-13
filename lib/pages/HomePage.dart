import 'package:chatappdemocracy/pages/CreateGroup.dart';
import 'package:chatappdemocracy/pages/PersonalInfo.dart';
import 'package:chatappdemocracy/pages/SearchPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatappdemocracy/pages/GroupChat.dart'; // Import the ChatRoomPage

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Democracy Groups'),
        backgroundColor: Colors.purple,
        automaticallyImplyLeading: false, // This removes the back button
      ),
      backgroundColor: Color(0xFFC986FF),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('group_chats').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    return Center(child: Text('User not logged in'));
                  }

                  final userUID = user.uid;

                  final groupChats = snapshot.data!.docs.where((doc) {
                    final participants = doc['participants'] as List<dynamic>;
                    return participants.contains(userUID);
                  }).toList();

                  return ListView.builder(
                    itemCount: groupChats.length,
                    itemBuilder: (context, index) {
                      final groupData = groupChats[index].data() as Map<String, dynamic>;
                      final participants = groupData['participants'] as List<dynamic>;

                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('chat_rooms')
                            .doc(groupChats[index].id)
                            .collection('messages')
                            .orderBy('timestamp', descending: true)
                            .limit(1)
                            .snapshots(),
                        builder: (context, messageSnapshot) {
                          if (messageSnapshot.connectionState == ConnectionState.waiting) {
                            return ListTile(
                              title: Text('Loading...'),
                              subtitle: Text(''),
                            );
                          } else if (messageSnapshot.hasError) {
                            return ListTile(
                              title: Text('Error'),
                              subtitle: Text(''),
                            );
                          } else {
                            final messages = messageSnapshot.data!.docs;
                            if (messages.isNotEmpty) {
                              final lastMessage = messages.first.data() as Map<String, dynamic>;
                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomPage(
                                        selectedUsers: participants.cast<String>(),
                                        chatRoomId: groupChats[index].id,
                                      ),
                                    ),
                                  );
                                },
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.primaries[index % Colors.primaries.length],
                                  ),
                                ),
                                title: FutureBuilder<List<String>>(
                                  future: _fetchUserNicknames(participants),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Text('Loading...');
                                    } else if (snapshot.hasError) {
                                      return Text('Error');
                                    } else {
                                      final nicknames = snapshot.data ?? [];
                                      return Text(nicknames.join(', '));
                                    }
                                  },
                                ),
                                subtitle: Text(lastMessage['message']),
                              );
                            } else {
                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomPage(
                                        selectedUsers: participants.cast<String>(),
                                        chatRoomId: groupChats[index].id,
                                      ),
                                    ),
                                  );
                                },
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.primaries[index % Colors.primaries.length],
                                  ),
                                ),
                                title: FutureBuilder<List<String>>(
                                  future: _fetchUserNicknames(participants),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Text('Loading...');
                                    } else if (snapshot.hasError) {
                                      return Text('Error');
                                    } else {
                                      final nicknames = snapshot.data ?? [];
                                      return Text(nicknames.join(', '));
                                    }
                                  },
                                ),
                                subtitle: Text('No messages yet'),
                              );
                            }
                          }
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
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
              icon: Icon(Icons.home, color: Colors.deepPurple),
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
              color: Colors.white,
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

  Future<List<String>> _fetchUserNicknames(List<dynamic> userIDs) async {
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

