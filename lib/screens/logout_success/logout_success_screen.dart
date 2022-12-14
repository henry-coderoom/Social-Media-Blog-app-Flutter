import 'package:flutter/material.dart';

import 'components/body.dart';

class LogOutSuccessScreen extends StatelessWidget {
  static String routeName = "/logout_success";

  const LogOutSuccessScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xffeaeaea),
      body: Body(),
    );
  }
}
