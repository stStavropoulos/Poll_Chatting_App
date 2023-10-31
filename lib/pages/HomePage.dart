import 'package:flutter/material.dart';
import 'package:chatappdemocracy/pages/LoginPage.dart';

class HomePage extends StatelessWidget {

  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Democracy Groups'), // Changed title to "Democracy Groups"
        backgroundColor: Colors.purple, // Changed app bar color to purple
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Navigate back to the sign-in page
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Color(0xFFC986FF), // Changed background color to light purple
      body: Center(
        child: const Text(
          'Hello',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

