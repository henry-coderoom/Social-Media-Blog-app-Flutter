// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:bbarena_app_com/deleted_user_screen.dart';
import 'package:bbarena_app_com/resource/firebase_methods.dart';
import 'package:bbarena_app_com/screens/commentReply/comments_reply_screen.dart';
import 'package:bbarena_app_com/screens/homeFire/profileFire/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../helper/utils.dart';
import '../user_screen.dart';

class CommentCard extends StatefulWidget {
  final snap;
  final snap1;
  final postId;
  final Function() updateComCount;
  final Function() updateMain;
  const CommentCard(
      {Key? key,
      this.snap,
      required this.updateComCount,
      required this.updateMain,
      this.snap1,
      this.postId})
      : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  int replyLen = 0;
  bool isAvail = false;
  @override
  void initState() {
    super.initState();
    fetchReplyLen();
  }

  fetchReplyLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(widget.snap['commentId'])
          .collection('commentreply')
          .get();
      replyLen = snap.docs.length;
    } catch (err) {
      showSnackBar(context, err.toString(), 2, () {}, '');
    }
    setState(() {});
  }

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
            showSnackBar(context, e.toString(), 3, () {}, '');
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

    DateTime datePosted = (widget.snap['datePublished']).toDate();

    final FirebaseAuth _auth = FirebaseAuth.instance;

    //
    // final args =
    //     ModalRoute.of(context)!.settings.arguments as PostDetailsArguments1;

    final firebaseUser = _auth.currentUser;

    Future<bool> _confirmDeleteComment() {
      throw showDialog(
          context: context,
          builder: (context) => AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                content:
                    const Text('Do you really want to delete this comment?'),
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
                      FireStoreMethods().deleteComment(
                          widget.snap['commentId'],
                          widget.postId,
                          firebaseUser?.uid,
                          widget.snap['commentImage']);
                      widget.updateComCount();
                      widget.updateMain();
                      Navigator.pop(context, false);
                    },
                  )
                ],
              ));
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8, top: 3, bottom: 3),
      child: Container(
        padding: const EdgeInsets.only(top: 16, bottom: 0, right: 16, left: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
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
                  ? () =>
                      Navigator.pushNamed(context, ProfileScreenFire.routeName)
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
                    radius: 18,
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
                                            builder: (context) => UserScreen(
                                              userId: widget.snap.data()['uid'],
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
                      padding:
                          widget.snap['text'].contains('/344*7^*!!@!%??/-=12@')
                              ? const EdgeInsets.only(left: 0.0, top: 0)
                              : const EdgeInsets.only(left: 4.0, top: 5),
                      child: widget.snap['text']
                              .contains('/344*7^*!!@!%??/-=12@')
                          ? const SizedBox.shrink()
                          : GestureDetector(
                              onLongPress: () async {
                                await Clipboard.setData(
                                    ClipboardData(text: widget.snap['text']));
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
                                  duration: const Duration(milliseconds: 2000),
                                ));
                              },
                              child: Text.rich(
                                TextSpan(children: textSpans),
                              ),
                            ),
                    ),
                    SizedBox(
                      child: widget.snap['commentImage'].contains('!@!@')
                          ? const SizedBox.shrink()
                          : GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CommentsReplyScreen(
                                    postDocsId: widget.postId.toString(),
                                    commentId: widget.snap
                                        .data()['commentId']
                                        .toString(),
                                    commentTex: widget.snap.data()['text'],
                                    updateRepLen: () {
                                      fetchReplyLen();
                                    },
                                    commentOwner: widget.snap.data()['uid'],
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: widget.snap['text']
                                        .contains('/344*7^*!!@!%??/-=12@')
                                    ? const EdgeInsets.only(top: 12.0)
                                    : const EdgeInsets.only(top: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.network(
                                    widget.snap['commentImage'],
                                    height: 240,
                                    width: 240,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 5),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CommentsReplyScreen(
                                          postDocsId: widget.postId.toString(),
                                          commentId: widget.snap
                                              .data()['commentId']
                                              .toString(),
                                          date: timeago.format(datePosted,
                                              locale: 'en_short'),
                                          commentTex:
                                              widget.snap.data()['text'],
                                          updateRepLen: () {
                                            fetchReplyLen();
                                          },
                                          commentOwner:
                                              widget.snap.data()['uid'],
                                        ),
                                      ),
                                    )
                                    .then((value) {}),
                                child: const Text(
                                  'Reply',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                child: replyLen >= 1
                                    ? const Text('  •  ')
                                    : const Text(''),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                    padding: const EdgeInsets.only(
                                        left: 0, right: 0),
                                    minimumSize: Size.zero),
                                child: replyLen >= 1
                                    ? Text(
                                        'Replies (${replyLen.toString()})',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    : const Text(''),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CommentsReplyScreen(
                                      postDocsId: widget.postId.toString(),
                                      commentId: widget.snap
                                          .data()['commentId']
                                          .toString(),
                                      commentTex: widget.snap.data()['text'],
                                      updateRepLen: () {
                                        fetchReplyLen();
                                      },
                                      commentOwner: widget.snap.data()['uid'],
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: widget.snap['uid']
                                        .contains(firebaseUser?.uid)
                                    ? _confirmDeleteComment
                                    : null,
                                icon: widget.snap['uid']
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
                          padding: const EdgeInsets.only(right: 1),
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
                                            .removecommentDownvote(
                                                widget.postId,
                                                widget.snap.data()['commentId'],
                                                firebaseUser?.uid,
                                                widget.snap
                                                    .data()['downvotes']);
                                        await FireStoreMethods()
                                            .addCommentUpvote(
                                                widget.postId,
                                                widget.snap.data()['commentId'],
                                                firebaseUser?.uid,
                                                widget.snap.data()['upvotes']);
                                      }
                                    : () async {
                                        await FireStoreMethods().commentUpvote(
                                            widget.postId,
                                            widget.snap.data()['commentId'],
                                            firebaseUser?.uid,
                                            widget.snap.data()['upvotes']);
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
                                width: 3,
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
                                            .removecommentUpvote(
                                                widget.postId,
                                                widget.snap.data()['commentId'],
                                                firebaseUser?.uid,
                                                widget.snap.data()['upvotes']);
                                        await FireStoreMethods()
                                            .addCommentDownvote(
                                                widget.postId,
                                                widget.snap.data()['commentId'],
                                                firebaseUser?.uid,
                                                widget.snap
                                                    .data()['downvotes']);
                                      }
                                    : () async {
                                        await FireStoreMethods()
                                            .commentDownvote(
                                                widget.postId,
                                                widget.snap.data()['commentId'],
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
                                width: 3,
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
    );
  }
}
