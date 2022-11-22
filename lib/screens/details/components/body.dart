// ignore_for_file: prefer_typing_uninitialized_variables
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:share_plus/share_plus.dart';
import 'package:styled_text/styled_text.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../helper/utils.dart';
import '../../../resource/firebase_methods.dart';
import '../../../widgets/like_animation.dart';

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

class PostDetailsCard extends StatefulWidget {
  final snap;
  final Function() refresh;
  const PostDetailsCard({
    Key? key,
    required this.refresh,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostDetailsCard> createState() => _PostDetailsCardState();
}

class _PostDetailsCardState extends State<PostDetailsCard>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  OverlayEntry? entry;
  late TransformationController controller;
  late AnimationController animationController;
  Animation<Matrix4>? animation;

  int commentLen = 0;
  bool loadingComment = true;

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
      loadingComment = false;
    } catch (err) {}
    setState(() {});
  }

  @override
  void initState() {
    fetchCommentLen();
    check();
    super.initState();
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

  @override
  void dispose() {
    controller.dispose();
    animationController.dispose();
    super.dispose();
  }

  bool isShare = false;

  Future<void> _onShare(BuildContext context) async {
    final imageurl = widget.snap['mediaUrl'];
    final uri = Uri.parse(imageurl);
    final response = await http.get(uri);
    final bytes = response.bodyBytes;
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/image.jpg';
    File(path).writeAsBytesSync(bytes);
    await Share.shareFiles([path],
        text: '${widget.snap['title']} - This and more on BB Arena App!');

    final box = context.findRenderObject() as RenderBox?;
  }

  @override
  Widget build(BuildContext context) {
    final dataKey = GlobalKey();
    final width = MediaQuery.of(context).size.width;
    DateTime datePosted = (widget.snap['postdate']).toDate();

    final firebaseUser = _auth.currentUser;

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
                          'Content couldn\'t load, please check your internet connection and try again.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            widget.refresh();
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
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  child: GestureDetector(
                    onLongPress: () async {
                      await Clipboard.setData(
                          ClipboardData(text: widget.snap['title']));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
                  color: Colors.white,
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
                        Container(
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
                                timeago.format(datePosted, locale: 'en_short'),
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 7,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),

                //IMAGE SECTION
                buildImage(),
                const SizedBox(
                  height: 5,
                ),
                //BUTTONS SECTION
                Row(
                  mainAxisAlignment: width > 600
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 7,
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
                      width: MediaQuery.of(context).size.height * 0.044,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        children: [
                          InkWell(
                            child: IconButton(
                              onPressed: () {
                                final targetContext = dataKey.currentContext;

                                Scrollable.ensureVisible(
                                  targetContext!,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                );
                              },
                              icon: const Icon(
                                Elusive.comment_alt,
                                size: 22,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              final targetContext = dataKey.currentContext;

                              Scrollable.ensureVisible(
                                targetContext!,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Text(
                              '$commentLen',
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(
                            width: 9,
                          ),

                          //SHARE BUTTON ICON SECTION
                          InkWell(
                            child: IconButton(
                              onPressed: () async {
                                setState(() {
                                  isShare = true;
                                });
                                await _onShare(context);
                                setState(() {
                                  isShare = false;
                                });
                              },
                              icon: isShare != true
                                  ? const Icon(
                                      MfgLabs.export_icon,
                                      color: Colors.grey,
                                      size: 22,
                                    )
                                  : const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1,
                                        color: Colors.grey,
                                      )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 0,
                ),
                const Divider(
                  thickness: 8,
                  color: Color(0x174D5C74),
                ),

                Center(
                  child: widget.snap['description'].contains(' ')
                      ? Container(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10, bottom: 10),
                          child: GestureDetector(
                            onLongPress: () async {
                              await Clipboard.setData(ClipboardData(
                                  text: widget.snap['description']));
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

                              // showSnackBar(
                              //     context, 'Text Copied!', 2, () {}, '');
                            },
                            child: StyledText(
                              text: widget.snap['description'],
                              tags: {
                                'bold': StyledTextTag(
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                'b': StyledTextTag(
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                'red': StyledTextTag(
                                    style: const TextStyle(color: Colors.red)),
                                'i': StyledTextTag(
                                    style: const TextStyle(
                                        fontStyle: FontStyle.italic)),
                                'color': StyledTextCustomTag(
                                    baseStyle: const TextStyle(
                                        fontStyle: FontStyle.italic),
                                    parse: (baseStyle, attributes) {
                                      if (attributes.containsKey('text') &&
                                          (attributes['text']!
                                                  .substring(0, 1) ==
                                              '#') &&
                                          attributes['text']!.length >= 6) {
                                        final String hexColor =
                                            attributes['text']!.substring(1);
                                        final String alphaChannel =
                                            (hexColor.length == 8)
                                                ? hexColor.substring(6, 8)
                                                : 'FF';
                                        final Color color = Color(int.parse(
                                            '0x$alphaChannel' +
                                                hexColor.substring(0, 6)));
                                        return baseStyle?.copyWith(
                                            color: color);
                                      } else {
                                        return baseStyle;
                                      }
                                    }),
                              },
                              style: const TextStyle(
                                  fontSize: 17, color: Color(0xFF585858)),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const Divider(
                  thickness: 8,
                  color: Color(0x0800081f),
                ),

                Container(
                  // width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(0, 1, 0, 1),
                  padding: const EdgeInsets.only(
                    left: 25.0,
                  ),
                  child: loadingComment == true
                      ? Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.fromLTRB(0, 1, 0, 1),
                          child: const CircularProgressIndicator(
                            strokeWidth: 1.3,
                            color: Colors.grey,
                          ),
                        )
                      : Card(
                          color: Colors.transparent,
                          elevation: 0,
                          key: dataKey,
                          child: commentLen == 0
                              ? const Text(
                                  'Be the first to comment',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700),
                                )
                              : Text(
                                  'Comments ($commentLen)',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700),
                                ),
                        ),
                ),
                // CommentsScreen(postId: widget.snap['postId']),
              ],
            ),
          );
  }

  Widget buildImage() {
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
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
