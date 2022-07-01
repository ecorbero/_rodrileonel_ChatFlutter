import 'dart:convert';

import 'package:flutter_chat/global/environment.dart';
import 'package:flutter_chat/models/login_response.dart';
import 'package:flutter_chat/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService with ChangeNotifier {
  late User user;
  bool _logeando = false;

  final _storage = const FlutterSecureStorage();

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
    //final token = await this._storage.read(key: 'token');

    //print("e22e");

    //String url = "http://localhost:3000/api/login";

    //final response = await http.get(Uri.parse(url));
    //final response = await http.get(Uri.parse('localhost:3000/api/login/renew'),
    //    headers: {'Content-Type': 'application/json', 'x-token': token!});

    //print(response);
/*
    String _baseUrl = '192.168.1.133:3000';
    String _path = 'api/login';
    Uri uri = Uri.http(_baseUrl, _path);
    var client = http.Client();

    print("eeee");
    //http.Response response = await http.get(uri);
    var response = await client.post(uri,
        headers: {'Content-Type': 'application/json', 'x-token': token!}
        //headers: requestHeaders,
        //body: jsonEncode(model.toJson()),
        );
*/
    var token = await this._storage.read(key: 'token');

    token ??= "";

    print(token);

    //final response = await http.get(
    //    Uri.parse('${Environment.apiUrl}/login/renew'),
    //    headers: {'Content-Type': 'application/json', 'x-token': token!});

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
  static Future<String?> getToken() async {
    final _storage = FlutterSecureStorage();
    return await _storage.read(key: 'token');
  }

  //si quiero el token sin referenciar a la clase, la hago static
  static Future<void> deleteToken() async {
    final _storage = FlutterSecureStorage();
    await _storage.delete(key: 'token');
  }
}
