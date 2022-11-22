import 'package:flutter/material.dart';

class WhiteScreen extends StatefulWidget {
  static String routeName = "/whiteScreen";
  final Widget routename;
  final String whatToDo;
  final Function() refresh;

  const WhiteScreen(
      {Key? key,
      required this.routename,
      required this.whatToDo,
      required this.refresh})
      : super(key: key);

  @override
  State<WhiteScreen> createState() => _WhiteScreenState();
}

class _WhiteScreenState extends State<WhiteScreen> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (widget.whatToDo == 'pop') {
        Navigator.pop(context);
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => widget.routename));
      }
    });

    return const Scaffold(
      body: SafeArea(
        child: Center(),
      ),
    );
  }
}
