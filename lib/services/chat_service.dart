import 'package:chat/global/environment.dart';
import 'package:chat/models/message.dart';
import 'package:chat/models/messages_response.dart';
import 'package:chat/models/user_model.dart';
import 'package:chat/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatService with ChangeNotifier {
  User userFrom;

  Future<List<Message>> getChat(String uid) async {
    try {
      final response = await http
          .get(Uri.parse('${Environment.apiUrl}/messages/$uid'), headers: {
        'Content-Type': 'application/json',
        'x-token': await AuthService.getToken()
      });
      final data = messagesResponseFromJson(response.body);
      return data.msj;
    } catch (e) {
      return [];
    }
  }
}
