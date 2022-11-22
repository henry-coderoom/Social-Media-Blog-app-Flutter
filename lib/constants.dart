import 'package:flutter/material.dart';
import 'package:bbarena_app_com/size_config.dart';

const kPrimaryColor = Color(0xFF000000);
const kGoogleColor = Color(0xFF919191);

const kPrimaryLightColor = Color(0xFFFFECDF);
const kAuthScreenBackgroundColors = Color(0xffeaeaea);

const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFFA53E), Color(0xFFFF7643)],
);
const kSecondaryColor = Color(0xFF919191);
const kTextColor = Color(0xFF757575);

const kAnimationDuration = Duration(milliseconds: 200);

final headingStyle = TextStyle(
  fontSize: getProportionateScreenWidth(28),
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

const defaultDuration = Duration(milliseconds: 250);

// Form Error
final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

const String kEmailNullError = "Enter your email address";
const String kInvalidEmailError = "Enter a valid email";
const String kPassNullError = "Choose a password";
const String kShortPassError = "Password should be 6 characters or more";
const String kShortUsernameError =
    "Username must be 3 or more characters, \nincluding numbers, hashtag or other symbols";
const String kMatchPassError = "Passwords didn't match";
const String kNamelNullError = "Choose a username";
const String kNameFeedbackTitleError = "Message title cannot be empty";
const String kNameMessageBodyError = "Message body cannot be empty";
const String kPhoneNumberNullError = "Enter your phone number";
const String kAddressNullError = "Enter your address";

final otpInputDecoration = InputDecoration(
  contentPadding:
      EdgeInsets.symmetric(vertical: getProportionateScreenWidth(15)),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
    borderSide: const BorderSide(color: kTextColor),
  );
}
