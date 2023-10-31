import 'package:cloud_firestore/cloud_firestore.dart';

class MessageGroup {
  final String senderId;
  final String senderEmail;
  final String senderNickname; // Add sender's nickname
  final String messageGroup;
  final Timestamp timestamp;

  MessageGroup({
    required this.senderId,
    required this.senderEmail,
    required this.senderNickname,
    required this.messageGroup,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'senderNickname': senderNickname,
      'message': messageGroup,
      'timestamp': timestamp,
    };
  }
}
