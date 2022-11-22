import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:fluttericon/zocial_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../../../components/form_error.dart';
import '../../../../constants.dart';
import '../../../../helper/keyboard.dart';
import '../../../../size_config.dart';

import '../../../helper/utils.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  Map<String, bool> bookmarks = {};
  final _formKey = GlobalKey<FormState>();
  late String firstName;
  late String messageBody;
  late String title;
  late String email;

  bool remember = false;
  bool isLoading = false;
  final List<String?> errors = [];

  DateTime dateLogged = DateTime.now();

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
    //Firebase Signup Function
    final TextEditingController feedbackEditingController =
        TextEditingController();

    void launchEmailSubmission() async {
      final Uri params = Uri(
          scheme: 'mailto',
          path: 'myOwnEmailAddress@gmail.com',
          queryParameters: {'subject': '', 'body': ''});
      if (await canLaunchUrl(params)) {
        await launchUrl(params);
      } else {
        showSnackBar(context, 'Could not launch', 2, () {}, '');
      }
    }

    _textMe() async {
      // Android
      const uri = 'sms:+39 348 060 888?body=Hi%20BBArena%20team';
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        // iOS
        const uri = 'sms:0039-222-060-888?body=Hi%20BBArena%20team';
        if (await canLaunch(uri)) {
          await launch(uri);
        } else {
          throw 'Could not launch $uri';
        }
      }
    }

    _submitFeedback() async {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        KeyboardUtil.hideKeyboard(context);
        setState(() {
          isLoading = true;
        });
        var firebaseUser = FirebaseAuth.instance.currentUser!;
        String messagId = const Uuid().v1();

        await FirebaseFirestore.instance
            .collection('feedbacks')
            .doc(messagId)
            .set({
              'Sender': firstName,
              'about': messageBody,
              'uid': firebaseUser.uid,
              'title': title,
              'Email': email,
              'dateLogged': dateLogged,
            })
            .then((value) {})
            .catchError((e) {
              if (kDebugMode) {
                print(e);
              }
            });
        setState(() {
          isLoading = false;
        });
        showSnackBar(
            context,
            'Thank you! Your message has been forwarded, we will get back to you as soon as possible.',
            4,
            () {},
            '');
        _formKey.currentState?.reset();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }

    //Firebase signup function ends

    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildFirstNameFormField(),
          SizedBox(height: getProportionateScreenHeight(15)),
          buildEmailFormField(),
          SizedBox(height: getProportionateScreenHeight(15)),
          buildTitleFormField(),
          SizedBox(height: getProportionateScreenHeight(15)),
          buildMessageBodyFormField(),
          SizedBox(height: getProportionateScreenHeight(5)),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(5)),
          GestureDetector(
            onTap: _submitFeedback,
            child: Container(
              height: 46,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: const Color(0xFF898989),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const []),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: (isLoading)
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 1.5,
                            ),
                          )
                        : const Text('Submit',
                            style:
                                TextStyle(color: Colors.black, fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Divider(
            height: 3,
            thickness: 3,
            color: Colors.white54,
          ),
          const SizedBox(
            height: 15,
          ),
          const Text(
            'You can alternatively send us a direct email or SMS, please note that phone calls are not being monitored on the line provided below.',
            // textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: launchEmailSubmission,
            child: Container(
              height: 46,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const []),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Zocial.gmail,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
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
                        : const Text('Send an email',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: _textMe,
            child: Container(
              height: 46,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const []),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Typicons.chat,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
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
                        : const Text('Send SMS',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  TextFormField buildFirstNameFormField() {
    return TextFormField(
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      onSaved: (newValue) => firstName,
      onChanged: (value) {
        if (value.isNotEmpty) {
          firstName = value;
          removeError(error: 'Enter your name');
        }
        return;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: 'Enter your name');
        } else if (value.length > 20) {
          return 'The name entered is too long';
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
        // labelText: "Name or Nickname",
        hintText: "Your contact name...",
        // If  you are using latest version of flutter then label text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const Icon(
          Linecons.user,
          size: 18,
          color: Colors.grey,
        ),
      ),
    );
  }

  TextFormField buildTitleFormField() {
    return TextFormField(
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      maxLength: 80,
      onSaved: (newValue) => title,
      onChanged: (value) {
        if (value.isNotEmpty) {
          title = value;
          removeError(error: kNameFeedbackTitleError);
        }
        return;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kNameFeedbackTitleError);
        } else if (value.length > 80) {
          return 'Please shorten the title';
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
        // labelText: "Name or Nickname",
        hintText: "Title of your message",
        // If  you are using latest version of flutter then label text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  TextFormField buildMessageBodyFormField() {
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.done,
      maxLines: 8,
      maxLength: 1200,
      onSaved: (newValue) => messageBody,
      onChanged: (value) {
        if (value.isNotEmpty) {
          messageBody = value;
          removeError(error: kNameMessageBodyError);
        }
        return;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kNameMessageBodyError);
        } else if (value.length > 1200) {
          return 'Your message body is too long.';
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
        // labelText: "Name or Nickname",
        hintText: "Enter your message...",
        // If  you are using latest version of flutter then label text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email,
      textInputAction: TextInputAction.done,
      onChanged: (value) {
        email = value;
        if (value.isNotEmpty) {
          removeError(error: kEmailNullError);
        } else if (emailValidatorRegExp.hasMatch(value)) {
          removeError(error: kInvalidEmailError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kEmailNullError);
          return "";
        } else if (!emailValidatorRegExp.hasMatch(value)) {
          addError(error: kInvalidEmailError);
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
        // labelText: "Email",
        hintText: "Enter your email address",
        // If  you are using latest version of flutter then label text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const Icon(
          Linecons.mail,
          size: 18,
          color: Colors.grey,
        ),
      ),
    );
  }
}
