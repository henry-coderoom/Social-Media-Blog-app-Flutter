import 'package:bbarena_app_com/components/auth_options_container.dart';
import 'package:bbarena_app_com/components/modal_box.dart';
import 'package:bbarena_app_com/screens/Setting_Screen/settings_page.dart';
import 'package:bbarena_app_com/screens/feedback_screen/feeback_screen.dart';
import 'package:bbarena_app_com/screens/homeFire/bookmarks/bookmark_page.dart';
import 'package:bbarena_app_com/screens/homeFire/components/home_user_image.dart';
import 'package:bbarena_app_com/screens/homeFire/notifications/notif_screen.dart';
import 'package:bbarena_app_com/screens/homeFire/profileFire/profile_screen.dart';
import 'package:bbarena_app_com/screens/search/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:progress_indicators/progress_indicators.dart';
import '../../../size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomeHeader extends StatefulWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  late String url;
  late String username;

  var loggedUser = FirebaseAuth.instance.currentUser;

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x88000000),
      context: context,
      builder: (context) {
        return ModalBox(refresh: () {}, modalWidget: buildModalMain());
      },
    );
  }

  void _showModalLoggedOut(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x88000000),
      context: context,
      builder: (context) {
        return ModalBox(refresh: () {}, modalWidget: buildModalLoggedOut());
      },
    );
  }

  void _modalAuthOptionsNotif(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x88000000),
      context: context,
      builder: (context) {
        return ModalBox(
          refresh: () {},
          modalWidget: AuthOptionsContainer(
            leadingText:
                'Get real-time notifications on interactions and hot posts',
            topIcon: const Icon(
              Icons.notifications,
              size: 40,
              color: Colors.blue,
            ),
            refresh: () {},
          ),
        );
      },
    );
  }

  void _modalAuthOptionsMain(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x88000000),
      context: context,
      builder: (context) {
        return ModalBox(
            refresh: () {},
            modalWidget: AuthOptionsContainer(
              leadingText:
                  'Join the biggest and most interactive meme and entertainment community',
              topIcon: Icon(
                Elusive.group_circled,
                size: 40,
                color: Colors.yellow.shade900,
              ),
              refresh: () {},
            ));
      },
    );
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
    fetch = newFetch();
    FirebaseAuth.instance.authStateChanges().listen((loggedInUser) {
      if (loggedInUser != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(loggedInUser.uid)
            .get()
            .then((doc) {
          if (doc.exists) {
            fetch = newFetch();
            loggedUser = loggedInUser;
            setState(() {});
          } else {
            Future.delayed(const Duration(milliseconds: 1000)).then((value) {
              fetch = newFetch();
              loggedUser = loggedInUser;
              setState(() {});
            });
          }
        });
      } else {
        loggedUser = null;
        setState(() {});
      }
    });
    super.initState();
  }

  var fetch;

  newFetch() async {
    final firebaseUser = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get()
        .then((ds) {
      url = ds['url'];
      username = ds['username'];
    }).catchError((e) {
      print(e);
      final snackBar = SnackBar(content: Text(e.toString()));
      Scaffold.of(context).showSnackBar(snackBar);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                offset: const Offset(0, 8),
                blurRadius: 5.0,
                spreadRadius: 0)
          ],
        ),
        height: 65,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: SizeConfig.screenWidth * 0.58,
                child: const Text(
                  'BB Arena',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, SearchPage.routeName),
                child: const Icon(
                  Icons.search,
                  size: 24,
                  color: Colors.grey,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: GestureDetector(
                  onTap: (loggedUser != null)
                      ? () =>
                          Navigator.pushNamed(context, NotifScreen.routeName)
                      : () {
                          _modalAuthOptionsNotif(context);
                        },
                  child: const Icon(
                    Icons.notifications,
                    size: 26,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(
                child: (loggedUser != null)
                    ? FutureBuilder(
                        future: fetch,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return GlowingProgressIndicator(
                              child: const Icon(
                                Icons.circle,
                                size: 40,
                                color: Color(0xFFC2C2C2),
                              ),
                            );
                          }
                          return HomeUserImage(
                            numOfitem: 1,
                            press: () {
                              _showModalBottomSheet(context);
                            },
                            url: url,
                          );
                        },
                      )
                    : GestureDetector(
                        onTap: () => _showModalLoggedOut(context),
                        child: const Icon(
                          Icons.account_circle,
                          size: 35,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  CustomContainer buildModalMain() {
    return CustomContainer(
      refresh: () {},
      childWidget: IntrinsicHeight(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder(
              future: fetch,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return JumpingDotsProgressIndicator(
                    fontSize: 30,
                  );
                }
                return buildMainMenuModal(
                    'My Account',
                    HomeUserImage(
                      numOfitem: 1,
                      press: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                            context, ProfileScreenFire.routeName);
                      },
                      url: url,
                    ), () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, ProfileScreenFire.routeName);
                }, '@$username');
              },
            ),
            const Divider(
              thickness: 1,
              height: 0,
            ),
            buildMainMenuModal(
                'Bookmarks',
                const Icon(
                  Octicons.bookmark,
                  color: Color(0xFF929292),
                ), () {
              Navigator.pop(context);
              Navigator.pushNamed(context, BookmarkPage.routeName);
            }, ''),
            const Divider(
              thickness: 1,
              height: 0,
            ),
            buildMainMenuModal(
                'Settings',
                const Icon(
                  Icons.settings,
                  color: Color(0xFF929292),
                ), () {
              Navigator.pop(context);
              Navigator.pushNamed(context, SettingsPage.routeName);
            }, ''),
            const Divider(
              thickness: 1,
              height: 0,
            ),
            buildMainMenuModal(
                'Submit Feedback',
                const Icon(
                  Icons.chat,
                  color: Color(0xFF929292),
                ), () {
              Navigator.pop(context);
              Navigator.pushNamed(context, FeedBackScreen.routeName);
            }, ''),
          ],
        ),
      ),
    );
  }

  CustomContainer buildModalLoggedOut() {
    return CustomContainer(
      childWidget: IntrinsicHeight(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildMainMenuModal(
                'Register or Login',
                const Icon(
                  Icons.account_circle,
                  color: Color(0xFF929292),
                  size: 28,
                ), () {
              Navigator.pop(context);
              _modalAuthOptionsMain(context);
            }, ''),
            const Divider(
              thickness: 1,
              height: 0,
            ),
            buildMainMenuModal(
                'Bookmarks',
                const Icon(
                  Octicons.bookmark,
                  color: Color(0xFF929292),
                ), () {
              Navigator.pop(context);
              _modalAuthOptionsBookmark(context);
            }, ''),
            const Divider(
              thickness: 1,
              height: 0,
            ),
            buildMainMenuModal(
                'Settings',
                const Icon(
                  Icons.settings,
                  color: Color(0xFF929292),
                ), () {
              Navigator.pop(context);
              Navigator.pushNamed(context, SettingsPage.routeName);
            }, ''),
            const Divider(
              thickness: 1,
              height: 0,
            ),
            buildMainMenuModal(
                'Submit Feedback',
                const Icon(
                  Icons.chat,
                  color: Color(0xFF929292),
                ), () {
              Navigator.pop(context);
              Navigator.pushNamed(context, FeedBackScreen.routeName);
            }, ''),
          ],
        ),
      ),
      refresh: () {},
    );
  }

  Expanded buildMainMenuModal(
      String title, Widget leadIcon, Function() function, String trailText) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 5, bottom: 9),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.transparent,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(30),
              ),
            ),
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8),
            child: ListTile(
              dense: true,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              leading: leadIcon,
              title: Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w800),
              ),
              trailing: Text(
                trailText,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
          onPressed: () {
            function();
          },
          //exit the app
        ),
      ),
    );
  }
}
