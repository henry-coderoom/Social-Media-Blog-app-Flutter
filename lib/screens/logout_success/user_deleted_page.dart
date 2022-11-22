import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../homeFire/home_screen.dart';
import 'components/bodydel.dart';

class UserDelete extends StatefulWidget {
  static String routeName = "/user_delete";

  const UserDelete({Key? key}) : super(key: key);

  @override
  State<UserDelete> createState() => _UserDeleteState();
}

class _UserDeleteState extends State<UserDelete> {
  bool isLoading = false;
  String loggedUse = 'no';

  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user?.uid != null) {
        setState(() {
          loggedUse = 'yes';
        });
      } else {
        setState(() {
          loggedUse = 'no';
        });
      }
    });
    super.initState();
  }

  Future<bool> _onBackPressed() {
    throw Navigator.pushNamed(context, HomeScreenFire.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackPressed(),
      child: Scaffold(
        backgroundColor: const Color(0xffe5e5e5),
        appBar: AppBar(
          backgroundColor: const Color(0xffcbcbcb),
          leading: const SizedBox(),
          title: const Text(""),
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: BodyDel(
            loggedUser: loggedUse,
          ),
        ),
      ),
    );
  }
}
