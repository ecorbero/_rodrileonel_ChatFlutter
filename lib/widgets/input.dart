import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final String placeholder;
  final IconData icon;
  final bool hidden;
  final TextEditingController controller;

  const Input({
    required this.placeholder,
    required this.icon,
    required this.controller,
    this.hidden = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 20, left: 5, top: 5, bottom: 5),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 5),
                blurRadius: 5)
          ]),
      child: TextField(
        controller: this.controller,
        autocorrect: false,
        obscureText: hidden,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            prefixIcon: Icon(this.icon),
            hintText: this.placeholder,
            focusedBorder: InputBorder.none,
            border: InputBorder.none),
      ),
    );
  }
}
