import 'package:bbarena_app_com/screens/sign_up/sign_up_screen.dart';
import 'package:bbarena_app_com/screens/white_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uuid/uuid.dart';

import '../authServices.dart';
import '../screens/sign_in/sign_in_screen.dart';
import '../screens/wallet_screens/create_wallet.dart';
import 'modal_box.dart';

import 'package:bbarena_app_com/authServices.dart';
import '../../../size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthOptionsContainer extends StatefulWidget {
  const AuthOptionsContainer(
      {Key? key,
      required this.refresh,
      required this.topIcon,
      required this.leadingText})
      : super(key: key);
  final Widget topIcon;
  final String leadingText;
  final Function() refresh;
  @override
  State<AuthOptionsContainer> createState() => AuthOptionsContainerState();
}

class AuthOptionsContainerState extends State<AuthOptionsContainer> {
  bool startGoogleLoading = false;
  DateTime dateJoined = DateTime.now();
  String about = '/344*7^*!!@!%??/-=12@';
  late String defaultImage;

  fetchUserImage() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc('defaultUserImage')
        .get()
        .then((ds) {
      defaultImage = ds['defaultImage'];
    }).catchError((e) {
      final snackBar = SnackBar(content: Text(e.toString()));
      Scaffold.of(context).showSnackBar(snackBar);
    });
  }

  Future<void> _googleSignIn() async {
    setState(() {
      startGoogleLoading = true;
    });
    final googleUser = await AuthServices.signInWithGoogle(context: context);
    if (googleUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(googleUser.uid)
          .get()
          .then((doc) async {
        if (doc.exists) {
          setState(() {
            startGoogleLoading = false;
          });
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
                  Text('Success!'),
                ],
              ),
            ),
          );

          Navigator.pop(context);
        } else {
          final String num = const Uuid().v1();
          final String trimmed = num.substring(0, num.length - 32);
          final String? googleUserEmail = googleUser.email;
          final nameToCheck =
              googleUserEmail?.substring(0, googleUserEmail.length - 10);
          final bool isNameAvail = await FirebaseFirestore.instance
              .collection('usernames')
              .doc(nameToCheck)
              .get()
              .then((doc) {
            return doc.exists;
          });
          final String? username =
              (isNameAvail == false) ? nameToCheck : nameToCheck! + trimmed;
          final String? name = googleUser.displayName;
          final String? photoUrl = googleUser.photoURL ?? defaultImage;

          await storeNewUserGoogle(googleUser, username!, name!, photoUrl!);
          setState(() {
            startGoogleLoading = false;
          });
          Navigator.pop(context);
        }
      });
    } else {
      setState(() {
        startGoogleLoading = false;
      });
    }
  }

  Future<void> storeNewUserGoogle(
      User user, String username, String name, String photoUrl) async {
    String privKey = '';
    String pubKey = '';
    String phrase = '';
    await FirebaseFirestore.instance
        .collection("usernames")
        .doc(username)
        .set({
          'username': username,
          'uid': user.uid,
        })
        .then((value) {})
        .catchError((e) {
          if (kDebugMode) {
            print(e);
          }
        });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
          'newImage': '!@!@',
          'url': photoUrl,
          'displayName': name,
          'username': username,
          'about': about,
          'uid': user.uid,
          'Email': user.email,
          'isPhoneVerified': false,
          'isVerified': false,
          'isAdmin': false,
          'isSuperAdmin': false,
          'password': user.uid,
          'privateKey': privKey,
          'publicKey': pubKey,
          'walletCreated': false,
          'phrase': phrase,
          'dateJoined': dateJoined,
        })
        .then((value) {})
        .catchError((e) {
          if (kDebugMode) {
            print(e);
          }
        });
  }

  @override
  void initState() {
    fetchUserImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      childWidget: IntrinsicHeight(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: TextButton(
                onPressed: () {},
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 40),
                        child: Center(child: widget.topIcon),
                      ),
                      Text(
                        widget.leadingText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Expanded(
                flex: 0,
                child: SizedBox(
                  height: 0,
                )),
            Center(
              child: (startGoogleLoading)
                  ? SizedBox(
                      height: (startGoogleLoading == true) ? 16 : 0,
                      width: (startGoogleLoading) ? 16 : 0,
                      child: const CircularProgressIndicator(
                        strokeWidth: 1.5,
                      ))
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 10),
            buildButtons(
                'Continue with Google',
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: SvgPicture.asset(
                    'assets/icons/google-icon.svg',
                    height: 20,
                    width: 20,
                  ),
                ), () {
              if (startGoogleLoading == false) {
                _googleSignIn();
              } else {}
            }, Colors.grey.shade300),
            const SizedBox(
              height: 6,
            ),
            buildButtons(
                'Continue with Apple ID',
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: SvgPicture.asset(
                    'assets/icons/apple_logo.svg',
                    color: Colors.black,
                    height: 22,
                    width: 22,
                  ),
                ),
                () {},
                Colors.grey.shade300),
            const SizedBox(
              height: 6,
            ),
            buildButtons(
                'Sign up with email',
                const Icon(
                  Icons.person_add,
                  color: Color(0xFF929292),
                ), () {
              if (startGoogleLoading == false) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WhiteScreen(
                      refresh: () {},
                      routename: const SignUpScreen(),
                      whatToDo: 'stay',
                    ),
                  ),
                );
              } else {}
            }, Colors.grey.shade300),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                side: const BorderSide(
                  color: Colors.transparent,
                ),
                elevation: 0,
              ),

              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  dense: true,
                  visualDensity:
                      const VisualDensity(horizontal: -4, vertical: -4),
                  title: Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                          fontSize: 16,
                          color: (startGoogleLoading)
                              ? Colors.grey.shade400
                              : Colors.blue,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
              onPressed: () {
                if (startGoogleLoading == false) {
                  Navigator.pushNamed(context, SignInScreen.routeName);
                } else {}
              },
              //exit the app
            ),

            // buildButtons('Login', const SizedBox.shrink(), () {
            //   if (startGoogleLoading == false) {
            //     Navigator.pop(context);
            //     Navigator.pushNamed(context, SignInScreen.routeName);
            //   } else {}
            // }, Colors.transparent),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Wrap(
                children: const [
                  Text(
                    'By continuing, you agree to our terms of service and acknowledge that you\'ve read our privacy policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.black26,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
      refresh: () {},
    );
  }

  Container buildButtons(
      String buttonText, Widget leadIcon, Function() function, Color color) {
    return Container(
      margin: const EdgeInsets.only(top: 0, bottom: 5),
      padding: const EdgeInsets.symmetric(
        horizontal: 45,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.transparent,
          side: BorderSide(color: color),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
        ),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8),
          child: ListTile(
            dense: true,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            leading: leadIcon,
            title: Center(
              child: Text(
                buttonText,
                style: TextStyle(
                    fontSize: 16,
                    color: (startGoogleLoading)
                        ? Colors.grey.shade400
                        : Colors.black,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
        onPressed: () {
          function();
        },
        //exit the app
      ),
    );
  }
}
