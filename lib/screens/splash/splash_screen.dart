import 'package:flutter/material.dart';
import 'package:bbarena_app_com/screens/splash/components/body.dart';

class SplashScreen extends StatelessWidget {
  static String routeName = "/splash";

  const SplashScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // You have to call it on your starting screen
    return const Scaffold(
      body: Body(),
    );
  }
}
