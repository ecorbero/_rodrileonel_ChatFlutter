import 'package:flutter_chat/pages/chat_page.dart';
import 'package:flutter_chat/pages/login_page.dart';
import 'package:flutter_chat/services/auth_service.dart';
import 'package:flutter_chat/services/chat_service.dart';
import 'package:flutter_chat/services/socket.dart';
import 'package:flutter_chat/services/users_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/models/user_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UsersPage extends StatefulWidget {
  static final routeName = 'Users';

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final usersService = UsersService();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<User> users = [];

  @override
  void initState() {
    _loadingUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).user;
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          user.name,
          style: const TextStyle(color: Colors.black),
        ),
        elevation: 1,
        backgroundColor: const Color.fromARGB(255, 116, 178, 229),
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app_outlined, color: Colors.black),
          onPressed: () {
            socketService.disconnect();
            AuthService.deleteToken();
            Navigator.pushReplacementNamed(context, LoginPage.routeName);
          },
        ),
        actions: [
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(right: 20),
            child: FaIcon(FontAwesomeIcons.plug,
                color: (socketService.serverStatus == ServerStatus.Online)
                    ? Colors.green
                    : Colors.grey),
          ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        header: const WaterDropHeader(
          waterDropColor: Colors.blue,
          complete: Icon(
            FontAwesomeIcons.check,
            color: Colors.green,
          ),
        ),
        onRefresh: _loadingUsers,
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: users.length,
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
          itemBuilder: (BuildContext context, int index) =>
              UserItem(users[index]),
        ),
      ),
    );
  }

  void _loadingUsers() async {
    this.users = await usersService.getUsers();
    _refreshController.refreshCompleted();
    setState(() {});
  }
}

class UserItem extends StatelessWidget {
  final User user;
  UserItem(this.user);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(user.name),
      subtitle: Text(user.email),
      leading: CircleAvatar(
        child: Text(user.name.substring(0, 2)),
      ),
      trailing: Icon(
        Icons.online_prediction,
        color: (user.online) ? Colors.green : Colors.red,
      ),
      onTap: () {
        final chatService = Provider.of<ChatService>(context, listen: false);
        chatService.userFrom = user;
        Navigator.pushNamed(context, ChatPage.routeName);
      },
    );
  }
}
