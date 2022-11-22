// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:io';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bbarena_app_com/resource/firebase_methods.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:uuid/uuid.dart';
import '../../deleted_user_screen.dart';
import '../../helper/keyboard.dart';
import '../../helper/utils.dart';
import '../homeFire/profileFire/profile_screen.dart';
import '../user_screen.dart';
import 'comment_reply_card.dart';

bool connectionStatus = true;
Future check() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      connectionStatus = true;
    }
  } on SocketException catch (_) {
    connectionStatus = false;
  }
}

class CommentsReplyScreen extends StatefulWidget {
  static String routeName = "/commentreply";
  final commentId;
  final postDocsId;
  final commentTex;
  final commentOwner;
  final snap;
  final replyLen;
  final date;
  final Function() updateRepLen;
  const CommentsReplyScreen(
      {Key? key,
      required this.commentId,
      required this.updateRepLen,
      required this.commentOwner,
      required this.commentTex,
      this.snap,
      this.replyLen,
      this.date,
      required this.postDocsId})
      : super(key: key);

  @override
  _CommentsReplyScreenState createState() => _CommentsReplyScreenState();
}

class _CommentsReplyScreenState extends State<CommentsReplyScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int replyLen = 0;

  late String commentName;
  late String ownerUid;
  late String ownerUrl;
  late String commentText;
  late DateTime datePosted;
  late String commentImage;
  var upvotes;
  var downvotes;
  var stream;
  var fetch;
  var fetchMainComment;
  bool replyLenLoading = true;
  bool isTyping = false;
  bool posting = false;
  RegExp reg = RegExp(r"\@(\w+)");

  late FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    fetchComment();
    fetchMainComment = fetchComment();
    stream = newReplyFetch();
    fetchReplyLen();
    check();
    fetch = fetchUser();
    myFocusNode = FocusNode();
  }

  Stream<QuerySnapshot> newReplyFetch() {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postDocsId)
        .collection('comments')
        .doc(widget.commentId)
        .collection('commentreply')
        .orderBy('datePublished', descending: false)
        .snapshots();
  }

  late String username;
  late String uid;
  late String url;

  fetchUser() async {
    final firebaseUser = _auth.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser?.uid)
        .get()
        .then((ds) {
      username = ds['username'];
      url = ds['url'];
      uid = ds['uid'];
    }).catchError((e) {
      showSnackBar(context, e.toString(), 2, () {}, '');
    });
  }

  final TextEditingController txt = TextEditingController();

  fetchReplyLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postDocsId)
          .collection('comments')
          .doc(widget.commentId)
          .collection('commentreply')
          .get();
      replyLen = snap.docs.length;
      setState(() {
        replyLenLoading = false;
      });
    } catch (err) {}
    setState(() {});
  }

  fetchComment() async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postDocsId)
        .collection('comments')
        .doc(widget.commentId)
        .get()
        .then((ds) {
      commentName = ds['name'];
      ownerUrl = ds['profilePic'];
      upvotes = ds['upvotes'];
      downvotes = ds['downvotes'];
      ownerUid = ds['uid'];
      commentText = ds['text'];
      datePosted = ds['datePublished'].toDate();
      commentImage = ds['commentImage'];
    }).catchError((e) {
      showSnackBar(context, e.toString(), 3, () {}, '');
    });
  }

  Uint8List? _file;

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text('Reply with image or GIF',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.only(left: 30, top: 10, bottom: 15),
                child: const Text('🔄 Choose from Gallery',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                    isTyping = true;
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.only(
                right: 20,
                bottom: 10,
              ),
              child: const Text(
                "Cancel",
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  bool isLoading = false;
  bool isAvail = false;

  @override
  Widget build(BuildContext context) {
    replyUserReply(tagged) {
      final newText = '@$tagged ';
      final updatedText = txt.text + newText;
      txt.value = txt.value.copyWith(
        text: updatedText,
        selection: TextSelection.collapsed(offset: updatedText.length),
      );
      myFocusNode.requestFocus();
    }

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
    final String text = widget.commentTex;
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

    Future<void> postCommentReplyWithImage(
      String uid,
      String name,
      String profilePic,
    ) async {
      setState(() {
        isLoading = true;
      });
      try {
        late String postTitle;
        late String postId;
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postDocsId)
            .get()
            .then((ds) {
          postId = ds['postId'];
          postTitle = ds['title'];
        }).catchError((e) {
          showSnackBar(context, e.toString(), 2, () {}, '');
        });
        final String imageId = const Uuid().v1();
        final Reference storageReference = FirebaseStorage.instance
            .ref()
            .child("commentReplyImages/$name - $imageId");
        UploadTask uploadTask = storageReference.putData(_file!);
        String downloadUrl = await (await uploadTask).ref.getDownloadURL();
        final String commentImage = downloadUrl;
        String commentText =
            txt.text.isEmpty ? '/344*7^*!!@!%??/-=12@' : txt.text;
        String res = await FireStoreMethods().postCommentReply(
            widget.postDocsId,
            commentText,
            uid,
            widget.commentOwner,
            name,
            profilePic,
            widget.commentId,
            commentImage,
            postTitle,
            widget.commentTex);
        if (res == "success") {
          setState(() {
            isLoading = false;
          });
          showSnackBar(context, 'Reply posted!', 2, () {}, '');
          clearImage();
          widget.updateRepLen();
          fetchReplyLen();
        } else {
          showSnackBar(context, res, 5, () {}, '');
        }
      } catch (err) {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, err.toString(), 5, () {}, '');
      }
    }

    Future<void> postCommentReply(
        String uid, String name, String profilePic) async {
      try {
        late String postTitle;
        late String postId;
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postDocsId)
            .get()
            .then((ds) {
          postId = ds['postId'];
          postTitle = ds['title'];
        }).catchError((e) {
          showSnackBar(context, e.toString(), 2, () {}, '');
        });
        String commentImage = '!@!@';
        String res = await FireStoreMethods().postCommentReply(
            widget.postDocsId,
            txt.text,
            uid,
            widget.commentOwner,
            name,
            profilePic,
            widget.commentId,
            commentImage,
            postTitle,
            widget.commentTex);

        if (res == 'success') {
          showSnackBar(context, 'Posted!', 1, () {}, '');
        }
      } catch (err) {
        showSnackBar(context, err.toString(), 5, () {}, '');
      }
    }

    Future<void> notifyTagged(
        String taggedName, String name, String uid) async {
      try {
        await FirebaseFirestore.instance
            .collection('usernames')
            .doc(taggedName)
            .get()
            .then((doc) async {
          if (doc.exists) {
            late String taggedUserId;
            await FirebaseFirestore.instance
                .collection('usernames')
                .doc(taggedName)
                .get()
                .then((ds) {
              taggedUserId = ds['uid'];
            }).catchError((e) {
              showSnackBar(context, e.toString(), 2, () {}, '');
            });

            late String postTitle;
            await FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.postDocsId)
                .get()
                .then((ds) {
              postTitle = ds['title'];
            }).catchError((e) {
              showSnackBar(context, e.toString(), 2, () {}, '');
            });

            await FireStoreMethods().postReplyTagNotif(
                widget.postDocsId,
                uid,
                txt.text,
                taggedUserId,
                name,
                widget.commentId,
                postTitle,
                widget.commentOwner,
                widget.commentTex);
          } else {
            showSnackBar(context, "user tagged does not exist", 1, () {}, '');
          }
        });
      } catch (err) {
        showSnackBar(context, err.toString(), 2, () {}, '');
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: replyLenLoading == true
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                  ),
                )
              : Center(
                  child: replyLen == 0
                      ? const Text(
                          'Be the first to reply',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        )
                      : Text(
                          'Replies to this comment - $replyLen',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: stream,
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final FirebaseAuth _auth = FirebaseAuth.instance;
          final firebaseUser = _auth.currentUser;

          Future<bool> _confirmDeleteComment() {
            throw showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      content:
                          const Text('Do you want to delete this comment?'),
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
                                widget.commentId,
                                widget.postDocsId,
                                firebaseUser?.uid,
                                commentImage);
                            Navigator.pop(context, false);
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ));
          }

          return RefreshIndicator(
            strokeWidth: 1,
            color: Colors.black38,
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
              setState(() {
                fetchMainComment = fetchComment();
                stream = newReplyFetch();
              });
              fetchReplyLen();
              check();
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Center(
                    child: connectionStatus == false
                        ? Container(
                            height: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 7,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.signal_cellular_off_outlined,
                                      size: 25,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'ERR: Check your internet connection \n and try again.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      await check();
                                      setState(() {});
                                    },
                                    child: const Text('Retry'))
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  FutureBuilder(
                    future: fetchMainComment,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            backgroundColor: Color(0xFFE8E8E8),
                            strokeWidth: 1,
                            color: Colors.black38,
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 0, right: 0, top: 5, bottom: 5),
                        child: Container(
                          padding: const EdgeInsets.only(
                              top: 16, bottom: 1, right: 16, left: 16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: ownerUid == firebaseUser?.uid
                                    ? () => Navigator.pushNamed(
                                        context, ProfileScreenFire.routeName)
                                    : () async {
                                        setState(() {
                                          isAvail = true;
                                        });
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(ownerUid)
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
                                                  userId: ownerUid,
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
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        ownerUrl,
                                      ),
                                      radius: 25,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 4.0),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: ownerUid ==
                                                      firebaseUser?.uid
                                                  ? () => Navigator.pushNamed(
                                                      context,
                                                      ProfileScreenFire
                                                          .routeName)
                                                  : () async {
                                                      setState(() {
                                                        isAvail = true;
                                                      });
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('users')
                                                          .doc(ownerUid)
                                                          .get()
                                                          .then((doc) async {
                                                        if (doc.exists) {
                                                          setState(() {
                                                            isAvail = false;
                                                          });
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      UserScreen(
                                                                userId:
                                                                    ownerUid,
                                                              ),
                                                            ),
                                                          );
                                                        } else {
                                                          setState(() {
                                                            isAvail = false;
                                                          });
                                                          Navigator.pushNamed(
                                                              context,
                                                              DeletedUserScreen
                                                                  .routeName);
                                                        }
                                                      });
                                                    },
                                              child: Text(
                                                commentName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17,
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
                                        padding: commentText.contains(
                                                '/344*7^*!!@!%??/-=12@')
                                            ? const EdgeInsets.only(
                                                left: 0.0, top: 0)
                                            : const EdgeInsets.only(
                                                left: 4.0, top: 5),
                                        child: commentText.contains(
                                                '/344*7^*!!@!%??/-=12@')
                                            ? const SizedBox.shrink()
                                            : GestureDetector(
                                                onLongPress: () async {
                                                  await Clipboard.setData(
                                                      ClipboardData(
                                                          text: commentText));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    backgroundColor:
                                                        Colors.blue,
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
                                                    duration: const Duration(
                                                        milliseconds: 2000),
                                                  ));
                                                },
                                                child: Text.rich(
                                                  TextSpan(children: textSpans),
                                                ),
                                              ),
                                      ),
                                      SizedBox(
                                        child: commentImage.contains('!@!@')
                                            ? const SizedBox.shrink()
                                            : Padding(
                                                padding: commentText.contains(
                                                        '/344*7^*!!@!%??/-=12@')
                                                    ? const EdgeInsets.only(
                                                        left: 4, top: 15.0)
                                                    : const EdgeInsets.only(
                                                        left: 4, top: 10),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  child: Image.network(
                                                    commentImage,
                                                    height: 250,
                                                    width: 250,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              TextButton(
                                                  style: TextButton.styleFrom(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 0,
                                                              right: 0),
                                                      minimumSize: Size.zero),
                                                  child: const Text(
                                                    'Reply',
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    replyUserReply(commentName);
                                                  }),
                                              IconButton(
                                                onPressed: ownerUid ==
                                                        firebaseUser?.uid
                                                    ? _confirmDeleteComment
                                                    : null,
                                                icon: ownerUid ==
                                                        firebaseUser?.uid
                                                    ? const Icon(
                                                        FontAwesome5.trash_alt,
                                                        color:
                                                            Color(0xFFD0D0D0),
                                                        size: 14,
                                                      )
                                                    : const Icon(
                                                        Icons.circle,
                                                        size: 0,
                                                      ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.only(
                                                right: 40),
                                            child: Row(
                                              children: [
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  onPressed: downvotes.contains(
                                                          firebaseUser?.uid)
                                                      ? () async {
                                                          await FireStoreMethods()
                                                              .removecommentDownvote(
                                                                  widget
                                                                      .postDocsId,
                                                                  widget
                                                                      .commentId,
                                                                  firebaseUser
                                                                      ?.uid,
                                                                  downvotes);
                                                          setState(() {
                                                            fetchMainComment =
                                                                fetchComment();
                                                          });
                                                          await FireStoreMethods()
                                                              .addCommentUpvote(
                                                                  widget
                                                                      .postDocsId,
                                                                  widget
                                                                      .commentId,
                                                                  firebaseUser
                                                                      ?.uid,
                                                                  upvotes);
                                                          setState(() {
                                                            fetchMainComment =
                                                                fetchComment();
                                                          });
                                                        }
                                                      : () async {
                                                          await FireStoreMethods()
                                                              .commentUpvote(
                                                                  widget
                                                                      .postDocsId,
                                                                  widget
                                                                      .commentId,
                                                                  firebaseUser
                                                                      ?.uid,
                                                                  upvotes);
                                                          setState(() {
                                                            fetchMainComment =
                                                                fetchComment();
                                                          });
                                                        },
                                                  icon: upvotes.contains(
                                                          firebaseUser?.uid)
                                                      ? const Icon(Typicons.up,
                                                          color: Colors.blue,
                                                          size: 20)
                                                      : const Icon(
                                                          Typicons.up_outline,
                                                          color: Colors.black26,
                                                          size: 20),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  '${upvotes.length}',
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                                const SizedBox(
                                                  width: 25,
                                                ),
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  onPressed: upvotes.contains(
                                                          firebaseUser?.uid)
                                                      ? () async {
                                                          await FireStoreMethods()
                                                              .removecommentUpvote(
                                                                  widget
                                                                      .postDocsId,
                                                                  widget
                                                                      .commentId,
                                                                  firebaseUser
                                                                      ?.uid,
                                                                  upvotes);
                                                          setState(() {
                                                            fetchMainComment =
                                                                fetchComment();
                                                          });
                                                          await FireStoreMethods()
                                                              .addCommentDownvote(
                                                                  widget
                                                                      .postDocsId,
                                                                  widget
                                                                      .commentId,
                                                                  firebaseUser
                                                                      ?.uid,
                                                                  downvotes);
                                                          setState(() {
                                                            fetchMainComment =
                                                                fetchComment();
                                                          });
                                                        }
                                                      : () async {
                                                          await FireStoreMethods()
                                                              .commentDownvote(
                                                                  widget
                                                                      .postDocsId,
                                                                  widget
                                                                      .commentId,
                                                                  firebaseUser
                                                                      ?.uid,
                                                                  downvotes);
                                                          setState(() {
                                                            fetchMainComment =
                                                                fetchComment();
                                                          });
                                                        },
                                                  icon: downvotes.contains(
                                                          firebaseUser?.uid)
                                                      ? const Icon(
                                                          Typicons.down,
                                                          color: Colors.blue,
                                                          size: 20)
                                                      : const Icon(
                                                          Typicons.down_outline,
                                                          color: Colors.black26,
                                                          size: 20),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  '${downvotes.length}',
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w700),
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
                    },
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (ctx, index) => CommentReplyCard(
                      snap: snapshot.data!.docs[index],
                      commentId: widget.commentId,
                      postId: widget.postDocsId,
                      fetchReplyLen: () {
                        fetchReplyLen();
                      },
                      updateRepLenComScreen: () {
                        widget.updateRepLen();
                      },
                      replyUser: () {
                        replyUserReply(
                            snapshot.data?.docs[index].data()['name']);
                      },
                      ownerId: widget.commentOwner,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: FutureBuilder(
          future: fetch,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return JumpingDotsProgressIndicator(
                fontSize: 30,
              );
            }
            return Container(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
                maxWidth: MediaQuery.of(context).size.width,
                minHeight: 25.0, //min height you want to take by container
                maxHeight: 120.0, //max height you want to take by container
              ),
              color: Colors.white,
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              padding:
                  const EdgeInsets.only(left: 8, right: 8, bottom: 5, top: 5),
              child: TextField(
                onChanged: (String value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      isTyping = true;
                    });
                  } else {
                    if (_file == null) {
                      setState(() {
                        isTyping = false;
                      });
                    } else {
                      setState(() {
                        isTyping = true;
                      });
                    }
                  }
                },
                focusNode: myFocusNode,
                maxLines: null,
                style: const TextStyle(
                  fontSize: 15,
                ),
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                controller: txt,
                decoration: InputDecoration(
                  prefixIcon: posting == true
                      ? Container(
                          height: 18,
                          width: 18,
                          padding: const EdgeInsets.all(15),
                          child: const CircularProgressIndicator(
                            strokeWidth: 1.5,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(url),
                            radius: 15,
                          ),
                        ),
                  suffixIcon: _file == null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () async {
                                await _selectImage(context);
                              },
                              icon: const Icon(
                                Elusive.picture,
                                color: Color(0xFFCBCBCB),
                              ),
                            ),
                            InkWell(
                              onTap: isTyping == false
                                  ? () {}
                                  : () async {
                                      setState(() {
                                        posting = true;
                                      });
                                      KeyboardUtil.hideKeyboard(context);
                                      await postCommentReply(
                                        uid,
                                        username,
                                        url,
                                      );
                                      for (var m in reg.allMatches(txt.text)) {
                                        if (m[1] != commentName) {
                                          await notifyTagged(
                                              m[1]!, username, uid);
                                        }
                                      }

                                      fetchReplyLen();
                                      setState(() {
                                        fetchMainComment = fetchComment();
                                        isTyping = false;
                                      });
                                      widget.updateRepLen();

                                      setState(() {
                                        txt.text = "";
                                        posting = false;
                                      });
                                    },
                              child: Container(
                                padding: const EdgeInsets.only(
                                    top: 15, bottom: 15, right: 15),
                                child: Text(
                                  'Post',
                                  style: TextStyle(
                                      color: isTyping == false
                                          ? Colors.black54
                                          : Colors.blue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8.0,
                                    bottom: 8.0,
                                    right: 5,
                                  ),
                                  child: SizedBox(
                                    height: 80.0,
                                    width: 80.0,
                                    child: AspectRatio(
                                      aspectRatio: 487 / 451,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                          fit: BoxFit.fill,
                                          alignment: FractionalOffset.topCenter,
                                          image: MemoryImage(_file!),
                                        )),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 7,
                                  bottom: 78,
                                  child: SizedBox(
                                    height: 27,
                                    width: 27,
                                    child: IconButton(
                                      onPressed: () {
                                        clearImage();
                                        if (txt.text.isEmpty) {
                                          setState(() {
                                            isTyping = false;
                                          });
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                        size: 27,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: isTyping == false
                                  ? () {}
                                  : () async {
                                      KeyboardUtil.hideKeyboard(context);

                                      await postCommentReplyWithImage(
                                        uid,
                                        username,
                                        url,
                                      );
                                      for (var m in reg.allMatches(txt.text)) {
                                        if (m[1] != commentName) {
                                          await notifyTagged(
                                              m[1]!, username, uid);
                                        }
                                      }
                                      fetchReplyLen();
                                      setState(() {
                                        fetchMainComment = fetchComment();
                                        isTyping = false;
                                      });
                                      widget.updateRepLen();

                                      setState(() {
                                        txt.text = "";
                                      });
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 8),
                                child: isLoading != true
                                    ? Text(
                                        'Post',
                                        style: TextStyle(
                                            color: isTyping == false
                                                ? Colors.black54
                                                : Colors.blue,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : const SizedBox(
                                        height: 25,
                                        width: 25,
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                          strokeWidth: 2,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                  filled: true,
                  fillColor: const Color(0x27AFAFAF),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFffffff), width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFffffff), width: 1.0),
                  ),
                  hintText: 'Reply as $username...',
                  hintStyle: const TextStyle(color: Color(0xFFAFAFAF)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
