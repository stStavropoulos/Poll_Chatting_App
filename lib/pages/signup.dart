import 'package:chatappdemocracy/Services/auth_service.dart';
import 'package:chatappdemocracy/components/my_Button.dart';
import 'package:chatappdemocracy/pages/ProfileImage.dart'; // Import the upload photo page
import 'package:flutter/material.dart';
import '../components/my_text_field.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text controller
  final nicknameController = TextEditingController(); // Add nickname controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match!"),
        ),
      );
      return;
    }

    // Check if the nickname is provided
    if (nicknameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please provide a nickname!"),
        ),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signUpWithEmailandPassword(
        nicknameController.text, // Pass nickname
        emailController.text,
        passwordController.text,
      );

      // Navigate to the homepage after successful signup
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  UploadPhotoPage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
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
                // nickname
                const SizedBox(height: 20),
                MyTextField(controller: nicknameController, obscuretext: false, hintText: 'Nickname'),
                // email
                const SizedBox(height: 20),
                MyTextField(controller: emailController, obscuretext: false, hintText: 'Email'),
                //password
                const SizedBox(height: 20),
                MyTextField(controller: passwordController, obscuretext: true, hintText: 'Password'),
                // confirm password
                const SizedBox(height: 20),
                MyTextField(controller: confirmPasswordController, obscuretext: true, hintText: 'Confirm Password'),
                //sign up
                const SizedBox(height: 20),
                MyButton(onTap: signUp, text: "Sign up now"),

                const SizedBox(height: 50),

                //Create account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("You want Justice?"),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,

                      child: const Text('Login now!', style: TextStyle(
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
