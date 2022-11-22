import 'package:flutter/material.dart';

import '../../../../constants.dart';
import 'edit_user_page.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: EditUser(),
    );
  }
}
