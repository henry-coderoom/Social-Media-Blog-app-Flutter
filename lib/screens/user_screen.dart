import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bbarena_app_com/components/modal_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/modern_pictograms_icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../helper/utils.dart';

class UserScreen extends StatefulWidget {
  static String routeName = "/userPage";

  final userId;

  const UserScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<UserScreen> createState() => UserScreenState();
}

class UserScreenState extends State<UserScreen> {
  late String displayName;
  late String about;
  late String url;
  late String email;
  DateTime dateJoined = DateTime.now();
  late String username;
  int commentCount = 0;
  var fetch;

  @override
  initState() {
    fetch = newFetch();
    check();
    comentLen();
    super.initState();
  }

  comentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('allComments')
          .get();
      commentCount = snap.docs.length;
    } catch (err) {
      showSnackBar(context, err.toString(), 3, () {}, '');
    }
    setState(() {});
  }

  bool connectionStatus = true;
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

  Future<void> newFetch() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get()
        .then((ds) {
      displayName = ds['displayName'];
      username = ds['username'];
      url = ds['url'];
      email = ds['Email'];
      about = ds['about'];
      dateJoined = ds['dateJoined'].toDate();
    }).catchError((e) {
      final snackBar = SnackBar(content: Text(e.toString()));
      Scaffold.of(context).showSnackBar(snackBar);
    });
  }

  @override
  Widget build(BuildContext context) {
    String userJoinDate = timeago.format(dateJoined, locale: 'en');

    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: RefreshIndicator(
        strokeWidth: 1,
        color: Colors.black38,
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          await check();
          setState(() {
            fetch = newFetch();
          });
        },
        child: SingleChildScrollView(
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
                      strokeWidth: 1.5,
                      color: Colors.blue,
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            padding:
                                const EdgeInsets.only(right: 15.0, left: 10),
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
                                          backgroundImage: NetworkImage(url),
                                        ),
                                        Positioned(
                                          right: 15,
                                          bottom: 10,
                                          child: SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  side: const BorderSide(
                                                      color: Colors.white),
                                                ),
                                                primary: Colors.white,
                                                backgroundColor: Colors.green,
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
                                                            text: displayName));
                                                    showCopiedSnackbar();
                                                  },
                                                  child: AutoSizeText(
                                                    displayName,
                                                    style: const TextStyle(
                                                      color: Colors.black38,
                                                    ),
                                                    maxFontSize: 14,
                                                    minFontSize: 10,
                                                    maxLines: 2,
                                                    textAlign: TextAlign.center,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                        ),
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
                                  onTap: () {},
                                  child: StyledText(
                                    text: 'No User Description yet...',
                                    tags: {
                                      'bold': StyledTextTag(
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      'b': StyledTextTag(
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
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
                                              fontWeight: FontWeight.bold)),
                                      'b': StyledTextTag(
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
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
                                  left: 30.0, top: 10, bottom: 10, right: 40),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                              Icons.perm_contact_cal_sharp,
                                              size: 15,
                                              color: Color(0xFFB4B4B4),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'Member since',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Text(timeago.format(dateJoined,
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
                                                  fontWeight: FontWeight.bold),
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
      ),
      // bottomNavigationBar: CustomBottomNavBar(selectedMenu: MenuState.profile),
    );
  }
}
