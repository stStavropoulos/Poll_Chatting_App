import 'package:chatappdemocracy/Services/auth_service.dart';
import 'package:chatappdemocracy/components/my_Button.dart';
import 'package:chatappdemocracy/pages/HomePage.dart';
import 'package:flutter/material.dart';
import '../components/my_text_field.dart';
import 'package:provider/provider.dart';


class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  // text controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signIn() async {
    //get the auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signInWithEmailandPassword(
        emailController.text,
        passwordController.text,
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString(),),),);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/democ.PNG'),
            fit: BoxFit.fill,
          ),
        ),

        child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),

        child: Column(
        children: [
          const SizedBox(height: 200),
          //welcome back
          //const Text('Welcome to Democracy', style: TextStyle(fontSize: 16
         // ),
          //),

          // email
          const SizedBox(height: 20),
          MyTextField(controller: emailController, obscuretext: false, hintText: 'Email'),
          //password
          const SizedBox(height: 20),
          MyTextField(controller: passwordController, obscuretext: true, hintText: 'Password'),

          //sign in
          const SizedBox(height: 20),
          MyButton(onTap: signIn, text: "Sign in"),
          const SizedBox(height: 50),
          //register
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("You want Justice?"),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: widget.onTap,

              child: const Text('Sign up now!', style: TextStyle(
                fontWeight: FontWeight.bold
              ),
              ),
              ),
            ],
          )
        ],
      ),
        ),
      ),
      ),
    );
  }
}
