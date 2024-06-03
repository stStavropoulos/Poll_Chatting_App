import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:chatappdemocracy/pages/GroupChat.dart';

class SelectChatPhotoPage extends StatefulWidget {
  final List<String> selectedUsers;
  final String chatRoomId;

  SelectChatPhotoPage({required this.selectedUsers, required this.chatRoomId});

  @override
  _SelectChatPhotoPageState createState() => _SelectChatPhotoPageState();
}

class _SelectChatPhotoPageState extends State<SelectChatPhotoPage> {
  Uint8List? _imageData;
  String? _imageName;
  bool isUploading = false;

  Future<void> _pickImage() async {
    final image = await ImagePickerWeb.getImageAsBytes();

    if (image != null) {
      setState(() {
        _imageData = image;
        _imageName = 'group_photo_${widget.chatRoomId}.jpg';
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> _uploadImage() async {
    if (_imageData == null) return;

    setState(() {
      isUploading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user is currently signed in.')),
        );
        setState(() {
          isUploading = false;
        });
        return;
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('group_photos')
          .child(_imageName!);

      UploadTask uploadTask = storageRef.putData(_imageData!);

      TaskSnapshot storageTaskSnapshot = await uploadTask;
      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('group_chats')
          .doc(widget.chatRoomId)
          .update({'groupImage': downloadUrl});

      setState(() {
        isUploading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoomPage(
            selectedUsers: widget.selectedUsers,
            chatRoomId: widget.chatRoomId,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        isUploading = false;
      });

      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Chat Photo'),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        color: Colors.purple[50],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_imageData != null)
                Image.memory(_imageData!, height: 200)
              else
                Text('No image selected.', style: TextStyle(color: Colors.purple)),
              SizedBox(height: 20),
              isUploading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () {
                  _pickImage().then((_) {
                    if (_imageData != null) {
                      _uploadImage();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                child: Text(_imageData == null ? 'Select Image' : 'Upload Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
