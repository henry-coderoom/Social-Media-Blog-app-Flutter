// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:bbarena_app_com/resource/firebase_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../deleted_user_screen.dart';
import '../../helper/utils.dart';
import '../homeFire/profileFire/profile_screen.dart';
import '../user_screen.dart';

class CommentReplyCard extends StatefulWidget {
  final snap;
  final snap1;
  final commentId;
  final postId;
  final ownerId;
  final Function() fetchReplyLen;
  final Function() updateRepLenComScreen;
  final Function() replyUser;

  const CommentReplyCard({
    Key? key,
    this.snap,
    this.snap1,
    this.postId,
    required this.ownerId,
    this.commentId,
    required this.replyUser,
    required this.updateRepLenComScreen,
    required this.fetchReplyLen,
  }) : super(key: key);

  @override
  State<CommentReplyCard> createState() => _CommentReplyCardState();
}

class _CommentReplyCardState extends State<CommentReplyCard> {
  bool isAvail = false;

  @override
  Widget build(BuildContext context) {
    void openTaggedUser(String taggedUserId) async {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final firebaseUser = _auth.currentUser;
      if (taggedUserId == firebaseUser?.uid) {
        setState(() {
          isAvail = false;
        });
        Navigator.pushNamed(context, ProfileScreenFire.routeName);
      } else {
        setState(() {
          isAvail = false;
        });
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserScreen(
              userId: taggedUserId,
            ),
          ),
        );
      }
    }

    void checkTaggedUser(String taggedText) async {
      await FirebaseFirestore.instance
          .collection('usernames')
          .doc(taggedText)
          .get()
          .then((doc) async {
        if (doc.exists) {
          late String taggedUserId;
          await FirebaseFirestore.instance
              .collection('usernames')
              .doc(taggedText)
              .get()
              .then((ds) {
            taggedUserId = ds['uid'];
          }).catchError((e) {
            showSnackBar(context, e.toString(), 2, () {}, '');
          });
          openTaggedUser(taggedUserId);
        } else {
          setState(() {
            isAvail = false;
          });
          showSnackBar(context, "No such user", 1, () {}, '');
        }
      });
    }

    final List<InlineSpan> textSpans = [];
    final String text = widget.snap.data()['text'];
    final RegExp regex = RegExp(r"\@(\w+)");
    final Iterable<Match> matches = regex.allMatches(text);
    int start = 0;
    for (final Match match in matches) {
      textSpans.add(TextSpan(
        text: text.substring(start, match.start),
        style: const TextStyle(fontSize: 17),
      ));
      textSpans.add(WidgetSpan(
          child: GestureDetector(
              onTap: () {
                setState(() {
                  isAvail = true;
                });
                checkTaggedUser('${match.group(1)}');
              },
              child: Text('@${match.group(1)}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 20,
                  )))));
      start = match.end;
    }
    textSpans.add(TextSpan(
        text: text.substring(start, text.length),
        style: const TextStyle(fontSize: 17)));

    final FirebaseAuth _auth = FirebaseAuth.instance;
    DateTime datePosted = (widget.snap['datePublished']).toDate();

    final firebaseUser = _auth.currentUser;

    Future<bool> _confirmDeleteReply() {
      throw showDialog(
          context: context,
          builder: (context) => AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                content: const Text('Do you want to delete this reply?'),
                actions: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.transparent, elevation: 0),
                    child: const Text('No',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    onPressed: () => Navigator.pop(context, false),
                    //exit the app
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.transparent, elevation: 0),
                    child: const Text('Yes',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    onPressed: () async {
                      FireStoreMethods().deleteReply(
                          widget.commentId,
                          widget.postId,
                          widget.snap['commentReplyId'],
                          firebaseUser?.uid,
                          widget.ownerId,
                          widget.snap['commentImage']);
                      widget.fetchReplyLen();
                      widget.updateRepLenComScreen();
                      Navigator.pop(context, false);
                      // CommentsReplyScreen(postDocsId: widget.postId, commentId: null,).
                    },
                  ),
                ],
              ));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, right: 6, bottom: 5),
          child: Container(
            padding: const EdgeInsets.only(top: 10, right: 10, left: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F8F8),
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: widget.snap.data()['uid'].contains(firebaseUser?.uid)
                      ? () => Navigator.pushNamed(
                          context, ProfileScreenFire.routeName)
                      : () async {
                          setState(() {
                            isAvail = true;
                          });
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.snap.data()['uid'])
                              .get()
                              .then((doc) async {
                            if (doc.exists) {
                              setState(() {
                                isAvail = false;
                              });
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => UserScreen(
                                    userId: widget.snap.data()['uid'],
                                  ),
                                ),
                              );
                            } else {
                              setState(() {
                                isAvail = false;
                              });
                              Navigator.pushNamed(
                                  context, DeletedUserScreen.routeName);
                            }
                          });
                        },
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          widget.snap.data()['profilePic'],
                        ),
                        radius: 16,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        child: isAvail == true
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Colors.grey,
                                ),
                              )
                            : const SizedBox.shrink(),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Text(),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: widget.snap
                                        .data()['uid']
                                        .contains(firebaseUser?.uid)
                                    ? () => Navigator.pushNamed(
                                        context, ProfileScreenFire.routeName)
                                    : () async {
                                        setState(() {
                                          isAvail = true;
                                        });
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(widget.snap.data()['uid'])
                                            .get()
                                            .then((doc) async {
                                          if (doc.exists) {
                                            setState(() {
                                              isAvail = false;
                                            });
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UserScreen(
                                                  userId:
                                                      widget.snap.data()['uid'],
                                                ),
                                              ),
                                            );
                                          } else {
                                            setState(() {
                                              isAvail = false;
                                            });
                                            Navigator.pushNamed(context,
                                                DeletedUserScreen.routeName);
                                          }
                                        });
                                      },
                                child: Text(
                                  widget.snap.data()['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF282828),
                                  ),
                                ),
                              ),
                              Text(
                                '  •  ${timeago.format(datePosted, locale: 'en_short')}',
                                style: const TextStyle(
                                    color: Colors.black38,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: widget.snap
                                  .data()['text']
                                  .contains('/344*7^*!!@!%??/-=12@')
                              ? const EdgeInsets.only(left: 0.0, top: 0)
                              : const EdgeInsets.only(left: 4.0, top: 4),
                          child: widget.snap
                                  .data()['text']
                                  .contains('/344*7^*!!@!%??/-=12@')
                              ? const SizedBox.shrink()
                              : GestureDetector(
                                  onLongPress: () async {
                                    await Clipboard.setData(ClipboardData(
                                        text: widget.snap.data()['text']));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
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
                                      duration:
                                          const Duration(milliseconds: 2000),
                                    ));
                                  },
                                  child: Text.rich(
                                    TextSpan(children: textSpans),
                                  ),
                                ),
                        ),
                        SizedBox(
                          child: widget.snap
                                  .data()['commentImage']
                                  .contains('!@!@')
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: widget.snap
                                          .data()['text']
                                          .contains('/344*7^*!!@!%??/-=12@')
                                      ? const EdgeInsets.only(top: 10.0)
                                      : const EdgeInsets.only(top: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.network(
                                      widget.snap.data()['commentImage'],
                                      height: 210,
                                      width: 210,
                                      fit: BoxFit.cover,
                                      // placeholder: (context, url) =>
                                      //     const CircularProgressIndicator(),
                                      // errorWidget: (context, url, error) =>
                                      //     const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: Row(
                                children: [
                                  InkWell(
                                    child: const Text(
                                      'Reply',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onTap: () {
                                      widget.replyUser();
                                    },
                                  ),
                                  IconButton(
                                    onPressed: widget.snap
                                            .data()['uid']
                                            .contains(firebaseUser?.uid)
                                        ? _confirmDeleteReply
                                        : null,
                                    icon: widget.snap
                                            .data()['uid']
                                            .contains(firebaseUser?.uid)
                                        ? const Icon(
                                            FontAwesome5.trash_alt,
                                            color: Color(0xFFD0D0D0),
                                            size: 14,
                                          )
                                        : const Icon(
                                            Icons.circle,
                                            size: 0,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(right: 40),
                              child: Row(
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: widget.snap
                                            .data()['downvotes']
                                            .contains(firebaseUser?.uid)
                                        ? () async {
                                            await FireStoreMethods()
                                                .removecommentReplyDownvote(
                                                    widget.postId,
                                                    widget.commentId,
                                                    widget.snap.data()[
                                                        'commentReplyId'],
                                                    firebaseUser?.uid,
                                                    widget.snap
                                                        .data()['downvotes']);
                                            await FireStoreMethods()
                                                .addCommentReplyUpvote(
                                                    widget.postId,
                                                    widget.commentId,
                                                    widget.snap.data()[
                                                        'commentReplyId'],
                                                    firebaseUser?.uid,
                                                    widget.snap
                                                        .data()['upvotes']);
                                          }
                                        : () async {
                                            await FireStoreMethods()
                                                .commentReplyUpvote(
                                                    widget.postId,
                                                    widget.commentId,
                                                    widget.snap.data()[
                                                        'commentReplyId'],
                                                    firebaseUser?.uid,
                                                    widget.snap
                                                        .data()['upvotes']);
                                          },
                                    icon: widget.snap
                                            .data()['upvotes']
                                            .contains(firebaseUser?.uid)
                                        ? const Icon(Typicons.up,
                                            color: Colors.blue, size: 18)
                                        : const Icon(Typicons.up_outline,
                                            color: Colors.black26, size: 18),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    '${widget.snap.data()['upvotes'].length}',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(
                                    width: 25,
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: widget.snap
                                            .data()['upvotes']
                                            .contains(firebaseUser?.uid)
                                        ? () async {
                                            await FireStoreMethods()
                                                .removecommentReplyUpvote(
                                                    widget.postId,
                                                    widget.commentId,
                                                    widget.snap.data()[
                                                        'commentReplyId'],
                                                    firebaseUser?.uid,
                                                    widget.snap
                                                        .data()['upvotes']);
                                            await FireStoreMethods()
                                                .addCommentReplyDownvote(
                                                    widget.postId,
                                                    widget.commentId,
                                                    widget.snap.data()[
                                                        'commentReplyId'],
                                                    firebaseUser?.uid,
                                                    widget.snap
                                                        .data()['downvotes']);
                                          }
                                        : () async {
                                            await FireStoreMethods()
                                                .commentReplyDownvote(
                                                    widget.postId,
                                                    widget.commentId,
                                                    widget.snap.data()[
                                                        'commentReplyId'],
                                                    firebaseUser?.uid,
                                                    widget.snap
                                                        .data()['downvotes']);
                                          },
                                    icon: widget.snap
                                            .data()['downvotes']
                                            .contains(firebaseUser?.uid)
                                        ? const Icon(Typicons.down,
                                            color: Colors.blue, size: 18)
                                        : const Icon(Typicons.down_outline,
                                            color: Colors.black26, size: 18),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    '${widget.snap.data()['downvotes'].length}',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
