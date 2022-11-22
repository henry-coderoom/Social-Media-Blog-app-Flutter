import 'package:flutter/material.dart';

import 'package:bbarena_app_com/size_config.dart';
import 'discount_banner.dart';
import 'popular_product.dart';

class BodyGiveFire extends StatelessWidget {
  const BodyGiveFire({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: getProportionateScreenWidth(0)),
            const DiscountBanner(),
            const PopularProducts(),
            SizedBox(height: getProportionateScreenWidth(30)),
          ],
        ),
      ),
    );
  }
}
