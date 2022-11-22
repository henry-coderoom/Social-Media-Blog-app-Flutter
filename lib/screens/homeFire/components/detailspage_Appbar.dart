// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:progress_indicators/progress_indicators.dart';

import '../../../components/auth_options_container.dart';
import '../../../components/modal_box.dart';
import '../../../helper/utils.dart';
import '../../../resource/firebase_methods.dart';
import '../bookmarks/bookmark_page.dart';

class DetailsAppBar extends StatefulWidget {
  final postTitle;
  final postId;
  final mediaUrl;

  const DetailsAppBar(
      {Key? key,
      required this.postTitle,
      required this.postId,
      required this.mediaUrl})
      : super(key: key);

  @override
  State<DetailsAppBar> createState() => _DetailsAppBarState();
}

class _DetailsAppBarState extends State<DetailsAppBar> {
  final Color backgroundColor = Colors.red;
  late bool ifSaved;
  bool isBookmarkLoading = true;
  var _loggedUser = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> checkIfDocExists(String postId) async {
    if (_loggedUser != null) {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final firebaseUser = _auth.currentUser;
      try {
        // Get reference to Firestore collection
        var collectionRef = FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser?.uid)
            .collection('bookmarks');
        await collectionRef.doc(postId).get().then((doc) {
          if (doc.exists) {
            setState(() {
              ifSaved = true;
            });
          } else {
            setState(() {
              ifSaved = false;
            });
          }
        });
        setState(() {
          isBookmarkLoading = false;
        });
      } catch (e) {
        throw e.toString();
      }
    } else {
      setState(() {
        ifSaved = false;
        isBookmarkLoading = false;
      });
    }
  }

  void _modalAuthOptionsBookmark(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x88000000),
      context: context,
      builder: (context) {
        return ModalBox(
            refresh: () {},
            modalWidget: AuthOptionsContainer(
              leadingText:
                  'Save posts to bookmarks and easily access them later from your profile.',
              topIcon: Icon(
                Entypo.bookmarks,
                size: 40,
                color: Colors.red.shade900,
              ),
              refresh: () {},
            ));
      },
    );
  }

  @override
  void initState() {
    checkIfDocExists(widget.postId);

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .then((doc) {
          if (doc.exists) {
            checkIfDocExists(widget.postId);
            setState(() {
              _loggedUser = FirebaseAuth.instance.currentUser;
            });
            setState(() {});
          } else {
            Future.delayed(const Duration(milliseconds: 1000)).then((value) {
              checkIfDocExists(widget.postId);
              setState(() {
                _loggedUser = FirebaseAuth.instance.currentUser;
              });
              setState(() {});
            });
          }
        });
      } else {
        setState(() {
          _loggedUser = null;
          ifSaved = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = _auth.currentUser;

    return AppBar(
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 25.0),
          child: isBookmarkLoading == true
              ? SizedBox(
                  height: 30,
                  width: 30,
                  child: JumpingDotsProgressIndicator(
                    color: Colors.grey,
                    fontSize: 30,
                  ),
                )
              : IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    if (_loggedUser != null) {
                      setState(() {
                        isBookmarkLoading = true;
                      });
                      await checkIfDocExists(widget.postId);
                      if (ifSaved == false) {
                        final uid = firebaseUser?.uid;
                        await FireStoreMethods().savePost(
                          uid!,
                          widget.postId,
                          widget.postTitle,
                          widget.mediaUrl,
                        );
                        setState(() {
                          ifSaved = true;
                          isBookmarkLoading = false;
                        });

                        showSnackBar(context, 'Post Saved!', 3, () {
                          Navigator.pushNamed(context, BookmarkPage.routeName);
                        }, ' See Bookmarks');
                      } else {
                        final uid = firebaseUser?.uid;
                        await FireStoreMethods()
                            .unsavePost(uid!, widget.postId);
                        setState(() {
                          ifSaved = false;
                          isBookmarkLoading = false;
                        });
                        showSnackBar(context, 'Post Unsaved!', 3, () {
                          Navigator.pushNamed(context, BookmarkPage.routeName);
                        }, 'See Bookmarks');
                      }
                    } else {
                      _modalAuthOptionsBookmark(context);
                    }
                  },
                  icon: ifSaved == false
                      ? const Icon(
                          Elusive.bookmark_empty,
                          size: 23,
                          color: Color(0xFF6D6D6D),
                        )
                      : const Icon(
                          Elusive.bookmark,
                          size: 23,
                          color: Color(0xFFFFB510),
                        ),
                ),
        ),
      ],
      backgroundColor: const Color(0xFFF5F6F9),
    );
  }
}
