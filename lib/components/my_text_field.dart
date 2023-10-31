import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {

  final TextEditingController controller;
  final String hintText;
  final bool obscuretext;
  const MyTextField({super.key,
  required this.controller,required this.obscuretext, required this.hintText
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscuretext,
      decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.deepPurpleAccent),
          ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.purpleAccent),
        ),
        fillColor: Colors.purpleAccent,
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white),

      ),


    );
  }
}
