import 'package:flutter/material.dart';

import 'components/body.dart';

class EditUserScreenFire extends StatelessWidget {
  static String routeName = "/editUserFire";

  const EditUserScreenFire({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool isLoading = false;

    return Scaffold(
      backgroundColor: const Color(0xffcbcbcb),
      appBar: AppBar(
        // backgroundColor: const Color(0xffcbcbcb),
        title: const Text(""),
      ),
      body: const Body(),
    );
  }
}
