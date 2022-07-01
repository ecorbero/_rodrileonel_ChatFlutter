import 'package:flutter_chat/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatMessage extends StatelessWidget {
  final String text;
  final String uid;
  final AnimationController anim;

  const ChatMessage({
    required this.text,
    required this.uid,
    required this.anim,
  });

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<AuthService>(context).user.uid;
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: Align(
        alignment: (this.uid == uid) ? Alignment.topRight : Alignment.topLeft,
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(
              top: 5,
              bottom: 5,
              left: (this.uid == uid) ? 50 : 10,
              right: (this.uid == uid) ? 10 : 50),
          decoration: BoxDecoration(
              color: (this.uid == uid) ? Colors.blueAccent : Colors.green,
              borderRadius: BorderRadius.circular(20)),
          child: Text(
            this.text,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
