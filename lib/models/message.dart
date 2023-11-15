import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String senderNickname; // Add sender's nickname

  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.senderNickname,
    required this.message,
    required this.timestamp,
  });

  // Add a method to convert the message to a map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'senderNickname': senderNickname, // Include sender's nickname in the map
      'message': message,
      'timestamp': timestamp,
    };
  }
}

