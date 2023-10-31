import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';


class AuthService extends ChangeNotifier{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // instance of firebase database
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //sign in

  Future<UserCredential?> signInWithEmailandPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentReference userDocRef = _firestore.collection("users").doc(userCredential.user!.uid);

      // Get the existing data from the Firestore document
      DocumentSnapshot userDocSnapshot = await userDocRef.get();
      Map<String, dynamic> userData = userDocSnapshot.data() as Map<String, dynamic>;

      // Update the document with new data, including the 'nickname' field if it doesn't exist
      userData['uid'] = userCredential.user!.uid;
      userData['email'] = email;

      if (!userData.containsKey('nickname')) {
        userData['nickname'] = "Jack"; // You can set a default value here
      }

      // Update the Firestore document with the new data
      await userDocRef.set(userData);

      return userCredential;
    } catch (e) {
      // Handle any errors here
      print("Error: $e");
      return null;
    }
  }
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot userData = await _firestore.collection('users').doc(userId).get();
      return userData.data() as Map<String, dynamic>?;
    } catch (e) {
      print("Error getting user data: $e");
      return null;
    }
  }

  Stream<QuerySnapshot> getChatRoomsForUser(String userId) {
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: userId)
        .snapshots();
  }

  //create new user
  Future<UserCredential> signUpWithEmailandPassword(
      String nickname, // Add nickname parameter
      String email,
      String password,
      ) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user data in Firestore
      _firestore.collection("users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'nickname': nickname, // Store the nickname
        'email': email,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //signout
Future<void> signOut() async{
    return await FirebaseAuth.instance.signOut();
}
}