import 'package:flutter/material.dart';
import 'package:bbarena_app_com/constants.dart';
import 'package:bbarena_app_com/size_config.dart';

import 'change_password_form.dart';

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: SizeConfig.screenHeight * 0.03),
                Text("Choose New Password", style: headingStyle),
                SizedBox(height: SizeConfig.screenHeight * 0.06),
                const ChangePasswordForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
