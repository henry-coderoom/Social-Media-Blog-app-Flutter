import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../size_config.dart';

class DiscountBanner extends StatelessWidget {
  const DiscountBanner({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: 200,
      margin: const EdgeInsets.fromLTRB(5, 15, 5, 15),
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(20),
        vertical: getProportionateScreenWidth(15),
      ),
      decoration: BoxDecoration(
        image: const DecorationImage(
            image: AssetImage("assets/images/black-gradient.png"),
            fit: BoxFit.cover),
        // color: Color(0xFF000000),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.7),
              offset: const Offset(0, 8),
              blurRadius: 5.0,
              spreadRadius: 0)
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: const [
                Text(
                  'CURRENT HOH',
                  style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w900,
                      fontSize: 22),
                ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 90,
                  width: 90,
                  child: CircleAvatar(
                    backgroundImage:
                        AssetImage("assets/images/Profile Image.png"),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                AutoSizeText(
                  'Whitemoney',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20),
                  minFontSize: 16,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Column(
              children: [
                const SizedBox(
                  height: 0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Season',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Color(0xFFBCBCBC),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Expanded(
                      child: AutoSizeText(
                        '7 - Shine Ya eye',
                        minFontSize: 3,
                        maxLines: 4,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Week',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Color(0xFFBCBCBC),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        )),
                    SizedBox(
                      width: 30,
                    ),
                    Text(
                      '10',
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                IntrinsicWidth(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: const [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Housemates',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Color(0xFFBCBCBC),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        '18',
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Wrap(
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.orangeAccent),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text('ALL HOUSEMATES'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
