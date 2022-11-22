import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';
import '../../../size_config.dart';

class HomeUserImage extends StatelessWidget {
  const HomeUserImage({
    Key? key,
    required this.url,
    this.numOfitem = 0,
    required this.press,
  }) : super(key: key);

  final String url;
  final int numOfitem;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: press,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(getProportionateScreenWidth(0)),
            height: getProportionateScreenWidth(30),
            width: getProportionateScreenWidth(30),
            decoration: BoxDecoration(
              color: kSecondaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              height: 25,
              width: 25,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(url),
                  ),
                ],
              ),
            ),
          ),
          if (numOfitem != 0)
            Positioned(
              top: 20,
              right: -2,
              child: Container(
                height: getProportionateScreenWidth(11),
                width: getProportionateScreenWidth(11),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(width: 1.5, color: Colors.white),
                ),
                child: Center(
                  child: Text(
                    "$numOfitem",
                    style: TextStyle(
                      fontSize: getProportionateScreenWidth(0),
                      height: 1,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
