import 'package:flutter/material.dart';
import 'package:bbarena_app_com/size_config.dart';
import 'package:bbarena_app_com/widgets/exit-popup.dart';
import 'package:bbarena_app_com/screens/homeFire/giveawayFire/components/body.dart';

class GiveScreenFire extends StatelessWidget {
  static String routeName = "/giveawayFire";

  const GiveScreenFire({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // You have to call it on your starting screen
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: const Scaffold(
        body: BodyGiveFire(),
      ),
    );
  }
}
