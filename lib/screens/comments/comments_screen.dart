// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bbarena_app_com/screens/comments/comment_card.dart';
import 'comment_card.dart';

class CommentsScreen extends StatefulWidget {
  final postId;
  final Function() update;
  final Function() updateMainCom;

  const CommentsScreen({
    Key? key,
    required this.postId,
    required this.update,
    required this.updateMainCom,
  }) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController commentEditingController =
      TextEditingController();
  var stream;

  @override
  void initState() {
    super.initState();
    stream = newStream();
  }

  Stream<QuerySnapshot> newStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .orderBy('upvotes', descending: true)
        .snapshots();
  }

  // static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Future<List<DocumentSnapshot>> fetchLeaderBoard() async {
  //   final result =
  //   await _firestore.collection('users').orderBy('points', descending: true).limit(10).get();
  //   return result.docs;
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const ScrollPhysics(),
          child: Column(
            children: [
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (ctx, index) => CommentCard(
                  snap: snapshot.data!.docs[index],
                  postId: widget.postId,
                  updateComCount: () {
                    widget.update();
                  },
                  updateMain: () {
                    widget.updateMainCom();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
