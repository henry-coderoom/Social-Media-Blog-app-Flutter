import 'dart:io';
import 'package:bbarena_app_com/screens/homeFire/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../size_config.dart';
import '../../../widgets/main_post_card.dart';
import 'discount_banner.dart';

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

class BodyFire extends StatefulWidget {
  const BodyFire({Key? key}) : super(key: key);

  @override
  State<BodyFire> createState() => _BodyFireState();
}

class _BodyFireState extends State<BodyFire>
    with AutomaticKeepAliveClientMixin<BodyFire> {
  var stream;
  var imageUrl;

  @override
  void initState() {
    check();
    super.initState();
    stream = newStream();
    // newImages();
    // cacheImage();
  }

  Stream<QuerySnapshot> newStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('section', isEqualTo: 'main')
        .orderBy('postdate', descending: true)
        .snapshots();
  }

  // Future<void> cacheImage() async {
  //   final uri = Uri.parse(imageUrl);
  //   final response = await http.get(uri);
  //   final bytes = response.bodyBytes;
  //   await DefaultCacheManager().putFile(
  //     imageUrl,
  //     bytes,
  //     fileExtension: "png",
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: RefreshIndicator(
        strokeWidth: 1,
        color: Colors.black38,
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          await check();
          if (connectionStatus == true) {
            setState(() {
              stream = newStream();
            });
          } else {
            Navigator.pushNamed(context, HomeScreenFire.routeName);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const DiscountBanner(),
              StreamBuilder(
                  stream: stream,
                  builder: (context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: connectionStatus == false
                          ? 1
                          : snapshot.data!.docs.length,
                      itemBuilder: (context, index) => MainPostCard(
                        snap: snapshot.data!.docs[index].data(),
                        postsDocId: snapshot.data!.docs[index].id.toString(),
                        refreshParent: () {
                          setState(() {
                            stream = newStream();
                          });
                        },
                      ),
                    );
                  }),
              SizedBox(height: getProportionateScreenWidth(30)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
