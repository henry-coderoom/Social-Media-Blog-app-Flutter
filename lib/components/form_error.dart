import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../size_config.dart';

class FormError extends StatelessWidget {
  const FormError({
    Key? key,
    required this.errors,
  }) : super(key: key);

  final List<String?> errors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
          errors.length, (index) => formErrorText(error: errors[index]!)),
    );
  }

  ListTile formErrorText({required String error}) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -4),
      leading: SvgPicture.asset(
        "assets/icons/Error.svg",
        height: getProportionateScreenWidth(14),
        width: getProportionateScreenWidth(14),
      ),
      title: Text(
        error,
      ),
    );
  }
}
