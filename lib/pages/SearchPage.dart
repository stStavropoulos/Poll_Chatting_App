import 'package:chatappdemocracy/pages/CreateGroup.dart';
import 'package:chatappdemocracy/pages/HomePage.dart';
import 'package:chatappdemocracy/pages/PersonalInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomSearchPage extends StatefulWidget {
  @override
  _CustomSearchPageState createState() => _CustomSearchPageState();
}

class _CustomSearchPageState extends State<CustomSearchPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        backgroundColor: Colors.purple,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Color(0xFFC986FF), // Set the background color to match the homepage
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                // Implement real-time search logic here
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search...',
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs;
                  List<Widget> searchResults = [];

                  for (var user in users) {
                    final nickname = user['nickname'] as String;
                    final userId = user['uid'] as String;

                    if (nickname.toLowerCase().startsWith(_searchController.text.toLowerCase())) {
                      searchResults.add(_buildUserTile(user));
                    }
                  }

                  return ListView(
                    children: searchResults,
                  );
                },
              ),
            ),
          ],
        ),
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
              color: Colors.deepPurple,
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

  Widget _buildUserTile(QueryDocumentSnapshot<Object?> user) {
    final nickname = user['nickname'] as String;
    final userId = user['uid'] as String;

    return GestureDetector(
      onTap: () {
        // Implement logic when a user is tapped
      },
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0x9E7C4DFF),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          title: Text(nickname),
        ),
      ),
    );
  }
}


