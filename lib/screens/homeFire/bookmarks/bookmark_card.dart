// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:timeago/timeago.dart' as timeago;
import 'dart:async';
import 'package:bbarena_app_com/resource/firebase_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:bbarena_app_com/screens/details/details_screen.dart';

class BookmarkCard extends StatefulWidget {
  final snap;
  const BookmarkCard({Key? key, required this.snap, this.postsDocId = ''})
      : super(key: key);
  final String postsDocId;

  @override
  State<BookmarkCard> createState() => _BookmarkCardState();
}

class _BookmarkCardState extends State<BookmarkCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final width = MediaQuery.of(context).size.width;

    DateTime dateSaved = (widget.snap['dateSaved']).toDate();

    final firebaseUser = _auth.currentUser;

    String postTitle = widget.snap['title'];
    String mediaUrl = widget.snap['mediaUrl'];

    Future<bool> _confirmUnsavePost() {
      throw showDialog(
          context: context,
          builder: (context) => AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                content: const Text(
                  'Remove this post from your Saved Post collection?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.transparent, elevation: 0),
                    child: const Text(
                      'Yah sure',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    onPressed: () async {
                      Navigator.pop(context, false);
                      await FireStoreMethods()
                          .unsavePost(firebaseUser?.uid, widget.snap['postId']);
                      setState(() {});
                    },
                    //exit the app
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.transparent, elevation: 0),
                    child: const Text('Cancel',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    onPressed: () => Navigator.pop(context, false),
                  )
                ],
              ));
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(children: [
          Expanded(
            flex: 6,
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DetailsScreen(
                    postId: widget.postsDocId,
                    updateComLen: () {},
                  ),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(mediaUrl), fit: BoxFit.fill)),
              ),
            ),
          ),
          const Spacer(
            flex: 1,
          ),
          Expanded(
            flex: 10,
            child: Container(
              padding: const EdgeInsets.only(top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(
                          postId: widget.postsDocId,
                          updateComLen: () {},
                        ),
                      ),
                    ),
                    child: Text(postTitle,
                        style: const TextStyle(
                            fontSize: 19.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          'Saved: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          timeago.format(dateSaved, locale: 'en'),
                          style: const TextStyle(fontSize: 12),
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
          ),
          Expanded(
            flex: 2,
            child: IconButton(
              onPressed: _confirmUnsavePost,
              icon: const Icon(
                Elusive.bookmark,
                color: Color(0xFFFFB510),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
