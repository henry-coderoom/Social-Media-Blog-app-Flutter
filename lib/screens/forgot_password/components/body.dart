import 'package:bbarena_app_com/screens/sign_in/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:bbarena_app_com/components/form_error.dart';
import 'package:bbarena_app_com/size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bbarena_app_com/helper/keyboard.dart';
import 'package:bbarena_app_com/screens/sign_up/sign_up_screen.dart';
import 'package:fluttericon/linecons_icons.dart';

import '../../../constants.dart';

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
          child: Column(
            children: [
              SizedBox(height: SizeConfig.screenHeight * 0.04),
              Text(
                "Reset Password",
                style: TextStyle(
                  fontSize: getProportionateScreenWidth(28),
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Please enter your registered email to receive your \npassword reset link",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.1),
              const ForgotPassForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class ForgotPassForm extends StatefulWidget {
  const ForgotPassForm({Key? key}) : super(key: key);

  @override
  _ForgotPassFormState createState() => _ForgotPassFormState();
}

class _ForgotPassFormState extends State<ForgotPassForm> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  List<String> errors = [];
  late String email;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            onSaved: (newValue) => email,
            onChanged: (value) {
              email = value;
              if (value.isNotEmpty && errors.contains(kEmailNullError)) {
                setState(() {
                  errors.remove(kEmailNullError);
                });
              } else if (emailValidatorRegExp.hasMatch(value) &&
                  errors.contains(kInvalidEmailError)) {
                setState(() {
                  errors.remove(kInvalidEmailError);
                });
              }
              return;
            },
            validator: (value) {
              if (value!.isEmpty && !errors.contains(kEmailNullError)) {
                setState(() {
                  errors.add(kEmailNullError);
                });
              } else if (!emailValidatorRegExp.hasMatch(value) &&
                  !errors.contains(kInvalidEmailError)) {
                setState(() {
                  errors.add(kInvalidEmailError);
                });
              }
              return null;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white70,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFffffff), width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFffffff), width: 1.0),
              ),
              hintStyle: const TextStyle(color: Color(0xFFAFAFAF)),
              // labelText: "Email",
              hintText: "Enter your registered email address",
              // If  you are using latest version of flutter then lable text and hint text shown like this
              // if you r using flutter less then 1.20.* then maybe this is not working properly
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: const Icon(
                Linecons.mail,
                size: 18,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(0)),
          FormError(errors: errors),
          SizedBox(height: SizeConfig.screenHeight * 0.04),
          GestureDetector(
            onTap: () async {
              setState(() {
                isLoading = true;
              });
              if (_formKey.currentState!.validate()) {
                KeyboardUtil.hideKeyboard(context);
                try {
                  await _auth.sendPasswordResetEmail(email: email);
                  const snackBar = SnackBar(
                      content: Text(
                          'Password reset email has been sent, you\'ll now be redirected to back login page.'));
                  Scaffold.of(context).showSnackBar(snackBar);
                  setState(() {
                    isLoading = false;
                  });
                  Future.delayed(const Duration(seconds: 5), () {
                    Navigator.pushNamed(context, SignInScreen.routeName);
                  });
                } catch (authError) {
                  final snackBar =
                      SnackBar(content: Text(authError.toString()));
                  Scaffold.of(context).showSnackBar(snackBar);
                  setState(() {
                    isLoading = false;
                  });
                }
                // if all are valid then go to success screen
              } else {
                setState(() {
                  isLoading = false;
                });
              }
            },
            child: Container(
              height: 46,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: const Color(0xFF000000),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: []),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text(
                  //   'Continue',
                  //   style: TextStyle(color: Colors.white, fontSize: 18),
                  // ),
                  Container(
                    child: (isLoading)
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 1.5,
                            ))
                        : const Text('Continue',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, SignInScreen.routeName);
                },
                child: Text(
                  "Back to Log In ",
                  style: TextStyle(
                      fontSize: getProportionateScreenWidth(16),
                      color: kPrimaryColor),
                ),
              ),
              Text(
                "Or ",
                style: TextStyle(fontSize: getProportionateScreenWidth(16)),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, SignUpScreen.routeName),
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                      fontSize: getProportionateScreenWidth(16),
                      color: kPrimaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
