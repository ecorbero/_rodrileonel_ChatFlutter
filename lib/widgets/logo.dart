import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 400,
        child: Column(children: const [
          Image(
            image: AssetImage('assets/logo.png'),
            height: 240,
          ),
          //Text('Super Mesenger',style:TextStyle(fontSize: 30))
        ]),
      ),
    );
  }
}
