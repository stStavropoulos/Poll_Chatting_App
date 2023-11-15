import 'package:chatappdemocracy/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _currentUserId; // Variable to hold the current user's ID

  ChatService() {
    _getCurrentUser(); // Retrieve the current user ID when ChatService is initialized
  }

  void _getCurrentUser() {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      _currentUserId = currentUser.uid; // Get the current user's ID
    } else {
      // Handle the case where the current user is not available
    }
  }

  Future<void> setUserDisplayName(String displayName) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await setUserDisplayNameInFirestore(user.uid, displayName); // Update display name in Firestore
    }
  }

  Future<void> setUserDisplayNameInFirestore(String userId, String displayName) async {
    await _firestore.collection('users').doc(userId).update({'nickname': displayName});
  }

  Future<String> getUserNickname(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data();
    if (userData != null && userData.containsKey('nickname')) {
      return userData['nickname'];
    }
    return 'DefaultNickname';
  }

  Widget yourMessageWidget({
    required String message,
    required String senderNickname,
    required bool isCurrentUser,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: isCurrentUser ? Colors.deepPurple : Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                senderNickname,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendMessage(String chatRoomId, String message) async {
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final String currentUserNickname = await getUserNickname(_currentUserId); // Use the current user ID
    final timestamp = Timestamp.now();

    if (currentUserNickname != 'DefaultNickname') {
      Message newMessage = Message(
        senderId: _currentUserId, // Use the current user ID
        senderEmail: currentUserEmail,
        senderNickname: currentUserNickname,
        message: message,
        timestamp: timestamp,
      );

      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());
    }
  }

  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}

