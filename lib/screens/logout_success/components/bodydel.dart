import 'package:flutter/material.dart';
import 'package:bbarena_app_com/size_config.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

import '../../../components/auth_options_container.dart';
import '../../../components/modal_box.dart';
import '../../homeFire/home_screen.dart';

class BodyDel extends StatefulWidget {
  final String loggedUser;
  const BodyDel({Key? key, required this.loggedUser}) : super(key: key);

  @override
  State<BodyDel> createState() => _BodyDelState();
}

class _BodyDelState extends State<BodyDel> {
  void _showModalAuthOptions(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x88000000),
      context: context,
      builder: (context) {
        return ModalBox(
          refresh: () {},
          modalWidget: AuthOptionsContainer(
            leadingText:
                'Join the biggest and most interactive meme and entertainment community',
            topIcon: Icon(
              Elusive.group_circled,
              size: 40,
              color: Colors.yellow.shade900,
            ),
            refresh: () {},
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: SizeConfig.screenHeight * 0.04),
          const Icon(
            FontAwesome5.user_times,
            size: 67,
            color: Colors.grey,
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.02),
          Text(
            "Account Deleted!",
            style: TextStyle(
              fontSize: getProportionateScreenWidth(30),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Center(
              child: Padding(
            padding: EdgeInsets.only(
              left: 20.0,
              right: 20,
            ),
            child: Text(
              'We hate to see you go, hoping to have you on board again soon. You can let us know your grievances via our feedback page.',
              style: TextStyle(fontSize: 17),
            ),
          )),
          const SizedBox(
            height: 30,
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
                        elevation: 0,
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 2),
                        side: const BorderSide(
                            color: Color(0x11000000), width: 1),
                        backgroundColor: const Color(0x3C1A2126),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(18),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, HomeScreenFire.routeName);
                      },
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
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
                        padding: const EdgeInsets.only(
                            left: 22, right: 15, bottom: 2),
                        side: const BorderSide(
                            color: Color(0x11000000), width: 1),
                        backgroundColor: const Color(0x51ACACAC),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(18),
                          ),
                        ),
                      ),
                      onPressed: (widget.loggedUser != 'no')
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: const [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text('You already logged in!'),
                                    ],
                                  ),
                                ),
                              );
                            }
                          : () {
                              _showModalAuthOptions(context);
                            },
                      child: const Text(
                        'SignUp or SignIn',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
