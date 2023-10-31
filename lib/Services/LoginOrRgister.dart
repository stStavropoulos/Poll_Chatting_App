import 'package:chatappdemocracy/pages/signup.dart';
import 'package:flutter/material.dart';
import 'package:chatappdemocracy/pages/LoginPage.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  //initially the login
  bool showloginPage = true;

  void togglePages(){
    setState((){
      showloginPage = !showloginPage;
    });

  }
  @override
  Widget build(BuildContext context) {
    if (showloginPage){

      return LoginPage(onTap: togglePages);
    }else{
      return RegisterPage(onTap: togglePages);
    }
  }
}
