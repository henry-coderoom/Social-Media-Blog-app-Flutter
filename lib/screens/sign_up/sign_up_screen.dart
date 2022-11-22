import 'package:bbarena_app_com/screens/white_screen.dart';
import 'package:flutter/material.dart';

import '../homeFire/home_screen.dart';
import 'components/body.dart';

class SignUpScreen extends StatelessWidget {
  static String routeName = "/sign_up";

  const SignUpScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeaeaea),
      appBar: AppBar(
        backgroundColor: const Color(0xffeaeaea),
        title: const Text(""),
      ),
      body: const Body(),
    );
  }
}
