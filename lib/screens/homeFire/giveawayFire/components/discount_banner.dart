import 'package:flutter/material.dart';

import 'package:bbarena_app_com/size_config.dart';

import '../../../add_post/add_post_users/add_screen_users.dart';

class DiscountBanner extends StatelessWidget {
  const DiscountBanner({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: 82,
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 5),
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(10),
        vertical: getProportionateScreenWidth(15),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Expanded(
          child: Column(
            children: [
              const Text(
                'Win awesome prices from our regular',
                style: TextStyle(color: Colors.white24),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AddPostScreenUser.routeName),
                child: const Text(
                  'Giveaways',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
