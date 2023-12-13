import 'package:cloud_firestore/cloud_firestore.dart';

class PollMessage {
  final String senderId;
  final String question;

  PollMessage({required this.senderId, required this.question});
}

class Message {
  final String senderId;
  final String senderEmail;
  final String senderNickname;
  final String? message;
  final List<String>? selectedAnswers;
  final Timestamp timestamp;

  // Constructor for regular text messages
  Message({
    required this.senderId,
    required this.senderEmail,
    required this.senderNickname,
    required this.message,
    required this.timestamp,
  }) : selectedAnswers = null;

  // Constructor for poll vote messages
  Message.vote({
    required this.senderId,
    required this.senderEmail,
    required this.senderNickname,
    required this.selectedAnswers,
    required this.timestamp,
  }) : message = null;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'senderNickname': senderNickname,
      'timestamp': timestamp,
    };

    if (message != null) {
      map['message'] = message;
    }

    if (selectedAnswers != null) {
      map['selectedAnswers'] = selectedAnswers;
    }

    return map;
  }
    }





