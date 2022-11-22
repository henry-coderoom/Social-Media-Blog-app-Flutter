import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:bbarena_app_com/helper/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../size_config.dart';
import 'defaultButton.dart';

class EmailVerify extends StatefulWidget {
  final bool? isVerified;
  final Function() reCheck;
  final Function() sendVer;

  const EmailVerify(
      {Key? key,
      required this.isVerified,
      required this.reCheck,
      required this.sendVer})
      : super(key: key);
  @override
  State<EmailVerify> createState() => EmailVerifyState();
}

class EmailVerifyState extends State<EmailVerify> {
  bool showVerify = false;
  final List<int> flag = [Flag.FLAG_ACTIVITY_NEW_TASK];

  @override
  void initState() {
    showVerify = widget.isVerified!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: (showVerify != true)
          ? Container(
              margin: const EdgeInsets.only(top: 8, bottom: 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        DefaultButton(
                          buttonText: 'Open email',
                          bgColor: Colors.transparent,
                          borderColor: Colors.transparent,
                          textColor: Colors.grey,
                          withIcon: true,
                          icon: Icons.open_in_new,
                          onTap: () async {
                            if (Platform.isAndroid) {
                              AndroidIntent intent = AndroidIntent(
                                action: 'android.intent.action.MAIN',
                                category: 'android.intent.category.APP_EMAIL',
                                flags: flag,
                              );
                              await intent.launch().catchError((e) {
                                print(e.toString());

                                showSnackBar(
                                    context, e.toString(), 2, () {}, '');
                              });
                            } else if (Platform.isIOS) {
                              launchUrlString('message://').catchError((e) {
                                showSnackBar(
                                    context, e.toString(), 2, () {}, '');
                              });
                            }
                          },
                        ),
                        DefaultButton(
                          buttonText: 'Close',
                          bgColor: Colors.transparent,
                          borderColor: Colors.transparent,
                          textColor: Colors.grey,
                          withIcon: true,
                          icon: Icons.close,
                          onTap: () {
                            setState(() {
                              showVerify = true;
                            });
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: IntrinsicWidth(
                        child: Row(
                          // alignment: WrapAlignment.center,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Text(
                                'Email Not Verified',
                                style: TextStyle(
                                    color: Colors.redAccent.shade400,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    //   child: Wrap(
                    //     // alignment: WrapAlignment.center,
                    //     children: const [
                    //       Text(
                    //         'Click on the verification link sent to your email address. Also check your spam folder.',
                    //         textAlign: TextAlign.center,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    IntrinsicWidth(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DefaultButton(
                            buttonText: 'Check again',
                            bgColor: Colors.blueGrey.shade600,
                            borderColor: Colors.transparent,
                            textColor: Colors.white,
                            withIcon: true,
                            icon: Icons.refresh_rounded,
                            onTap: () {
                              widget.reCheck();
                            },
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          DefaultButton(
                            buttonText: 'Resend link',
                            bgColor: Colors.blueGrey.shade600,
                            borderColor: Colors.transparent,
                            textColor: Colors.white,
                            withIcon: true,
                            icon: Entypo.paper_plane,
                            onTap: () {
                              widget.sendVer();
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: getProportionateScreenWidth(0)),
                      child: DefaultButton(
                        buttonText: 'Change email',
                        bgColor: Colors.transparent,
                        borderColor: Colors.transparent,
                        textColor: Colors.blue,
                        withIcon: false,
                        onTap: () {
                          widget.reCheck();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
