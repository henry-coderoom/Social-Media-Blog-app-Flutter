import 'package:bbarena_app_com/constants.dart';
import 'package:flutter/material.dart';

import 'components/body.dart';

class SignInScreen extends StatelessWidget {
  static String routeName = "/sign_in";

  const SignInScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Future<bool> _onBackPressed() {
    //   throw Navigator.pop(context);
    // }

    return Scaffold(
      backgroundColor: kAuthScreenBackgroundColors,
      appBar: AppBar(
        backgroundColor: kAuthScreenBackgroundColors,
        title: const Text(""),
      ),
      body: const Body(),
    );
  }
}
