import 'package:chatappdemocracy/pages/CreateGroup.dart';
import 'package:chatappdemocracy/pages/HomePage.dart';
import 'package:chatappdemocracy/pages/SearchPage.dart';
import 'package:chatappdemocracy/pages/Settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalInfoPage extends StatefulWidget {
  final String? userId;

  PersonalInfoPage({this.userId});

  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  late User? currentUser;
  String userNickname = "Guest";
  String userEmail = "guest@example.com";
  String userPhoto = ""; // Variable to store the photo URL
  bool isLoading = true; // Loading state for image
  bool isError = false; // Error state for image

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;

    // Fetch user information based on whether userId is provided or is an empty string
    if (widget.userId != null && widget.userId!.isNotEmpty) {
      fetchUserNickname(widget.userId!);
    } else if (currentUser != null) {
      fetchUserNickname(currentUser!.uid);
    }
  }

  Future<void> fetchUserNickname(String userId) async {
    try {
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null) {
        setState(() {
          userNickname = userData['nickname'] ?? "Guest";
          userEmail = userData['email'] ?? "No email available";
          userPhoto = userData['photoUrl'] ?? "";
          isLoading = false; // Set loading state to false when data is fetched
        });
      }
    } catch (e) {
      print('Error fetching user info: $e');
      setState(() {
        isLoading = false; // Set loading state to false in case of an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Column(
              mainAxisSize: MainAxisSize.min,
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
                  color: Colors.white,
                  tooltip: 'Add',
                ),
                Text('Add', style: TextStyle(fontSize: 12, color: Colors.white)),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalInfoPage(userId: ""),
                      ),
                    );
                  },
                  icon: Icon(Icons.person),
                  color: Colors.deepPurple,
                  tooltip: 'My Profile',
                ),
                Text('My Profile', style: TextStyle(fontSize: 12, color: Colors.deepPurple)),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 30,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                backgroundImage: userPhoto.isNotEmpty && !isError
                    ? NetworkImage(userPhoto)
                    : null,
                child: isLoading
                    ? CircularProgressIndicator()
                    : userPhoto.isEmpty || isError
                    ? Icon(
                  Icons.person,
                  size: 60,
                )
                    : null,
              ),
            ),
            Positioned(
              top: 150,
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
