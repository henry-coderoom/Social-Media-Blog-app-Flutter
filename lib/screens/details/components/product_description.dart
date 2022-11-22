import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';
import '../../../models/main_post.dart';
import '../../../size_config.dart';

class ProductDescription extends StatelessWidget {
  const ProductDescription({
    Key? key,
    required this.postId,
    this.pressOnSeeMore,
  }) : super(key: key);

  final MainPost postId;
  final GestureTapCallback? pressOnSeeMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: [
        //     InkWell(
        //       borderRadius: BorderRadius.circular(50),
        //       onTap: () {},
        //       child: Container(
        //         padding: EdgeInsets.all(getProportionateScreenWidth(8)),
        //         height: getProportionateScreenWidth(28),
        //         width: getProportionateScreenWidth(28),
        //         decoration: BoxDecoration(
        //           color: product.isFavourite
        //               ? kPrimaryColor.withOpacity(0.15)
        //               : kSecondaryColor.withOpacity(0.1),
        //           shape: BoxShape.circle,
        //         ),
        //         child: SvgPicture.asset(
        //           "assets/icons/Heart Icon_2.svg",
        //           color: product.isFavourite
        //               ? Color(0xFFFF4848)
        //               : Color(0xFFDBDEE4),
        //         ),
        //       ),
        //     ),
        //     InkWell(
        //       borderRadius: BorderRadius.circular(50),
        //       onTap: () {},
        //       child: Container(
        //         padding: EdgeInsets.all(getProportionateScreenWidth(8)),
        //         height: getProportionateScreenWidth(28),
        //         width: getProportionateScreenWidth(28),
        //         decoration: BoxDecoration(
        //           color: product.isFavourite
        //               ? kPrimaryColor.withOpacity(0.15)
        //               : kSecondaryColor.withOpacity(0.1),
        //           shape: BoxShape.circle,
        //         ),
        //         child: SvgPicture.asset(
        //           "assets/icons/Heart Icon_2.svg",
        //           color: product.isFavourite
        //               ? Color(0xFFFF4848)
        //               : Color(0xFFDBDEE4),
        //         ),
        //       ),
        //     ),
        //     InkWell(
        //       borderRadius: BorderRadius.circular(50),
        //       onTap: () {},
        //       child: Container(
        //         padding: EdgeInsets.all(getProportionateScreenWidth(8)),
        //         height: getProportionateScreenWidth(28),
        //         width: getProportionateScreenWidth(28),
        //         decoration: BoxDecoration(
        //           color: product.isFavourite
        //               ? kPrimaryColor.withOpacity(0.15)
        //               : kSecondaryColor.withOpacity(0.1),
        //           shape: BoxShape.circle,
        //         ),
        //         child: SvgPicture.asset(
        //           "assets/icons/Heart Icon_2.svg",
        //           color: product.isFavourite
        //               ? Color(0xFFFF4848)
        //               : Color(0xFFDBDEE4),
        //         ),
        //       ),
        //     ),
        //     Row(
        //       children: [
        //         Icon(
        //           Icons.comment,
        //           size: 25,
        //         ),
        //         Text(
        //           "${product.price}",
        //           style: TextStyle(
        //             fontSize: getProportionateScreenWidth(18),
        //             fontWeight: FontWeight.w600,
        //             color: kPrimaryColor,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ],
        // ),
        // SizedBox(
        //   height: 30,
        // ),
        // Padding(
        //   padding:
        //       EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
        //   child: Text(
        //     product.title,
        //     style: Theme.of(context).textTheme.headline5,
        //   ),
        // ),
        // SizedBox(
        //   height: 15,
        // ),
        // Padding(
        //   padding: EdgeInsets.only(
        //     left: getProportionateScreenWidth(20),
        //     right: getProportionateScreenWidth(64),
        //   ),
        //   child: Text(
        //     product.description,
        //     maxLines: 1000,
        //     style: TextStyle(fontSize: 17),
        //   ),
        // ),
      ],
    );
  }
}
