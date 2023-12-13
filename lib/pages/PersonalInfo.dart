import 'package:chatappdemocracy/pages/CreateGroup.dart';
import 'package:chatappdemocracy/pages/HomePage.dart';
import 'package:chatappdemocracy/pages/SearchPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalInfoPage extends StatefulWidget {
  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  late User? currentUser;
  String userNickname = "Guest"; // Default value

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;

    // Fetch user nickname from Firestore
    if (currentUser != null) {
      fetchUserNickname(currentUser!.uid);
    }
  }

  Future<void> fetchUserNickname(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('nickname')) {
        setState(() {
          userNickname = userData['nickname'];
        });
      }
    } catch (e) {
      print('Error fetching user nickname: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String userEmail = currentUser?.email ?? "guest@example.com";
    //String userImage = currentUser?.photoURL ?? "https://example.com/profile-image.jpg";

    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Info'),
        backgroundColor: Colors.purple,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Color(0xFFC986FF),
      bottomNavigationBar: BottomAppBar(
        color: Colors.purple,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
              icon: Icon(Icons.home, color: Colors.white),
            ),
            IconButton(
              onPressed: () {
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonalInfoPage(),
                  ),
                );
              },
              icon: Icon(Icons.person),
              color: Colors.deepPurple,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          alignment: Alignment.center, // Adjust this to control the alignment of the entire stack
          children: [
            Positioned(
              top: 30, // Adjust the top position
              child: CircleAvatar(
                radius: 60,

              ),
            ),
            Positioned(
              top: 150, // Adjust the top position
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    userNickname,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


