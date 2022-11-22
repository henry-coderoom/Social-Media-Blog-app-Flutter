import 'package:flutter/material.dart';
import 'package:bbarena_app_com/constants.dart';
import 'package:bbarena_app_com/size_config.dart';

import 'sign_up_form.dart';

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
                SizedBox(height: SizeConfig.screenHeight * 0.04), // 4%
                Wrap(
                    alignment: WrapAlignment.center,
                    children: [Text("Sign Up", style: headingStyle)]),
                const SizedBox(height: 25),
                const SignUpForm(),
                SizedBox(height: SizeConfig.screenHeight * 0.03),
                Wrap(
                  children: [
                    Text(
                      'By continuing, you hereby confirm that you\'ve read out privacy policy and agree to our Terms, of service.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.caption,
                    )
                  ],
                ),
                SizedBox(height: getProportionateScreenHeight(30)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
