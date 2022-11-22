import 'package:bbarena_app_com/components/auth_options_container.dart';
import 'package:bbarena_app_com/helper/utils.dart';
import 'package:bbarena_app_com/resource/firebase_methods.dart';
import 'package:bbarena_app_com/screens/homeFire/profileFire/profile_screen.dart';
import 'package:bbarena_app_com/screens/logout_success/user_deleted_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/modern_pictograms_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/modal_box.dart';
import '../logout_success/logout_success_screen.dart';
import '../sign_in/sign_in_screen.dart';
import '../sign_up/sign_up_screen.dart';

class SettingsPage extends StatefulWidget {
  static String routeName = "/settings";

  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final loggedUser = FirebaseAuth.instance.currentUser;
  bool stateNotif = true;
  bool stateTheme = true;

  // late String username;
  // late String userImage;

  bool isDel = false;
  void _launchURL(String _url) async {
    if (!await launch(
      _url,
      forceSafariVC: true,
      forceWebView: true,
      enableJavaScript: true,
    )) throw 'Could not open $_url';
  }

  void _modalAuthOptionsMain(BuildContext context) {
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
            ));
      },
    );
  }

  Future deleteUserAuth(String email, String password) async {
    try {
      AuthCredential credentials =
          EmailAuthProvider.credential(email: email, password: password);
      final result =
          await loggedUser?.reauthenticateWithCredential(credentials);

      await result?.user?.delete();

      return true;
    } catch (e) {
      showSnackBar(context, e.toString(), 5, () {}, '');
      return null;
    }
  }

  Future<void> deleteUser() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(loggedUser?.uid)
          .get()
          .then((doc) async {
        final String username = doc['username'];
        final String userImage = doc['newImage'];
        final String email = doc['Email'];
        final String password = doc['password'];
        if (password != loggedUser?.uid) {
          deleteUserAuth(email, password);
        }
        await FireStoreMethods().deleteUsername(
          username,
        );
        await FireStoreMethods().deleteUserDoc(loggedUser?.uid, userImage);
        await FirebaseAuth.instance.currentUser?.delete();
        await GoogleSignIn().signOut();
        await FirebaseAuth.instance.signOut();
      });

      Navigator.pushNamed(context, UserDelete.routeName);
    } catch (e) {
      final snackBar = SnackBar(content: Text(e.toString()));
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  void _showLoadingModal(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x88000000),
      context: context,
      builder: (context) {
        return ModalBox(
            refresh: () {
              deleteUser();
            },
            modalWidget: buildLoadingModalWidget());
      },
    );
  }

  Future<void> _signOutF() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        await FirebaseAuth.instance.signOut();

        Navigator.pushNamed(context, LogOutSuccessScreen.routeName);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> _delAccount() {
    throw showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              content: const Text('Do you really want to delete your account?',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.transparent,
                    elevation: 0,
                  ),
                  child: const Text('No',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  onPressed: () => Navigator.pop(context, false),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.transparent, elevation: 0),
                  child: const Text('Logout Instead',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  onPressed: () => _signOutF(),
                  //exit the app
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.transparent, elevation: 0),
                  child: isDel == true
                      ? Container(
                          height: 15,
                          width: 15,
                          margin: const EdgeInsets.all(10),
                          child: const CircularProgressIndicator(
                            color: Colors.red,
                            strokeWidth: 1.5,
                          ),
                        )
                      : const Text('Yes',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                  onPressed: () async {
                    Navigator.pop(context, false);
                    _showLoadingModal(context);
                  },
                  //exit the app
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 15),
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          buildTopText(
            context,
            'APP THEME',
            Icons.brightness_4,
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            color: Color(0xFFF1F1F1),
            height: 15,
            thickness: 1,
          ),
          const SizedBox(
            height: 10,
          ),
          buildSettingsMenuWidget(
            context,
            'Toggle light or dark mode',
            Colors.black,
            Transform.scale(
              scale: 1,
              child: Switch(
                activeColor: Colors.green,
                activeTrackColor: Colors.greenAccent.shade100,
                value: stateTheme,
                onChanged: (bool val) {
                  setState(() {
                    stateTheme = val;
                  });
                },
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          buildTopText(
            context,
            'GENERAL',
            Octicons.settings,
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            height: 15,
            color: Color(0xFFF1F1F1),
            thickness: 1,
          ),
          const SizedBox(
            height: 5,
          ),
          TextButton(
            child: buildSettingsMenuWidget(
              context,
              'Account',
              Colors.black,
              const Icon(
                Icons.arrow_forward_ios_outlined,
                color: Colors.grey,
                size: 15,
              ),
            ),
            onPressed: (loggedUser == null)
                ? () {
                    _modalAuthOptionsMain(context);
                  }
                : () {
                    Navigator.pushNamed(context, ProfileScreenFire.routeName);
                  },
          ),
          TextButton(
            onPressed: () {
              _launchURL('https://www.iusecoupon.com');
            },
            child: buildSettingsMenuWidget(
              context,
              'Privacy Policy',
              Colors.black,
              const Icon(
                Icons.arrow_forward_ios_outlined,
                color: Colors.grey,
                size: 15,
              ),
            ),
          ),
          TextButton(
              onPressed: () {},
              child: buildSettingsMenuWidget(
                context,
                'Terms & Conditions',
                Colors.black,
                const Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Colors.grey,
                  size: 15,
                ),
              )),
          TextButton(
              onPressed: () {},
              child: buildSettingsMenuWidget(
                context,
                'About',
                Colors.black,
                const Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Colors.grey,
                  size: 15,
                ),
              )),
          TextButton(
              onPressed: () {},
              child: buildSettingsMenuWidget(
                context,
                'Feedback',
                Colors.black,
                const Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Colors.grey,
                  size: 15,
                ),
              )),
          TextButton(
              onPressed: () {},
              child: buildSettingsMenuWidget(
                context,
                'Rate Us',
                Colors.black,
                const Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Colors.grey,
                  size: 15,
                ),
              )),
          const SizedBox(
            height: 40,
          ),
          buildTopText(
            context,
            'NOTIFICATIONS',
            Entypo.bell,
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            color: Color(0xFFF1F1F1),
            height: 15,
            thickness: 1,
          ),
          const SizedBox(
            height: 10,
          ),
          buildSettingsMenuWidget(
            context,
            'Enable App Notifications',
            Colors.black,
            Transform.scale(
              scale: 1,
              child: Switch(
                activeColor: Colors.green,
                activeTrackColor: Colors.greenAccent.shade100,
                value: stateNotif,
                onChanged: (bool value) {
                  setState(
                    () {
                      stateNotif = value;
                      if (stateNotif == true) {
                        FirebaseMessaging.instance.subscribeToTopic('Update');
                      } else {
                        FirebaseMessaging.instance
                            .unsubscribeFromTopic('Update');
                      }
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          buildTopText(context, 'ADVANCED', ModernPictograms.wrench),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            color: Color(0xFFF1F1F1),
            height: 15,
            thickness: 1,
          ),
          const SizedBox(
            height: 10,
          ),
          TextButton(
            child: buildSettingsMenuWidget(
                context, 'Clear cache', Colors.black, const SizedBox.shrink()),
            onPressed: () {},
          ),
          TextButton(
            child: buildSettingsMenuWidget(
                context, 'App version', Colors.black, const Text('1.0.0')),
            onPressed: () {},
          ),
          SizedBox(
            child: (loggedUser == null)
                ? TextButton(
                    child: buildSettingsMenuWidget(context, 'Signup or Log in',
                        Colors.green, const SizedBox.shrink()),
                    onPressed: () {
                      _modalAuthOptionsMain(context);
                    },
                  )
                : TextButton(
                    child: buildSettingsMenuWidget(context, 'Delete account',
                        Colors.red, const SizedBox.shrink()),
                    onPressed: () {
                      _delAccount();
                    },
                  ),
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }

  Padding buildTopText(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade500,
          ),
          const SizedBox(
            width: 15,
          ),
          Text(
            title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  SizedBox buildSettingsMenuWidget(
    BuildContext context,
    String title,
    Color color,
    Widget trail,
  ) {
    return SizedBox(
      child: ListTile(
          dense: true,
          visualDensity: const VisualDensity(vertical: -4),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          trailing: trail),
    );
  }

  Container buildLoadingModalWidget() {
    return Container(
      color: Colors.transparent,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
