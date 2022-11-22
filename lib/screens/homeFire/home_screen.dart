import 'package:bbarena_app_com/screens/homeFire/components/home_header.dart';
import 'package:bbarena_app_com/screens/wallet_screens/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:bbarena_app_com/size_config.dart';
import 'package:bbarena_app_com/screens/homeFire/components/body.dart';
import 'package:bbarena_app_com/widgets/exit-popup.dart';

import 'giveawayFire/components/body.dart';

class HomeScreenFire extends StatefulWidget {
  static String routeName = "/homeFire";
  final Function() navTo;

  const HomeScreenFire({
    Key? key,
    required this.navTo,
  }) : super(key: key);

  @override
  State<HomeScreenFire> createState() => _HomeScreenFireState();
}

class _HomeScreenFireState extends State<HomeScreenFire>
    with AutomaticKeepAliveClientMixin<HomeScreenFire> {
  // final controller = ScrollController();
  final PageController _pageController = PageController(initialPage: 0);
  void onPageChanged(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
    });
  }

  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();

    super.initState();
  }

  void _scrollToTop() {
    if (_scrollController.offset >= 2) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.linear);
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    super.build(context);
    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: Scaffold(
        body: SafeArea(
          child: NestedScrollView(
            controller: _scrollController,
            physics: const NeverScrollableScrollPhysics(),
            // floatHeaderSlivers: true,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                const SliverAppBar(
                  automaticallyImplyLeading: false,
                  floating: true,
                  expandedHeight: 56,
                  snap: true,
                  flexibleSpace: HomeHeader(),
                ),
              ];
            },

            body: PageView(
              controller: _pageController,
              onPageChanged: onPageChanged,
              children: const [
                BodyFire(),
                WalletScreen(
                  title: 'Wallet',
                ),
                BodyGiveFire(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,

          //Unselected
          unselectedFontSize: 13,
          unselectedIconTheme:
              const IconThemeData(color: Color(0xFFB1B1B1), size: 30),
          unselectedItemColor: const Color(0xFFB1B1B1),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),

          //Selected

          selectedFontSize: 13,
          selectedIconTheme:
              const IconThemeData(color: Color(0xFF000000), size: 33),
          selectedItemColor: const Color(0xFF000000),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),

          currentIndex: _currentIndex,
          onTap: (index) {
            if (_currentIndex == index) {
              _scrollToTop();
            } else {
              _pageController.animateToPage(index,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOutSine);
            }
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.local_fire_department),
              label: 'LATEST',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'WALLET',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard),
              label: 'GIVEAWAY',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.how_to_vote),
              label: 'VOTES',
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
