import 'package:chatappdemocracy/Services/LoginOrRgister.dart';
import 'package:chatappdemocracy/pages/HomePage.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: ( context,  snapshot) {
          //user logged in
          if (snapshot.hasData){
            return const HomePage();
          }else{
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
