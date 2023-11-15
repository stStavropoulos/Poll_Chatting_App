import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChatService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> createOrRetrieveGroupChat(List<String> selectedUsers) async {
    if (selectedUsers.isEmpty) {
      return null; // Return null if no users are selected
    }

    // Sort the selected users' IDs to ensure consistency in generating the group chat ID
    selectedUsers.sort();

    // Check if a group chat already exists with the same users
    final querySnapshot = await _firestore
        .collection('group_chats')
        .where('participants', arrayContains: selectedUsers)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // If a group chat with these users exists, return the chat room ID
      return querySnapshot.docs.first.id;
    } else {
      // Create a new group chat if no existing chat found with these users
      final newGroupChatRef = await _firestore.collection('group_chats').add({
        'participants': selectedUsers,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Return the ID of the newly created chat
      return newGroupChatRef.id;
    }
  }
}

