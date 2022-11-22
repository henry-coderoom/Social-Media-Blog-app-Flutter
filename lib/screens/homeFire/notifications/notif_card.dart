// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:bbarena_app_com/screens/commentReply/comments_reply_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bbarena_app_com/screens/details/details_screen.dart';

class NotifCard extends StatefulWidget {
  final snap;
  const NotifCard({Key? key, required this.snap, this.postsDocId = ''})
      : super(key: key);
  final String postsDocId;

  @override
  State<NotifCard> createState() => _NotifCardState();
}

class _NotifCardState extends State<NotifCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final width = MediaQuery.of(context).size.width;

    updateClicked(String notifId) async {
      var firebaseUser = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .collection('notifs')
          .doc(notifId)
          .update({
            'clicked': true,
          })
          .then((value) {})
          .catchError((e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
              ),
            );
          });
    }

    DateTime dateSent = (widget.snap['dateSent']).toDate();

    // final firebaseUser = _auth.currentUser;
    //
    // String postTitle = widget.snap['title'];
    // String mediaUrl = widget.snap['mediaUrl'];

    // Future<bool> _confirmUnsavePost() {
    //   throw showDialog(
    //       context: context,
    //       builder: (context) => AlertDialog(
    //             shape: const RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.all(Radius.circular(20.0))),
    //             content: const Text(
    //                 'Remove this post from your Saved Post collection?'),
    //             actions: <Widget>[
    //               ElevatedButton(
    //                 style: ElevatedButton.styleFrom(
    //                     primary: Colors.transparent, elevation: 0),
    //                 child: const Text(
    //                   'Yah sure',
    //                   style: TextStyle(
    //                       color: Colors.blue,
    //                       fontWeight: FontWeight.bold,
    //                       fontSize: 15),
    //                 ),
    //                 onPressed: () async {
    //                   Navigator.pop(context, false);
    //                   await FireStoreMethods()
    //                       .unsavePost(firebaseUser?.uid, widget.snap['postId']);
    //                   setState(() {});
    //                 },
    //                 //exit the app
    //               ),
    //               ElevatedButton(
    //                 style: ElevatedButton.styleFrom(
    //                     primary: Colors.transparent, elevation: 0),
    //                 child: const Text('Cancel',
    //                     style: TextStyle(
    //                         color: Colors.blue,
    //                         fontWeight: FontWeight.bold,
    //                         fontSize: 15)),
    //                 onPressed: () => Navigator.pop(context, false),
    //               )
    //             ],
    //           ));
    // }

    return Column(
      children: [
        Container(
          color: widget.snap['clicked'] == true
              ? const Color(0x0f000000)
              : Colors.white,
          child: InkWell(
            onTap: (widget.snap['notifType'].contains('commentMention'))
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(
                          postId: (widget.snap['post']),
                          updateComLen: () {},
                        ),
                      ),
                    );
                    updateClicked(widget.snap['notifId']);
                  }
                : (widget.snap['notifType'].contains('reply'))
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CommentsReplyScreen(
                              updateRepLen: () {},
                              commentOwner: widget.snap['commentOwner'],
                              commentTex: widget.snap['commentText'],
                              postDocsId: widget.snap['post'],
                              commentId: widget.snap['commentId'],
                            ),
                          ),
                        );
                        updateClicked(widget.snap['notifId']);
                      }
                    : (widget.snap['notifType'].contains('tag'))
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CommentsReplyScreen(
                                  updateRepLen: () {},
                                  commentOwner: widget.snap['commentOwner'],
                                  commentTex: widget.snap['commentText'],
                                  postDocsId: widget.snap['post'],
                                  commentId: widget.snap['commentId'],
                                ),
                              ),
                            );
                            updateClicked(widget.snap['notifId']);
                          }
                        : () {},
            child: ListTile(
              leading: SizedBox(
                  child: (widget.snap['notifType'].contains('commentMention'))
                      ? const Icon(Octicons.mention)
                      : (widget.snap['notifType'].contains('reply'))
                          ? const Icon(Octicons.comment_discussion)
                          : (widget.snap['notifType'].contains('tag'))
                              ? const Icon(Entypo.reply_all)
                              : const SizedBox.shrink()),
              title: Wrap(
                children: [
                  Text(
                    widget.snap['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                      child: (widget.snap['notifType']
                              .contains('commentMention'))
                          ? const Text(' mentioned you on a post: ')
                          : (widget.snap['notifType'].contains('reply'))
                              ? const Text(' replied your comment on ')
                              : (widget.snap['notifType'].contains('tag'))
                                  ? const Text(
                                      ' tagged you in a reply under a comment on: ')
                                  : const SizedBox.shrink()),
                  Text(
                    widget.snap['postTitle'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Entypo.clock,
                      size: 15,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      timeago.format(dateSent, locale: 'en'),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              trailing: SizedBox(
                child: widget.snap['clicked'] == true
                    ? const Icon(FontAwesome5.check_double,
                        color: Colors.grey, size: 12)
                    : const Icon(
                        Icons.circle,
                        color: Colors.green,
                        size: 12,
                      ),
              ),
            ),
          ),
        ),
        const Divider(
          thickness: 1,
          color: Colors.black12,
        ),
      ],
    );
  }
}
