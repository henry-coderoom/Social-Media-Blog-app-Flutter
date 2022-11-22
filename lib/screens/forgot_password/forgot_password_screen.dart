import 'package:flutter/material.dart';

import 'components/body.dart';

class ForgotPasswordScreen extends StatelessWidget {
  static String routeName = "/forgot_password";

  const ForgotPasswordScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffcbcbcb),
      appBar: AppBar(
        backgroundColor: const Color(0xffcbcbcb),
        title: const Text(""),
      ),
      body: const Body(),
    );
  }
}
