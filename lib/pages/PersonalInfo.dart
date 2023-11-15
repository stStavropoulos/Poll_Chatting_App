import 'package:flutter/material.dart';

class PersonalInfoPage extends StatelessWidget {
  final String userId; // Pass the user ID to retrieve personal info

  PersonalInfoPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    // Replace the following with logic to fetch user info based on the userId
    // You might want to use FutureBuilder or StreamBuilder for asynchronous operations

    // Example: Fetch user info using userId
    String userName = "John Doe";
    String userEmail = "john.doe@example.com";
    String userImage = "https://example.com/profile-image.jpg";

    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Info'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(userImage),
            ),
            SizedBox(height: 16),
            Text(
              userName,
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
                color: Colors.grey,
              ),
            ),
            // Add other user details as needed
          ],
        ),
      ),
    );
  }
}
