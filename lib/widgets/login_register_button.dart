import 'package:flutter/material.dart';

class LoginRegisterButton extends StatelessWidget {
  final String routeName;
  final String textButton;
  final String label;

  const LoginRegisterButton(
      {required this.routeName, required this.textButton, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        SizedBox(height: 10),
        Text(this.label),
        SizedBox(height: 10),
        GestureDetector(
            onTap: () =>
                Navigator.pushReplacementNamed(context, this.routeName),
            child: Text(this.textButton,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold))),
      ]),
    );
  }
}
