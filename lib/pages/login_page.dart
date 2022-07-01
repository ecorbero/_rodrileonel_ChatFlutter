import 'package:flutter_chat/helpers/show_alert.dart';
import 'package:flutter_chat/pages/register_page.dart';
import 'package:flutter_chat/pages/users_page.dart';
import 'package:flutter_chat/services/auth_service.dart';
import 'package:flutter_chat/services/socket.dart';
import 'package:flutter_chat/widgets/input.dart';
import 'package:flutter_chat/widgets/login_register_button.dart';
import 'package:flutter_chat/widgets/logo.dart';
import 'package:flutter_chat/widgets/button_sign.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  static const routeName = 'Login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Logo(),
                    _Form(),
                    const LoginRegisterButton(
                      routeName: RegisterPage.routeName,
                      label: "Don't have an account?",
                      textButton: 'Create one now!',
                    ),
                    //const SizedBox(height: 5),
                    const Text('Terms and Conditions'),
                  ]),
            ),
          ),
        ));
  }
}

class _Form extends StatelessWidget {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(children: [
          Input(
            icon: Icons.email_outlined,
            placeholder: 'Email',
            controller: emailController,
          ),
          const SizedBox(
            height: 20,
          ),
          Input(
            icon: Icons.lock_outlined,
            placeholder: 'Password',
            controller: passController,
            hidden: true,
          ),
          const SizedBox(
            height: 30,
          ),
          SignButton(
            label: 'Log In',
            press: authService.logeando
                ? null
                : () async {
                    FocusScope.of(context).unfocus();
                    final loginOK = await authService.login(
                        emailController.text.trim(), passController.text);
                    if (loginOK) {
                      //conectar a socketserver
                      socketService.connect();
                      //navegar a la pantalla de usuarios
                      Navigator.pushReplacementNamed(
                          context, UsersPage.routeName);
                    } else {
                      showAlert(context, 'Login Incorrect',
                          'Check your credentials and try again');
                    }
                  },
          ),
        ]),
      ),
    );
  }
}
