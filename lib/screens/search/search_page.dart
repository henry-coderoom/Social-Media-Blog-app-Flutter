import 'package:bbarena_app_com/screens/user_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bbarena_app_com/size_config.dart';
import 'package:flutter/services.dart';
import '../../constants.dart';
import '../../helper/keyboard.dart';
import '../details/details_screen.dart';
import '../homeFire/profileFire/profile_screen.dart';
import '../sign_up/components/sign_up_form.dart';

class SearchPage extends StatefulWidget {
  static String routeName = "/searchPage";
  const SearchPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        KeyboardUtil.hideKeyboard(context);
        searchingPost = false;
        searchingUser = false;
      });
    });
    super.initState();
  }

  final TextEditingController searchPostsController = TextEditingController();
  final TextEditingController searchUserController = TextEditingController();

  bool isShowUsers = false;
  bool searchingPost = false;
  bool searchingUser = false;

  late Future streamQuery;

  @override
  void dispose() {
    _tabController.dispose();
    searchPostsController.dispose();
    searchUserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final firebaseUser = _auth.currentUser;
    SizeConfig().init(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            TabBar(
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.black,
              indicatorColor: Colors.white54,
              tabs: const [
                Tab(
                    child: Text(
                  'Search Posts',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
                Tab(
                    child: Text(
                  'Search Users',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
              ],
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 15.0, right: 20, bottom: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  KeyboardUtil.hideKeyboard(context);
                                },
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Form(
                                child: Container(
                                  width: SizeConfig.screenWidth * 0.7,
                                  decoration: BoxDecoration(
                                    color: kSecondaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: TextFormField(
                                    autofocus: true,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    controller: searchPostsController,
                                    textInputAction: TextInputAction.search,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal:
                                              getProportionateScreenWidth(20),
                                          vertical:
                                              getProportionateScreenWidth(9)),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      hintText: "Search by post title...",
                                    ),
                                    onChanged: (String _) {
                                      if (searchPostsController.text.isEmpty) {
                                        searchingPost = false;
                                      } else {
                                        setState(() {
                                          streamQuery = FirebaseFirestore
                                              .instance
                                              .collection('posts')
                                              .where('title',
                                                  isGreaterThanOrEqualTo:
                                                      searchPostsController
                                                          .text)
                                              .where('title',
                                                  isLessThan:
                                                      searchPostsController
                                                              .text +
                                                          'z')
                                              .get();
                                          searchingPost = true;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: searchingPost == true
                              ? FutureBuilder(
                                  future: streamQuery,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: (snapshot.data! as dynamic)
                                          .docs
                                          .length,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: [
                                            InkWell(
                                              onTap: () =>
                                                  Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailsScreen(
                                                    postId: (snapshot.data!
                                                            as dynamic)
                                                        .docs[index]['postId'],
                                                    updateComLen: () {},
                                                  ),
                                                ),
                                              ),
                                              child: ListTile(
                                                leading: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  child: Image.network(
                                                    (snapshot.data! as dynamic)
                                                            .docs[index]
                                                        ['mediaUrl'],
                                                    height: 50,
                                                    width: 50,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                title: Text(
                                                  (snapshot.data! as dynamic)
                                                      .docs[index]['title'],
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            const Divider(
                                              thickness: 1,
                                              color: Colors.black12,
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                )
                              : const Center(),
                        )
                      ],
                    ),
                  ),

                  ///SEARCH USER SECTION STARTS HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 15.0, right: 20, bottom: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  KeyboardUtil.hideKeyboard(context);
                                },
                              ),
                              const SizedBox(
                                width: 0,
                              ),
                              Form(
                                child: Container(
                                  width: SizeConfig.screenWidth * 0.7,
                                  decoration: BoxDecoration(
                                    color: kSecondaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: TextFormField(
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'\s')),
                                      LowerCaseTextFormatter(),
                                    ],
                                    controller: searchUserController,
                                    textInputAction: TextInputAction.search,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal:
                                              getProportionateScreenWidth(20),
                                          vertical:
                                              getProportionateScreenWidth(9)),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      hintText: "Search users by username...",
                                    ),
                                    onChanged: (String _) {
                                      if (searchUserController.text.isEmpty) {
                                        searchingUser = false;
                                      } else {
                                        setState(() {
                                          streamQuery = FirebaseFirestore
                                              .instance
                                              .collection('users')
                                              .where('username',
                                                  isGreaterThanOrEqualTo:
                                                      searchUserController.text)
                                              .where('username',
                                                  isLessThan:
                                                      searchUserController
                                                              .text +
                                                          'z')
                                              .get();
                                          searchingUser = true;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: searchingUser == true
                              ? FutureBuilder(
                                  future: streamQuery,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    return ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: (snapshot.data! as dynamic)
                                            .docs
                                            .length,
                                        itemBuilder: (context, index) {
                                          return Column(
                                            children: [
                                              InkWell(
                                                onTap: (snapshot.data!
                                                                    as dynamic)
                                                                .docs[index]
                                                            ['uid'] ==
                                                        firebaseUser?.uid
                                                    ? () => Navigator.pushNamed(
                                                        context,
                                                        ProfileScreenFire
                                                            .routeName)
                                                    : () =>
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    UserScreen(
                                                              userId: (snapshot
                                                                          .data!
                                                                      as dynamic)
                                                                  .docs[index]['uid'],
                                                            ),
                                                          ),
                                                        ),
                                                child: ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                      (snapshot.data!
                                                              as dynamic)
                                                          .docs[index]['url'],
                                                    ),
                                                    radius: 16,
                                                  ),
                                                  title: Text(
                                                    '@${(snapshot.data! as dynamic).docs[index]['username']}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              const Divider(
                                                thickness: 1,
                                                color: Colors.black12,
                                              ),
                                            ],
                                          );
                                        });
                                  },
                                )
                              : const Center(),
                        )
                      ],
                    ),
                  ),
                ],
                controller: _tabController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
