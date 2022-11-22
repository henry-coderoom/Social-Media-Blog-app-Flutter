import 'package:flutter/material.dart';

import '../homeFire/home_screen.dart';
import 'components/body.dart';

class LoginSuccessScreen extends StatefulWidget {
  static String routeName = "/login_success";

  const LoginSuccessScreen({Key? key}) : super(key: key);

  @override
  State<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<LoginSuccessScreen> {
  bool isLoading = true;

  @override
  void initState() {
    doLoad();
    super.initState();
  }

  Future<void> doLoad() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    setState(() {
      isLoading = false;
    });
  }

  Future<bool> _onBackPressed() {
    throw Navigator.pushNamed(context, HomeScreenFire.routeName);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading == true) {
      return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          backgroundColor: const Color(0xffcbcbcb),
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(
                    strokeWidth: 1,
                    color: Colors.blue,
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Text(
                    'Please wait...',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          backgroundColor: const Color(0xffe0e0e0),
          appBar: AppBar(
            backgroundColor: const Color(0xffcbcbcb),
            leading: const SizedBox(),
            title: const Text(""),
          ),
          body: SingleChildScrollView(child: const Body()),
        ),
      );
    }
  }
}
