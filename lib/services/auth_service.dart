import 'dart:convert';

import 'package:chat/global/environment.dart';
import 'package:chat/models/login_response.dart';
import 'package:chat/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService with ChangeNotifier {
  User user;
  bool _logeando = false;

  final _storage = FlutterSecureStorage();

  bool get logeando => this._logeando;
  set logeando(value) {
    this._logeando = value;
    notifyListeners();
  }

  Future login(String email, String password) async {
    this.logeando = true;

    final request = {'email': email, 'password': password};

    final response = await http.post(Uri.parse('${Environment.apiUrl}/login'),
        body: jsonEncode(request),
        headers: {'Content-Type': 'application/json'});

    print(response.body);

    this.logeando = false;

    if (response.statusCode == 200) {
      final data = loginResponseFromJson(response.body);
      this.user = data.user;
      await this._saveToken(data.token);
      return true;
    } else {
      return false;
    }
  }

  Future register(String name, String email, String password) async {
    this.logeando = true;

    final request = {'name': name, 'email': email, 'password': password};

    final response = await http.post(
        Uri.parse('${Environment.apiUrl}/login/new'),
        body: jsonEncode(request),
        headers: {'Content-Type': 'application/json'});
    this.logeando = false;

    if (response.statusCode == 200) {
      final data = loginResponseFromJson(response.body);
      this.user = data.user;
      await this._saveToken(data.token);
      return true;
    } else
      return jsonDecode(response.body)['msg'];
  }

  Future _saveToken(String token) async {
    return await _storage.write(key: 'token', value: token);
  }

  Future<bool> logged() async {
    final token = await this._storage.read(key: 'token');

    final response = await http.get(
        Uri.parse('${Environment.apiUrl}/login/renew'),
        headers: {'Content-Type': 'application/json', 'x-token': token});

    print(response.body);

    if (response.statusCode == 200) {
      final data = loginResponseFromJson(response.body);
      this.user = data.user;
      await this._saveToken(data.token);
      return true;
    } else {
      this.logout();
      return false;
    }
  }

  Future logout() async {
    await _storage.delete(key: 'token');
  }

  //si quiero el token sin referenciar a la clase, la hago static
  static Future<String> getToken() async {
    final _storage = FlutterSecureStorage();
    return await _storage.read(key: 'token');
  }

  //si quiero el token sin referenciar a la clase, la hago static
  static Future<void> deleteToken() async {
    final _storage = FlutterSecureStorage();
    await _storage.delete(key: 'token');
  }
}
