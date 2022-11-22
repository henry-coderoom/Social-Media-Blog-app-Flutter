import 'dart:io';

import 'package:bbarena_app_com/components/modal_box.dart';
import 'package:bbarena_app_com/screens/homeFire/bookmarks/bookmark_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookmarkPage extends StatefulWidget {
  static String routeName = "/bookmarks";

  const BookmarkPage({Key? key}) : super(key: key);

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage>
    with AutomaticKeepAliveClientMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var stream;
  bool isLoading = true;

  @override
  void initState() {
    bookLen();
    check();
    super.initState();
    stream = newStream();
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

  int bookmarks = 0;

  bookLen() async {
    final firebaseUser = _auth.currentUser!;
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .collection('bookmarks')
          .get();
      bookmarks = snap.docs.length;
      setState(() {
        isLoading = false;
      });
    } catch (err) {}
    setState(() {});
  }

  Stream<QuerySnapshot> newStream() {
    final user = _auth.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user)
        .collection('bookmarks')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Your Saved Posts - $bookmarks',
          style: const TextStyle(
            fontSize: 16,
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
                ),
              )
            : RefreshIndicator(
                strokeWidth: 1,
                color: Colors.black38,
                onRefresh: () async {
                  await Future.delayed(const Duration(seconds: 1));
                  check();
                  setState(() {
                    stream = newStream();
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
                        },
                      ),
                      Center(
                          child: bookmarks == 0
                              ? Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Elusive.bookmark,
                                        size: 60,
                                        color: Color(0xFFFFB510),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        'No Bookmarks!',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Text(
                                          'You haven\'t saved any posts yet! Click on the \'Bookmark\' icon beside any post to add the post to your Saved Post collection',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Text(
                                      'Click on any item to open the full post'),
                                )),
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
                              itemBuilder: (context, index) => BookmarkCard(
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
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
