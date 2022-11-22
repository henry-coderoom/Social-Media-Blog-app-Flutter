import 'package:bbarena_app_com/constants.dart';
import 'package:flutter/material.dart';

import 'components/body.dart';

class FeedBackScreen extends StatelessWidget {
  static String routeName = "/feedbackPage";

  const FeedBackScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool isLoading = false;

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
