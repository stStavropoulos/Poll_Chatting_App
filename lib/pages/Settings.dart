import 'package:chatappdemocracy/pages/CreateGroup.dart';
import 'package:chatappdemocracy/pages/HomePage.dart';
import 'package:chatappdemocracy/pages/PersonalInfo.dart';
import 'package:chatappdemocracy/pages/SearchPage.dart';
import 'package:chatappdemocracy/pages/LoginPage.dart'; // Import your sign-in page
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  void _signOut(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Sign Out'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _auth.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(), // Navigate to the sign-in page
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.purple,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFC986FF),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _signOut(context),
          child: Text('Sign Out'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            textStyle: TextStyle(fontSize: 24),
          ),
        ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.settings),
                  color: Colors.deepPurple,
                  tooltip: 'Settings',
                ),
                Text('Settings', style: TextStyle(fontSize: 12, color: Colors.deepPurple)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
