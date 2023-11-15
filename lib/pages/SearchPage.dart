import 'package:flutter/material.dart';

class CustomSearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
              ),
            ),
            // Add your search results here
            // You can use a ListView.builder or any other widget to display results
          ],
        ),
      ),
    );
  }
}
