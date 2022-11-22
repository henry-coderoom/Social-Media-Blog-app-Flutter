import 'dart:io';
import 'package:bbarena_app_com/components/modal_box.dart';
import 'package:bbarena_app_com/helper/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'notif_card.dart';

class NotifScreen extends StatefulWidget {
  static String routeName = "/notifs";

  const NotifScreen({Key? key}) : super(key: key);

  @override
  State<NotifScreen> createState() => _NotifScreenState();
}

class _NotifScreenState extends State<NotifScreen>
    with AutomaticKeepAliveClientMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var stream;
  bool isLoading = true;

  @override
  void initState() {
    check();
    notifLen();
    super.initState();
    stream = newNotifs();
  }

  int notifs = 0;
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

  notifLen() async {
    final firebaseUser = _auth.currentUser!;
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .collection('notifs')
          .get();
      notifs = snap.docs.length;
      setState(() {
        isLoading = false;
      });
    } catch (err) {
      showSnackBar(context, err.toString(), 3, () {}, '');
    }
    setState(() {});
  }

  Stream<QuerySnapshot> newNotifs() {
    final user = _auth.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user)
        .collection('notifs')
        .orderBy('dateSent', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading == true
            ? const Center(
                child: SizedBox(
                height: 35,
                width: 35,
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  color: Colors.black54,
                ),
              ))
            : RefreshIndicator(
                strokeWidth: 1,
                color: Colors.black38,
                onRefresh: () async {
                  await Future.delayed(const Duration(seconds: 1));
                  await check();
                  setState(() {
                    stream = newNotifs();
                  });
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      NoNetworkWidget(
                          isConnected: connectionStatus,
                          reLoad: () {
                            check();
                          }),
                      Center(
                        child: notifs == 0
                            ? Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.notifications_paused_sharp,
                                      size: 80,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'No Notifications!',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 18),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'You don\'t have any notifiactions for now.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      StreamBuilder(
                          stream: stream,
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center();
                            }
                            return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) => NotifCard(
                                snap: snapshot.data!.docs[index].data(),
                                postsDocId:
                                    snapshot.data!.docs[index].id.toString(),
                              ),
                            );
                          }),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
