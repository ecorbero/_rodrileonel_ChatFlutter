import 'package:flutter/material.dart';

class SignButton extends StatelessWidget {
  final Function press;
  final String label;

  const SignButton({this.press, @required this.label});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      elevation: 5,
      highlightElevation: 5,
      color: Colors.blue,
      shape: StadiumBorder(),
      onPressed: press,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 15),
        child: Center(
            child: Text(
          label,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        )),
      ),
    );
  }
}
