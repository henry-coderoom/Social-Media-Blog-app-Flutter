// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bbarena_app_com/components/modal_box.dart';
import 'package:bbarena_app_com/components/verify_email_widget.dart';
import 'package:bbarena_app_com/helper/utils.dart';
import 'package:bbarena_app_com/screens/homeFire/bookmarks/bookmark_page.dart';
import 'package:bbarena_app_com/screens/homeFire/profileFireEdit/editUser_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/modern_pictograms_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bbarena_app_com/screens/logout_success/logout_success_screen.dart';
import 'package:flutter_svg/svg.dart';
import '../../Setting_Screen/settings_page.dart';

class ProfileScreenFire extends StatefulWidget {
  static String routeName = "/profileFire";

  const ProfileScreenFire({Key? key}) : super(key: key);

  @override
  State<ProfileScreenFire> createState() => _ProfileScreenFireState();
}

class _ProfileScreenFireState extends State<ProfileScreenFire> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String displayName;
  late String about;
  late String url;
  late String email;
  late String username;
  var fetch;
  bool isNoUser = false;
  bool showEmailVer = false;

  int bookmarks = 0;
  int commentCount = 0;
  bool connectionStatus = true;

  bool? isEmailVerified;

  @override
  initState() {
    fetch = newFetch();
    super.initState();
    check();
    bookLen();
    FirebaseAuth.instance.authStateChanges().listen((loggedInUser) {
      if (loggedInUser == null) {
        setState(() {
          isNoUser = true;
        });
      }
    });
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    FirebaseAuth.instance.currentUser!.reload().then((value) {});

    if (isEmailVerified == false) {
      setState(() {
        showEmailVer = true;
      });
    }
  }

  void sendEmailVerification() {
    final user = FirebaseAuth.instance.currentUser;
    user!.sendEmailVerification();
  }

  void chechAgain() {
    FirebaseAuth.instance.currentUser!.reload().then((value) {
      setState(() {
        isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      });
    });
  }

  Future check() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        connectionStatus = true;
        setState(() {});
      }
    } on SocketException catch (_) {
      connectionStatus = false;
      setState(() {});
    }
  }

  bookLen() async {
    final firebaseUser = _auth.currentUser!;
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .collection('bookmarks')
          .get();
      bookmarks = snap.docs.length;
    } catch (err) {
      showSnackBar(context, err.toString(), 3, () {}, '');
    }
    setState(() {});
  }

  comentLen() async {
    final firebaseUser = _auth.currentUser!;
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .collection('allComments')
          .get();
      commentCount = snap.docs.length;
    } catch (err) {
      showSnackBar(context, err.toString(), 3, () {}, '');
    }
    setState(() {});
  }

  showCopiedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.blue,
      content: Row(
        children: const [
          Icon(
            Icons.copy_sharp,
            color: Colors.white,
          ),
          SizedBox(
            width: 10,
          ),
          Text('Text Copied!'),
        ],
      ),
      duration: const Duration(milliseconds: 2000),
    ));
  }

  newFetch() async {
    final firebaseUser = _auth.currentUser!;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get()
        .then((ds) {
      displayName = ds['displayName'];
      username = ds['username'];
      url = ds['url'];
      email = ds['Email'];
      about = ds['about'];
    }).catchError((e) {
      showSnackBar(context, e.toString(), 2, () {}, '');
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime? userJoinDate = _auth.currentUser?.metadata.creationTime;

    //Firebase Sign out function
    Future<void> _signOutUser() async {
      try {
        final firebaseUser = FirebaseAuth.instance.currentUser;

        if (firebaseUser != null) {
          await FirebaseAuth.instance.signOut();
          await GoogleSignIn().signOut();
          Navigator.pushNamed(context, LogOutSuccessScreen.routeName);
        }
      } catch (e) {
        showSnackBar(context, e.toString(), 4, () {}, '');
        print(e);
      }
    }

    // Future<bool> _onBackPressed() {
    //   throw Navigator.pushNamed(context, ProfileScreenFire.routeName);
    // }

    Future<bool> _confirmLogout() {
      throw showDialog(
          context: context,
          builder: (context) => AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                content: const Text(
                  'Arrgh... Okay!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.transparent, elevation: 0),
                    child: const Text(
                      'Log out',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    onPressed: () => _signOutUser(),
                    //exit the app
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.transparent, elevation: 0),
                    child: const Text('Back',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    onPressed: () => Navigator.pop(context, false),
                  )
                ],
              ));
    }

    return (isNoUser == false)
        ? RefreshIndicator(
            strokeWidth: 1,
            color: Colors.black38,
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
              await check();
              setState(() {
                fetch = newFetch();
              });
            },
            child: Scaffold(
              backgroundColor: const Color(0xFFE0E0E0),
              appBar: AppBar(
                title: const Text(""),
                flexibleSpace: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 25.0, top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, SettingsPage.routeName),
                          child: SvgPicture.asset(
                            "assets/icons/Settings.svg",
                            width: 22,
                            height: 22,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () => _confirmLogout(),
                          child: SvgPicture.asset(
                            'assets/icons/Log out.svg',
                            width: 20,
                            height: 20,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: FutureBuilder(
                    future: fetch,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            color: Colors.blue,
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EmailVerify(
                            isVerified: isEmailVerified,
                            reCheck: () {
                              chechAgain();
                            },
                            sendVer: () {
                              sendEmailVerification();
                            },
                          ),
                          NoNetworkWidget(
                              isConnected: connectionStatus, reLoad: check),
                          const SizedBox(
                            height: 8,
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 15.0, left: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: SizedBox(
                                          height: 145,
                                          width: 145,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            clipBehavior: Clip.none,
                                            children: [
                                              CircleAvatar(
                                                backgroundImage:
                                                    NetworkImage(url),
                                              ),
                                              Positioned(
                                                right: 15,
                                                bottom: 10,
                                                child: SizedBox(
                                                  height: 18,
                                                  width: 18,
                                                  child: TextButton(
                                                    style: TextButton.styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        side: const BorderSide(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      primary: Colors.white,
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                    onPressed: () {},
                                                    child: SvgPicture.asset(""),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 120,
                                        child: Flexible(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '@$username',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                                maxLines: 6,
                                                textAlign: TextAlign.center,
                                              ),
                                              Center(
                                                child: displayName.contains(
                                                        '/344*7^*!!@!%??/-=13434xxww77+-0@2@')
                                                    ? const SizedBox.shrink()
                                                    : GestureDetector(
                                                        onLongPress: () async {
                                                          await Clipboard.setData(
                                                              ClipboardData(
                                                                  text:
                                                                      displayName));
                                                          showCopiedSnackbar();
                                                        },
                                                        child: AutoSizeText(
                                                          displayName,
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.black38,
                                                          ),
                                                          maxFontSize: 14,
                                                          minFontSize: 10,
                                                          maxLines: 2,
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              SizedBox(
                                                height: 30,
                                                child: TextButton(
                                                    style: TextButton.styleFrom(
                                                        // maximumSize: Size.zero,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        shape:
                                                            const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(15),
                                                          ),
                                                        ),
                                                        side: const BorderSide(
                                                            color:
                                                                Colors.blue)),
                                                    onPressed: () {
                                                      Navigator.popAndPushNamed(
                                                          context,
                                                          EditUserScreenFire
                                                              .routeName);
                                                    },
                                                    child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          SvgPicture.asset(
                                                            "assets/icons/Edit.svg",
                                                            width: 14,
                                                            color: Colors.blue,
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          const Text(
                                                            'Edit Profile',
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                        ])),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20, bottom: 20, top: 10),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '  About',
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                about.contains('/344*7^*!!@!%??/-=12@')
                                    ? GestureDetector(
                                        onTap: () => {
                                          Navigator.pushNamed(context,
                                              EditUserScreenFire.routeName)
                                        },
                                        child: StyledText(
                                          text:
                                              'Describe yourself to the community memebers, you can also mention your social handles for people to connect with you...',
                                          tags: {
                                            'bold': StyledTextTag(
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            'b': StyledTextTag(
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          },
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontStyle: FontStyle.italic,
                                              color: Color(0xFFAFAFAF)),
                                        ),
                                      )
                                    : GestureDetector(
                                        onLongPress: () async {
                                          await Clipboard.setData(
                                              ClipboardData(text: about));
                                          showCopiedSnackbar();
                                        },
                                        child: StyledText(
                                          text: '  $about ',
                                          tags: {
                                            'bold': StyledTextTag(
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            'b': StyledTextTag(
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          },
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    color: Color(0xFFF5F6F9),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30.0,
                                        top: 10,
                                        bottom: 10,
                                        right: 40),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: const [
                                                  Icon(
                                                    Icons
                                                        .perm_contact_cal_sharp,
                                                    size: 15,
                                                    color: Color(0xFFB4B4B4),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    'Member since',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 15,
                                              ),
                                              Text(timeago.format(userJoinDate!,
                                                  locale: 'en')),
                                            ],
                                          ),
                                        ),
                                        const Divider(
                                          thickness: 2,
                                          color: Colors.white,
                                        ),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: const [
                                                  Icon(
                                                    FontAwesome5.comment_dots,
                                                    size: 15,
                                                    color: Color(0xFFB4B4B4),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    'Comment count',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 15,
                                              ),
                                              SizedBox(
                                                child: (commentCount <= 1)
                                                    ? Text(
                                                        '$commentCount comment',
                                                      )
                                                    : Text(
                                                        '$commentCount comments',
                                                      ),
                                              )
                                            ],
                                          ),
                                        ),
                                        const Divider(
                                          thickness: 2,
                                          color: Colors.white,
                                        ),
                                        GestureDetector(
                                          onTap: () => Navigator.pushNamed(
                                              context, BookmarkPage.routeName),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: const [
                                                    Icon(
                                                      Octicons.bookmark,
                                                      size: 15,
                                                      color: Color(0xFFB4B4B4),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      'Bookmarks',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                SizedBox(
                                                  child: (bookmarks <= 1)
                                                      ? Text(
                                                          '$bookmarks post',
                                                        )
                                                      : Text(
                                                          '$bookmarks posts',
                                                        ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Divider(
                                          thickness: 2,
                                          color: Colors.white,
                                        ),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: const [
                                                  Icon(
                                                    ModernPictograms.mail,
                                                    size: 15,
                                                    color: Color(0xFFB4B4B4),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    'Email',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 15,
                                              ),
                                              Text('$email 🔒',
                                                  style: const TextStyle(
                                                      fontSize: 14))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              // bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.profile),
            ),
          )
        : const Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                  ),
                ),
              ),
            ),
          );
  }
}
