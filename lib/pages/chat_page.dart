import 'dart:io';

import 'package:flutter_chat/models/message.dart';
import 'package:flutter_chat/models/user_model.dart';
import 'package:flutter_chat/services/auth_service.dart';
import 'package:flutter_chat/services/chat_service.dart';
import 'package:flutter_chat/services/socket.dart';
import 'package:flutter_chat/widgets/chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ChatPage extends StatefulWidget {
  static const routeName = 'Chat';

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textControler = TextEditingController();
  bool writing = false;
  final _focus = FocusNode();

  final List<ChatMessage> _items = [];

  late User user;
  late SocketService socketService;
  late AuthService authService;
  late ChatService chatService;

  late bool isIos;

  @override
  void initState() {
    super.initState();
    socketService = Provider.of<SocketService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);
    chatService = Provider.of<ChatService>(context, listen: false);

    user = chatService.userFrom;
    socketService.socket.on('message', _listenMessage);

    isIos = false;

    if (!kIsWeb) {
      if (Platform.isIOS) {
        isIos = true;
      }
    }

    _loadingChat(chatService.userFrom.uid);
  }

  void _loadingChat(String uid) async {
    List<Message> chat = await chatService.getChat(uid);
    final history = chat.map((m) => ChatMessage(
          text: m.message,
          uid: m.from,
          anim: AnimationController(
              vsync: this, duration: const Duration(milliseconds: 0))
            ..forward(),
        ));
    setState(() {
      _items.insertAll(0, history);
    });
  }

  void _listenMessage(dynamic data) {
    print(data['message']);
    ChatMessage msj = ChatMessage(
      text: data['message'],
      uid: data['from'],
      anim: AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
      ),
    );
    setState(() {
      _items.insert(0, msj);
    });
    msj.anim.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(
              child: (user != null)
                  ? Text('${user.name.substring(0, 2)}')
                  : Text('')),
          SizedBox(width: 10),
          Expanded(
              child: (user != null)
                  ? Text(
                      '${user.name}',
                      style: TextStyle(color: Colors.black),
                    )
                  : Text('')),
        ]),
        elevation: 1,
        backgroundColor: Color.fromARGB(255, 116, 178, 229),
      ),
      body: Container(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                reverse: true,
                itemCount: _items.length,
                itemBuilder: (BuildContext context, int index) {
                  return _items[index];
                },
              ),
            ),
            const Divider(height: 2),
            _inputChat(),
          ],
        ),
      ),
    );
  }

  Widget _inputChat() {
    return SafeArea(
      child: Container(
        height: 50,
        margin: const EdgeInsets.all(8),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textControler,
                decoration:
                    const InputDecoration.collapsed(hintText: 'Type Message'),
                focusNode: _focus,
                onSubmitted: writing
                    ? (_) => _handleSubmit(_)
                    : (_) => _textControler.clear(),
                onChanged: (text) {
                  if (text.trim().isNotEmpty) {
                    writing = true;
                  } else {
                    writing = false;
                  }
                  setState(() {});
                },
              ),
            ),
            Container(
                child: isIos
                    ? CupertinoButton(
                        onPressed: writing
                            ? () => _handleSubmit(_textControler.text)
                            : null,
                        child: const Text('Send'),
                      )
                    : IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        icon: const Icon(Icons.send),
                        onPressed: writing
                            ? () => _handleSubmit(_textControler.text)
                            : null,
                      ))
          ],
        ),
      ),
    );
  }

  _handleSubmit(String text) {
    _textControler.clear();
    _focus.requestFocus();

    final message = ChatMessage(
      text: text,
      uid: authService.user.uid,
      anim: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    _items.insert(0, message);
    message.anim.forward();

    setState(() {
      writing = false;
    });

    //enviar mensaje al socket server
    socketService.socket.emit('message',
        {'from': authService.user.uid, 'to': user.uid, 'message': text});
  }

  @override
  void dispose() {
    for (ChatMessage message in _items) {
      message.anim.dispose();
    }
    _textControler.dispose();
    socketService.socket.off('message');
    super.dispose();
  }
}
