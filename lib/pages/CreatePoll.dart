import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePollPage extends StatefulWidget {
  final String chatRoomId;
  final String senderId;

  CreatePollPage({required this.chatRoomId, required this.senderId});

  @override
  _CreatePollPageState createState() => _CreatePollPageState();
}

class _CreatePollPageState extends State<CreatePollPage> {
  TextEditingController _questionController = TextEditingController();
  List<TextEditingController> _answerControllers = [TextEditingController()];

  void _addAnswerOption() {
    setState(() {
      _answerControllers.add(TextEditingController());
    });
  }

  void _sendPollAnnouncement(String question, List<String> answers) {
    // Add logic to send the poll announcement message to the group chat
    FirebaseFirestore.instance.collection('chat_rooms').doc(widget.chatRoomId).collection('messages').add({
      'senderId': widget.senderId,
      'message': 'New Poll: $question',
      'answers': answers,
      'timestamp': FieldValue.serverTimestamp(),
      'isPoll': true,
    });

    // Close the CreatePollPage after sending the announcement
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a Poll'),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE5CCFF),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    labelText: 'Enter your poll question',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple), // Set border color to purple
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              for (int i = 0; i < _answerControllers.length; i++)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _answerControllers[i],
                    decoration: InputDecoration(
                      labelText: 'Enter answer option ${i + 1}',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple), // Set border color to purple
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 24.0), // Increased space between the two buttons
              ElevatedButton(
                onPressed: _addAnswerOption,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, // Change button color to purple
                  padding: EdgeInsets.symmetric(vertical: 16.0), // Increase vertical padding
                ),
                child: Text('Add Answer Option', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 16.0), // Space between the two buttons
              ElevatedButton(
                onPressed: () {
                  String question = _questionController.text;
                  List<String> answers = _answerControllers
                      .map((controller) => controller.text.trim())
                      .where((answer) => answer.isNotEmpty)
                      .toList();

                  if (question.isNotEmpty && answers.isNotEmpty) {
                    _sendPollAnnouncement(question, answers);
                  } else {
                    // Handle case when the question or answers are empty
                    // You can show a Snackbar or an alert
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, // Change button color to purple
                  padding: EdgeInsets.symmetric(vertical: 16.0), // Increase vertical padding
                ),
                child: Text('Confirm', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}






