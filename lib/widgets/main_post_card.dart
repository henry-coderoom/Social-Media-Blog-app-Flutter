// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:bbarena_app_com/screens/homeFire/home_screen.dart';
import 'package:bbarena_app_com/video_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:bbarena_app_com/resource/firebase_methods.dart';
import 'package:bbarena_app_com/widgets/like_animation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import '../helper/utils.dart';
import '../screens/details/details_screen.dart';
import 'package:share_plus/share_plus.dart';

import '../screens/homeFire/bookmarks/bookmark_page.dart';

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

class MainPostCard extends StatefulWidget {
  final snap;
  final Function() refreshParent;
  const MainPostCard(
      {Key? key,
      required this.snap,
      required this.refreshParent,
      this.postsDocId = ''})
      : super(key: key);
  final String postsDocId;

  @override
  State<MainPostCard> createState() => _MainPostCardState();
}

class _MainPostCardState extends State<MainPostCard>
    with SingleTickerProviderStateMixin {
  OverlayEntry? entry;
  late TransformationController controller;
  late AnimationController animationController;
  Animation<Matrix4>? animation;

  late Future<void> _initializedVideoPlayerFuture;

  int commentLen = 0;
  bool isReactActive = false;
  bool ifSaved = false;
  bool isBookmarkLoading = true;

  final asset = 'assets/ForBiggerBlazes.mp4';

  @override
  void initState() {
    checkIfDocExists(widget.snap['postId']);
    check();
    super.initState();
    fetchCommentLen();
    controller = TransformationController();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(() => controller.value = animation!.value)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          removeOverlay();
        }
      });
  }

  // Check If Document Exists
  Future<bool> checkIfDocExists(String postId) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final firebaseUser = _auth.currentUser;
    try {
      // Get reference to Firestore collection
      var collectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser?.uid)
          .collection('bookmarks');
      await collectionRef.doc(postId).get().then((doc) {
        ifSaved = doc.exists;
      });
      setState(() {
        isBookmarkLoading = false;
      });
      return ifSaved;
    } catch (e) {
      throw e;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    animationController.dispose();
    super.dispose();
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {}
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // VideoListData video = VideoListData('videoTitle', widget.snap['videoUrl']);
    void _onShare(BuildContext context) async {
      final imageurl = widget.snap['mediaUrl'];
      final uri = Uri.parse(imageurl);
      final response = await http.get(uri);
      final bytes = response.bodyBytes;
      final temp = await getTemporaryDirectory();
      final path = '${temp.path}/image.jpg';
      File(path).writeAsBytesSync(bytes);
      await Share.shareFiles([path],
          text: '${widget.snap['title']} - More on BB Arena App!');

      final box = context.findRenderObject() as RenderBox?;
    }

    final FirebaseAuth _auth = FirebaseAuth.instance;
    final width = MediaQuery.of(context).size.width;

    DateTime datePosted = (widget.snap['postdate']).toDate();

    final firebaseUser = _auth.currentUser;

    String? uid = firebaseUser?.uid;
    String postId = widget.snap['postId'];
    String postTitle = widget.snap['title'];
    String mediaUrl = widget.snap['mediaUrl'];

    return connectionStatus == false
        ? Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: width > 600
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 5),
                  child: Text(
                    '',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 100,
                          width: 100,
                          child:
                              Image.asset('assets/images/no_signal_image.jpg')),
                      const Text(
                        'No Internet Connection',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 70.0, right: 70),
                        child: Text(
                          'Updates couldn\'t load, please check your internet connection and try again.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, HomeScreenFire.routeName);
                          },
                          child: const Text('Retry'))
                    ],
                  ),
                )
              ],
            ),
          )
        : Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: width > 600
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                // GestureDetector(
                //     onTap: () =>
                //         Navigator.pushNamed(context, VideoScreen.routeName),
                //     child: Text('see Video')),

                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(
                          postId: widget.snap['postId'],
                          postTitle: widget.snap['title'],
                          mediaUrl: widget.snap['mediaUrl'],
                          updateComLen: () {
                            fetchCommentLen();
                          },
                        ),
                      ),
                    ),
                    child: Text(
                      widget.snap['title'],
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                          .copyWith(right: 0),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 40),
                    child: Row(
                      mainAxisAlignment: width > 600
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                            child: Row(
                              mainAxisAlignment: width > 600
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: Image.network(
                                    widget.snap['catUrl'],
                                    height: 21,
                                    width: 21,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  '${widget.snap['category']}  • ',
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  width: 3,
                                ),
                                Text(
                                  timeago.format(datePosted,
                                      locale: 'en_short'),
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            onTap: () {}

                            //     Navigator.pushNamed(
                            //   context,
                            //   DetailsScreen.routeName,
                            //   arguments: PostDetailsArguments1(
                            //       postsDocId: widget.postsDocId),
                            // ),
                            ),
                        const SizedBox(
                          width: 7,
                        ),
                        Container(
                          child: isBookmarkLoading == true
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1,
                                    color: Colors.grey,
                                  ),
                                )
                              : IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () async {
                                    setState(() {
                                      isBookmarkLoading = true;
                                    });
                                    await checkIfDocExists(
                                        widget.snap['postId']);
                                    if (ifSaved == false) {
                                      await FireStoreMethods().savePost(
                                        uid!,
                                        postId,
                                        postTitle,
                                        mediaUrl,
                                      );
                                      setState(() {
                                        ifSaved = true;
                                        isBookmarkLoading = false;
                                      });

                                      showSnackBar(context, 'Post Saved!', 3,
                                          () {
                                        Navigator.pushNamed(
                                            context, BookmarkPage.routeName);
                                      }, ' See Bookmarks');
                                    } else {
                                      await FireStoreMethods()
                                          .unsavePost(uid!, postId);
                                      setState(() {
                                        ifSaved = false;
                                        isBookmarkLoading = false;
                                      });
                                      showSnackBar(context, 'Post Unsaved!', 3,
                                          () {
                                        Navigator.pushNamed(
                                            context, BookmarkPage.routeName);
                                      }, 'See Bookmarks');
                                    }
                                  },
                                  icon: ifSaved == false
                                      ? const Icon(
                                          Elusive.bookmark_empty,
                                          size: 17,
                                          color: Color(0xFFB8B8B8),
                                        )
                                      : const Icon(
                                          Elusive.bookmark,
                                          size: 17,
                                          color: Color(0xFFFFB510),
                                        ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 7,
                ),

                //IMAGE SECTION
                Center(
                    child: widget.snap['mediaUrl'].contains('postWithVideo')
                        ? VideoScreen(video: widget.snap['videoUrl'])
                        : buildImage()),
                const SizedBox(
                  height: 5,
                ),
                //BUTTONS SECTION
                Row(
                  mainAxisAlignment: width > 600
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    //REACTION LIKE THUMBS UP BUTTON
                    LikeAnimation(
                      isAnimating:
                          widget.snap['likes'].contains(firebaseUser?.uid),
                      smallLike: true,
                      child: IconButton(
                        onPressed: (widget.snap['dislikes']
                                .contains(firebaseUser?.uid))
                            ? () async {
                                await FireStoreMethods().removeDislikeForLikes(
                                  widget.snap['postId'],
                                  firebaseUser?.uid,
                                );
                              }
                            : (widget.snap['love'].contains(firebaseUser?.uid))
                                ? () async {
                                    await FireStoreMethods().removeLoveForLikes(
                                      widget.snap['postId'],
                                      firebaseUser?.uid,
                                    );
                                  }
                                : () async {
                                    await FireStoreMethods().likePost(
                                      widget.snap['postId'],
                                      firebaseUser?.uid,
                                      widget.snap['likes'],
                                    );
                                  },
                        icon: widget.snap['likes'].contains(firebaseUser?.uid)
                            ? const Icon(
                                Entypo.thumbs_up,
                                color: Colors.blueAccent,
                                size: 24,
                              )
                            : const Icon(
                                Entypo.thumbs_up,
                                color: Colors.black38,
                                size: 24,
                              ),
                      ),
                    ),
                    LikeAnimation(
                      isAnimating:
                          widget.snap['likes'].contains(firebaseUser?.uid),
                      smallLike: true,
                      child: GestureDetector(
                        onTap: (widget.snap['dislikes']
                                .contains(firebaseUser?.uid))
                            ? () async {
                                await FireStoreMethods().removeDislikeForLikes(
                                  widget.snap['postId'],
                                  firebaseUser?.uid,
                                );
                              }
                            : (widget.snap['love'].contains(firebaseUser?.uid))
                                ? () async {
                                    await FireStoreMethods().removeLoveForLikes(
                                      widget.snap['postId'],
                                      firebaseUser?.uid,
                                    );
                                  }
                                : () async {
                                    await FireStoreMethods().likePost(
                                      widget.snap['postId'],
                                      firebaseUser?.uid,
                                      widget.snap['likes'],
                                    );
                                  },
                        child: Text(
                          '${widget.snap['likes'].length}',
                          style: const TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    //REACTION THUMBS DOWN
                    LikeAnimation(
                      isAnimating:
                          widget.snap['dislikes'].contains(firebaseUser?.uid),
                      smallDislike: true,
                      child: IconButton(
                        onPressed: (widget.snap['likes']
                                .contains(firebaseUser?.uid))
                            ? () async {
                                await FireStoreMethods().removeLikeForDislike(
                                  widget.snap['postId'],
                                  firebaseUser?.uid,
                                );
                              }
                            : (widget.snap['love'].contains(firebaseUser?.uid))
                                ? () async {
                                    await FireStoreMethods()
                                        .removeLoveForDislikes(
                                      widget.snap['postId'],
                                      firebaseUser?.uid,
                                    );
                                  }
                                : () async {
                                    await FireStoreMethods().disLikePost(
                                      widget.snap['postId'],
                                      firebaseUser?.uid,
                                      widget.snap['dislikes'],
                                    );
                                  },
                        icon:
                            widget.snap['dislikes'].contains(firebaseUser?.uid)
                                ? const Icon(
                                    Entypo.thumbs_down,
                                    color: Colors.blueAccent,
                                    size: 24,
                                  )
                                : const Icon(
                                    Entypo.thumbs_down,
                                    color: Color(0xFFA1A1A1),
                                    size: 24,
                                  ),
                      ),
                    ),
                    LikeAnimation(
                      isAnimating:
                          widget.snap['dislikes'].contains(firebaseUser?.uid),
                      smallDislike: true,
                      child: GestureDetector(
                        onTap: (widget.snap['likes']
                                .contains(firebaseUser?.uid))
                            ? () async {
                                await FireStoreMethods().removeLikeForDislike(
                                  widget.snap['postId'],
                                  firebaseUser?.uid,
                                );
                              }
                            : (widget.snap['love'].contains(firebaseUser?.uid))
                                ? () async {
                                    await FireStoreMethods()
                                        .removeLoveForDislikes(
                                      widget.snap['postId'],
                                      firebaseUser?.uid,
                                    );
                                  }
                                : () async {
                                    await FireStoreMethods().disLikePost(
                                      widget.snap['postId'],
                                      firebaseUser?.uid,
                                      widget.snap['dislikes'],
                                    );
                                  },
                        child: Text(
                          '${widget.snap['dislikes'].length}',
                          style: const TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    //REACTION LOVE BUTTON
                    LikeAnimation(
                      isAnimating:
                          widget.snap['love'].contains(firebaseUser?.uid),
                      smallLove: true,
                      child: IconButton(
                        onPressed:
                            (widget.snap['likes'].contains(firebaseUser?.uid))
                                ? () async {
                                    await FireStoreMethods().removeLikeForLove(
                                      widget.snap['postId'],
                                      firebaseUser?.uid,
                                    );
                                  }
                                : (widget.snap['dislikes']
                                        .contains(firebaseUser?.uid))
                                    ? () async {
                                        await FireStoreMethods()
                                            .removeDislikeForLove(
                                          widget.snap['postId'],
                                          firebaseUser?.uid,
                                        );
                                      }
                                    : () async {
                                        await FireStoreMethods().lovePost(
                                          widget.snap['postId'],
                                          firebaseUser?.uid,
                                          widget.snap['love'],
                                        );
                                      },
                        icon: widget.snap['love'].contains(firebaseUser?.uid)
                            ? SvgPicture.asset(
                                "assets/icons/haha_emoji.svg",
                                height: 22,
                                width: 21,
                              )
                            : SvgPicture.asset(
                                "assets/icons/haha_emoji_nocolor.svg",
                                height: 22,
                                width: 21,
                              ),
                      ),
                    ),
                    LikeAnimation(
                      isAnimating:
                          widget.snap['love'].contains(firebaseUser?.uid),
                      smallLove: true,
                      child: GestureDetector(
                        onTap:
                            (widget.snap['likes'].contains(firebaseUser?.uid))
                                ? () async {
                                    await FireStoreMethods().removeLikeForLove(
                                      widget.snap['postId'],
                                      firebaseUser?.uid,
                                    );
                                  }
                                : (widget.snap['dislikes']
                                        .contains(firebaseUser?.uid))
                                    ? () async {
                                        await FireStoreMethods()
                                            .removeDislikeForLove(
                                          widget.snap['postId'],
                                          firebaseUser?.uid,
                                        );
                                      }
                                    : () async {
                                        await FireStoreMethods().lovePost(
                                          widget.snap['postId'],
                                          firebaseUser?.uid,
                                          widget.snap['love'],
                                        );
                                      },
                        child: Text(
                          '${widget.snap['love'].length}',
                          style: const TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    //COMMENT BUTTON ICON SECTION
                    SizedBox(
                      width: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          children: [
                            InkWell(
                              child: IconButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => DetailsScreen(
                                      postId: widget.snap['postId'],
                                      postTitle: widget.snap['title'],
                                      mediaUrl: widget.snap['mediaUrl'],
                                      updateComLen: () {
                                        fetchCommentLen();
                                      },
                                    ),
                                  ),
                                ),
                                icon: const Icon(
                                  Elusive.comment_alt,
                                  size: 22,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DetailsScreen(
                                    postId: widget.snap['postId'],
                                    postTitle: widget.snap['title'],
                                    mediaUrl: widget.snap['mediaUrl'],
                                    updateComLen: () {
                                      fetchCommentLen();
                                    },
                                  ),
                                ),
                              ),
                              child: Text(
                                '$commentLen',
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),

                            //SHARE BUTTON ICON SECTION
                            IconButton(
                              onPressed: () => _onShare(context),
                              icon: const Icon(
                                MfgLabs.export_icon,
                                color: Colors.grey,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 8,
                  color: Color(0xFFEEEEEE),
                ),
              ],
            ),
          );
  }

  Widget buildImage() {
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DetailsScreen(
            postId: widget.snap['postId'],
            postTitle: widget.snap['title'],
            mediaUrl: widget.snap['mediaUrl'],
            updateComLen: () {
              fetchCommentLen();
            },
          ),
        ),
      ),
      child: SizedBox(
        height: width > 600 ? 400 : MediaQuery.of(context).size.height * 0.42,
        width: width > 600 ? 500 : double.infinity,
        child: Builder(builder: (context) {
          return InteractiveViewer(
            transformationController: controller,
            maxScale: 4,
            minScale: 1,
            clipBehavior: Clip.none,
            onInteractionEnd: (details) {
              resetAnimation();
            },
            onInteractionStart: (details) {
              if (details.pointerCount < 2) return;

              showOverlay(context);
            },
            child: Image.network(
              widget.snap['mediaUrl'],
              fit: BoxFit.cover,
            ),
          );
        }),
      ),
    );
  }

  void showOverlay(BuildContext context) {
    final renderBox = context.findRenderObject()! as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = MediaQuery.of(context).size;

    entry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              child: Container(color: Colors.black),
            ),
            Positioned(
              left: offset.dx,
              top: offset.dy,
              width: size.width,
              child: buildImage(),
            ),
          ],
        );
      },
    );

    final overlay = Overlay.of(context)!;
    overlay.insert(entry!);
  }

  void removeOverlay() {
    entry?.remove();
    entry = null;
  }

  void resetAnimation() {
    animation = Matrix4Tween(
      begin: controller.value,
      end: Matrix4.identity(),
    ).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut));

    animationController.forward(from: 0);
  }
}
