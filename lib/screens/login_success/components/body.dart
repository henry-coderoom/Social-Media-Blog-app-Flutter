import 'package:bbarena_app_com/screens/homeFire/home_screen.dart';
import 'package:bbarena_app_com/screens/homeFire/profileFire/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:bbarena_app_com/size_config.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    // Future.delayed(const Duration(seconds: 1), () {
    //   Navigator.pushNamed(context, HomeScreenFire.routeName);
    // });

    return Center(
      child: IntrinsicHeight(
        child: Column(
          children: [
            SizedBox(height: SizeConfig.screenHeight * 0.04),
            Image.asset(
              "assets/images/success.png",
              height: SizeConfig.screenHeight * 0.3, //40%
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.05),
            Wrap(children: [
              Text(
                "Signup Successful",
                style: TextStyle(
                  fontSize: getProportionateScreenWidth(25),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ]),
            const SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Wrap(children: const [
                Text(
                  "You can view and edit your profile on your profile page",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black38,
                  ),
                ),
              ]),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: IntrinsicWidth(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(
                              left: 22, right: 22, bottom: 2),
                          side: const BorderSide(
                              color: Color(0x0a000000), width: 1),
                          backgroundColor: const Color(0x32ACACAC),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(18),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                              context, ProfileScreenFire.routeName);
                        },
                        child: const Text(
                          'Go to Profile',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          elevation: 0,
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 2),
                          side: const BorderSide(
                              color: Color(0x0a000000), width: 1),
                          backgroundColor: const Color(0x4D138EE8),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(18),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                              context, HomeScreenFire.routeName);
                        },
                        child: const Text(
                          'Skip to Home',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
