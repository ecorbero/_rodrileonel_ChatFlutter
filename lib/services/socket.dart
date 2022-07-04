import 'package:flutter_chat/global/environment.dart';
import 'package:flutter_chat/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart' show kIsWeb;

enum ServerStatus { Online, Offline, Conecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Conecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket;

  void connect() async {
    //obtengo el token del storage
    final token = await AuthService.getToken();

    print('Conectant al socket... token = ${token}');

    if (kIsWeb) {
      // for Web => run without ".setTransports"..
      _socket = IO.io(Environment.socketUrl, {
        //'transports': ['websocket'],
        'autoConnect': true,
        'forceNew': true, //crea una nueva instancia/cliente,
        //sin esto el backend trata de mantener la misma sesion
        //pero necesitamos que sea una nueva por el manejo de tokens
        'extraHeaders': {
          'x-token': token,
        }
      });
    } else {
      // for No Web => run with ".setTransports"...
      _socket = IO.io(Environment.socketUrl, {
        'transports': ['websocket'],
        'autoConnect': true,
        'forceNew': true, //crea una nueva instancia/cliente,
        //sin esto el backend trata de mantener la misma sesion
        //pero necesitamos que sea una nueva por el manejo de tokens
        'extraHeaders': {
          'x-token': token,
        }
      });
    }

    // Connect to websocket
    //socket.connect();
    socket.onConnect((data) => {
          print('Connected to socket server'),
          _serverStatus = ServerStatus.Online,
          notifyListeners(),
        });

    socket.onDisconnect((data) => {
          print('Disconnected from socket server'),
          _serverStatus = ServerStatus.Offline,
          notifyListeners(),
        });
/*
    _socket.on('connect', (_) {
      print('Connected to socket server');
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });
    _socket.on('disconnect', (_) {
      print('Disconnected from socket server');
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

*/
  }

  void disconnect() {
    print('Desconectando del socket...');
    _socket.disconnect();
  }
}
