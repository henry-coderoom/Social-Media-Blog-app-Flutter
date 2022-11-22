import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bbarena_app_com/components/form_error.dart';
import 'package:fluttericon/linecons_icons.dart';
import '../../../constants.dart';
import '../../../helper/keyboard.dart';
import '../../../size_config.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({Key? key}) : super(key: key);

  @override
  _ChangePasswordFormState createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String?> errors = [];
  String? newPassword;
  String? confirmPassword;
  bool isLoading = false;

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _changePassword(String? password) async {
      if (_formKey.currentState!.validate()) {
        setState(() {
          isLoading = true;
        });
        _formKey.currentState!.save();
        KeyboardUtil.hideKeyboard(context);
        try {
          final firebaseUser = FirebaseAuth.instance.currentUser!;

          firebaseUser.updatePassword(password!).then((_) {
            FirebaseFirestore.instance
                .collection("users")
                .doc(firebaseUser.uid)
                .update({
              "password": newPassword,
            }).then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Password Updated!'),
                  action: SnackBarAction(
                    label: 'Go Back',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  duration: const Duration(seconds: 10),
                ),
              );
              setState(() {
                isLoading = false;
              });
            });
          }).catchError((error) {
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error " + error.toString()),
              ),
            );
          });
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(15)),
          buildConfirmPassFormField(),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(40)),
          GestureDetector(
            onTap: () {
              _changePassword(newPassword);
            },
            child: Container(
              height: 46,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: const Color(0xFF000000),
                  borderRadius: BorderRadius.circular(15),
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
                            ),
                          )
                        : const Text('Confirm',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextFormField buildConfirmPassFormField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => confirmPassword = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.isNotEmpty && newPassword == confirmPassword) {
          removeError(error: kMatchPassError);
        }
        confirmPassword = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if ((newPassword != value)) {
          addError(error: kMatchPassError);
          return "";
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
          borderSide: const BorderSide(color: Color(0xFFffffff), width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFffffff), width: 1.0),
        ),
        hintStyle: const TextStyle(color: Color(0xFFAFAFAF)),
        // labelText: "Confirm Password",
        hintText: "Re-enter your password",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const Icon(
          Linecons.lock,
          size: 20,
          color: Colors.grey,
        ),
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => newPassword = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 6) {
          removeError(error: kShortPassError);
        }
        newPassword = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if (value.length < 6) {
          addError(error: kShortPassError);
          return "";
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
          borderSide: const BorderSide(color: Color(0xFFffffff), width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFffffff), width: 1.0),
        ),
        hintStyle: const TextStyle(color: Color(0xFFAFAFAF)),
        // labelText: "Password",
        hintText: "Enter new password",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const Icon(
          Linecons.lock,
          size: 20,
          color: Colors.grey,
        ),
      ),
    );
  }
}
