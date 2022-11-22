import 'package:bbarena_app_com/screens/feedback_screen/components/feedback_submit_page.dart';
import 'package:flutter/material.dart';
import 'package:bbarena_app_com/size_config.dart';

import '../../../../constants.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
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
                const SizedBox(height: 10), // 4%
                Text("Submit Feedback", style: headingStyle),

                // const Text('Upload New Display Picture'),
                const SizedBox(
                  height: 15,
                ),
                const FeedbackPage(),
                SizedBox(height: SizeConfig.screenHeight * 0.08),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
