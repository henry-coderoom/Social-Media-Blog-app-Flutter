// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:typed_data';

import 'package:bbarena_app_com/screens/comments/comments_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:uuid/uuid.dart';
import '../../components/auth_options_container.dart';
import '../../components/modal_box.dart';
import '../../helper/keyboard.dart';
import '../../helper/utils.dart';
import '../../resource/firebase_methods.dart';
import '../homeFire/components/detailspage_Appbar.dart';
import 'components/body.dart';

class DetailsScreen extends StatefulWidget {
  static String routeName = "/details";
  final postTitle;
  final mediaUrl;
  final postId;
  final Function() updateComLen;
  const DetailsScreen(
      {Key? key,
      this.postId,
      required this.updateComLen,
      this.postTitle,
      this.mediaUrl})
      : super(key: key);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>
    with AutomaticKeepAliveClientMixin<DetailsScreen> {
  @override
  bool get wantKeepAlive => true;

  bool isTyping = false;
  RegExp reg = RegExp(r"\@(\w+)");
  var _loggedUser = FirebaseAuth.instance.currentUser;

  var fetch;
  var fetchPosts;

  late String uid;
  late String url;
  late String username;

  void _commentAuthModalBox(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x88000000),
      context: context,
      builder: (context) {
        return ModalBox(
            refresh: () {},
            modalWidget: AuthOptionsContainer(
              leadingText:
                  'Post comments on posts and reply to other people\'s comments, log in or sign up.',
              topIcon: Icon(
                FontAwesome5.comments,
                size: 40,
                color: Colors.purple.shade400,
              ),
              refresh: () {},
            ));
      },
    );
  }

  fetchUser() async {
    if (_loggedUser != null) {
      final userId = _loggedUser?.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((ds) {
        username = ds['username'];
        url = ds['url'];
        uid = ds['uid'];
      }).catchError((e) {
        showSnackBar(context, e.toString(), 3, () {}, '');
      });
    } else {
      _loggedUser = null;
    }
  }

  late String postId;
  late String postTitle;
  late String mediaUrl;

  fetchPost() async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .get()
        .then((ds) {
      postId = ds['postId'];
      postTitle = ds['title'];
      mediaUrl = ds['mediaUrl'];
    }).catchError((e) {
      final snackBar = SnackBar(content: Text(e.toString()));
      Scaffold.of(context).showSnackBar(snackBar);
    });
  }

  @override
  void initState() {
    fetchUser();
    fetch = fetchUser();
    fetchPosts = fetchPost();
    stream = newStream();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        setState(() {
          _loggedUser = FirebaseAuth.instance.currentUser;
        });
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .then((doc) {
          if (doc.exists) {
            fetchUser();
            fetch = fetchUser();
            setState(() {});
          } else {
            Future.delayed(const Duration(milliseconds: 1000)).then((value) {
              fetchUser();
              fetch = fetchUser();
              setState(() {});
            });
          }
        });
      } else {
        setState(() {
          _loggedUser = null;
        });
      }
    });
    super.initState();
  }

  var stream;
  Stream<DocumentSnapshot> newStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .snapshots();
  }

  Uint8List? _file;

  final TextEditingController txt = TextEditingController();

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text('Comment with image or GIF',
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

  Future<String> uploadCommentImage(String name) async {
    final String imageId = const Uuid().v1();
    final Reference storageReference =
        FirebaseStorage.instance.ref().child("commentImages/$name - $imageId");
    UploadTask uploadTask = storageReference.putData(_file!);

    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    Future<void> postComment(String uid, String name, String profilePic) async {
      setState(() {
        isLoading = true;
      });
      try {
        late String postTitle;
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .get()
            .then((ds) {
          postId = ds['postId'];
          postTitle = ds['title'];
        }).catchError((e) {
          showSnackBar(context, e.toString(), 2, () {}, '');
        });
        String commentImage =
            (_file != null) ? await uploadCommentImage(name) : '!@!@';
        String res = await FireStoreMethods().postComment(
          widget.postId,
          txt.text,
          uid,
          name,
          profilePic,
          commentImage,
          postTitle,
        );

        if (res == 'success') {
          setState(() {
            isLoading = false;
          });
          clearImage();
          showSnackBar(context, 'Posted!', 1, () {}, '');
        } else {
          showSnackBar(context, res, 5, () {}, '');
          setState(() {
            isLoading = true;
          });
        }
      } catch (err) {
        setState(() {
          isLoading = false;
        });
        clearImage();
        showSnackBar(context, err.toString(), 5, () {}, '');
      }
    }

    Future<void> notifyMentioned(
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

            await FireStoreMethods().postCommentMentionNotif(widget.postId, uid,
                txt.text, taggedUserId, name, widget.postTitle);
          } else {
            showSnackBar(context, "User tagged does not exist", 1, () {}, '');
          }
        });
      } catch (err) {
        showSnackBar(context, err.toString(), 2, () {}, '');
      }
    }

    super.build(context);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: FutureBuilder(
            future: fetchPosts,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center();
              }
              return DetailsAppBar(
                postTitle: widget.postTitle,
                postId: widget.postId,
                mediaUrl: mediaUrl,
              );
            }),
      ),
      backgroundColor: const Color(0xFFF5F6F9),
      body: RefreshIndicator(
        strokeWidth: 1,
        color: Colors.black38,
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          setState(() {
            stream = newStream();
            fetchPosts = fetchPost();
          });
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder(
                  stream: stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 1,
                      itemBuilder: (context, index) => PostDetailsCard(
                        snap: snapshot.data!,
                        refresh: () {
                          // setState(() {});
                        },
                      ),
                    );
                  }),
              const SizedBox(
                height: 5,
              ),
              CommentsScreen(
                postId: widget.postId,
                // key: globalKey,
                update: () {
                  setState(() {
                    stream = newStream();
                  });
                },
                updateMainCom: () {
                  widget.updateComLen();
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: (_loggedUser != null)
            ? FutureBuilder(
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
                      minHeight:
                          25.0, //min height you want to take by container
                      maxHeight:
                          140.0, //max height you want to take by container
                    ),
                    color: Colors.white,
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, bottom: 5, top: 5),
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
                      maxLines: null,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.newline,
                      controller: txt,
                      decoration: InputDecoration(
                        prefixIcon: (_loggedUser != null)
                            ? Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(url),
                                  radius: 15,
                                ),
                              )
                            : const SizedBox.shrink(),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              child: (_file == null)
                                  ? IconButton(
                                      onPressed: () async {
                                        await _selectImage(context);
                                      },
                                      icon: const Icon(
                                        Elusive.picture,
                                        color: Color(0xFFCBCBCB),
                                      ),
                                    )
                                  : Stack(
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
                                                  alignment: FractionalOffset
                                                      .topCenter,
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
                            ),
                            InkWell(
                              onTap: isTyping == false
                                  ? () {}
                                  : () async {
                                      KeyboardUtil.hideKeyboard(context);
                                      await postComment(
                                        uid,
                                        username,
                                        url,
                                      );
                                      for (var m in reg.allMatches(txt.text)) {
                                        await notifyMentioned(
                                            m[1]!, username, uid);
                                      }

                                      setState(() {
                                        isTyping = false;
                                        txt.text = "";
                                        stream = newStream();
                                      });
                                      widget.updateComLen();
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
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 13),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFffffff), width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFFffffff), width: 1.0),
                        ),
                        hintText: (_loggedUser != null)
                            ? 'Comment as $username...'
                            : 'Post comment...',
                        hintStyle: const TextStyle(color: Color(0xFFAFAFAF)),
                      ),
                    ),
                  );
                },
              )
            : buildCustomCommentNavbar(),
      ),
    );
  }

  GestureDetector buildCustomCommentNavbar() {
    return GestureDetector(
      onTap: () {
        _commentAuthModalBox(context);
      },
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
          maxWidth: MediaQuery.of(context).size.width,
          minHeight: 25.0, //min height you want to take by container
          maxHeight: 140.0, //max height you want to take by container
        ),
        color: Colors.white,
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 5, top: 5),
        child: IgnorePointer(
          child: TextField(
            onChanged: (String value) {},
            maxLines: null,
            style: const TextStyle(
              fontSize: 15,
            ),
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              prefixIcon: const SizedBox.shrink(),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () async {},
                    icon: const Icon(
                      Elusive.picture,
                      color: Color(0xFFCBCBCB),
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 8),
                      child: const Text(
                        'Post',
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
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
              hintText: 'Post comment...',
              hintStyle: const TextStyle(color: Color(0xFFAFAFAF)),
            ),
          ),
        ),
      ),
    );
  }
}
