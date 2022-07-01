import 'package:flutter_chat/global/environment.dart';
import 'package:flutter_chat/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Conecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Conecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;

  void connect() async {
    //obtengo el token del storage
    final token = await AuthService.getToken();

    print('Conectando al socket...');

    this._socket = IO.io(Environment.socketUrl, {
      'transports': ['websocket'],
      'autoConnect': true,
      'forceNew': true, //crea una nueva instancia/cliente,
      //sin esto el backend trata de mantener la misma sesion
      //pero necesitamos que sea una nueva por el manejo de tokens
      'extraHeaders': {
        'x-token': token,
      }
    });
    this._socket.on('connect', (_) {
      print('Connected to socket server');
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });
    this._socket.on('disconnect', (_) {
      print('Disconnected from socket server');
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });
  }

  void disconnect() {
    print('Desconectando del socket...');
    this._socket.disconnect();
  }
}
