import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class VotePage extends StatefulWidget {
  final String chatRoomId;
  final List<String> options;


  VotePage({required this.chatRoomId, required this.options});

  @override
  _VotePageState createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  late List<bool> selectedOptions;
  String? userNickname; // Store user nickname
  late String _currentUserId; // Add this line to declare _currentUserId
  bool hasVoted = false;

  @override
  void initState() {
    super.initState();
    selectedOptions = List<bool>.generate(widget.options.length, (index) => false);

    // Fetch and store the user's nickname when the page is initialized
    fetchUserNickname();

    // Initialize _currentUserId
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  }
  // Add this function to fetch and store the user's nickname
  void fetchUserNickname() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = snapshot.data() as Map<String, dynamic>?;

      // Check if the user has a valid nickname
      if (userData != null && userData['nickname'] != 'default') {
        setState(() {
          userNickname = userData['nickname'];
        });
      }
    }
  }

  Future<void> _sendUserAnswer(List<String> selectedAnswers) async {
    // Check if the user has already voted
    if (hasVoted) {
      // Display a message indicating that the user has already voted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have already voted.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check if there are selected answers before sending the message
    if (selectedAnswers.isNotEmpty) {
      // Display a message in the chat room with the selected answer and voter's nickname
      final String voterNickname = userNickname ?? 'Unknown Voter';

      // Add the vote message to the chat with the selected answers
      await FirebaseFirestore.instance.collection('chat_rooms').doc(widget.chatRoomId).collection('messages').add({
        'senderId': _currentUserId,
        'message': 'Selected Answers: ${selectedAnswers.join(', ')}',
        'timestamp': FieldValue.serverTimestamp(),
        'isPoll': false,
        'isPollAnswer': true,
        'answers': selectedAnswers,
        'voterNickname': voterNickname, // Pass the voter nickname to the message
      });

      // Set hasVoted to true after successfully sending the answer
      setState(() {
        hasVoted = true;
      });
    }
  }


// Add this function to generate the vote message widget
  Widget renderVoteMessage({
    required List<String> selectedAnswers,
    String? voterNickname, // Pass the voter nickname as a parameter
    bool isVoteMessage = true, // Add a flag to indicate this is a vote message
  }) {
    // Customize this method based on how you want to display vote messages
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: isVoteMessage ? Colors.purple : Colors.blue, // Customize the color for vote messages
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vote: ${selectedAnswers.join(', ')}',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          if (voterNickname != null && voterNickname.isNotEmpty)
            Text(
              'Voter Nickname: $voterNickname', // Display the voter nickname
              style: TextStyle(color: Colors.white),
            ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5CCFF),
      appBar: AppBar(
        title: Text('Vote'),
        backgroundColor: Colors.purple, // Match the app's primary color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select an option:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.options.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: selectedOptions[index],
                        onChanged: (value) {
                          setState(() {
                            selectedOptions[index] = value ?? false;
                          });
                        },
                        activeColor: Colors.purple, // Match the app's primary color
                      ),
                      SizedBox(width: 8.0),
                      Text(widget.options[index]),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                List<String> selectedAnswers = [];
                for (int i = 0; i < selectedOptions.length; i++) {
                  if (selectedOptions[i]) {
                    selectedAnswers.add(widget.options[i]);
                  }
                }

                // Display a message in the chat room with the selected answer and voter's nickname

                // Add the vote message to the chat
                await _sendUserAnswer(selectedAnswers);

                // Update this part based on your UI requirements
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Vote submitted: ${selectedAnswers.join(', ')}'),
                    duration: Duration(seconds: 2),
                  ),
                );

                Navigator.pop(context); // Close the VotePage
              },
              child: Text('Vote'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple, // Match the app's primary color
              ),
            ),
          ],
        ),
      ),
    );
  }
}



