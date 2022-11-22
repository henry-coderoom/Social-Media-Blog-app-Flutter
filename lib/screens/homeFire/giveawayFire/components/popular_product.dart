import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bbarena_app_com/components/product_card.dart';
import 'package:bbarena_app_com/models/Product.dart';

import 'package:bbarena_app_com/size_config.dart';

class PopularProducts extends StatelessWidget {
  const PopularProducts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...List.generate(
                demoProducts.length,
                (index) {
                  if (demoProducts[index].isPopular)
                    return ProductCard(product: demoProducts[index]);

                  return SizedBox.shrink();
                  // here by default width and height is 0
                },
              ),
              SizedBox(
                width: getProportionateScreenWidth(20),
              ),
            ],
          ),
        )
      ],
    );
  }
}
