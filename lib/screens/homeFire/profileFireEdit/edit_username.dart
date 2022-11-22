import 'package:bbarena_app_com/screens/homeFire/profileFireEdit/editUser_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/iconic_icons.dart';
import 'package:fluttericon/typicons_icons.dart';

import '../../../components/form_error.dart';
import '../../../constants.dart';
import '../../../helper/keyboard.dart';
import '../../../helper/utils.dart';
import '../../../resource/firebase_methods.dart';
import '../../sign_up/components/sign_up_form.dart';

class EditUsername extends StatefulWidget {
  const EditUsername({Key? key}) : super(key: key);

  static String routename = '/editUsername';

  @override
  State<EditUsername> createState() => _EditUsernameState();
}

class _EditUsernameState extends State<EditUsername> {
  final _formKey = GlobalKey<FormState>();
  final List<String?> errors = [];
  var fetch;
  late String username;
  late String firstName;
  bool avail = false;
  bool isChecking = false;
  bool isAvail = false;
  bool isLoading = false;

  final tc = TextEditingController();

  @override
  void initState() {
    fetch = fetchUser();
    super.initState();
  }

  @override
  void dispose() {
    tc.dispose();
    super.dispose();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  fetchUser() async {
    final firebaseUser = _auth.currentUser!;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get()
        .then((ds) {
      username = ds['username'];
    }).catchError((e) {
      final snackBar = SnackBar(content: Text(e.toString()));
      Scaffold.of(context).showSnackBar(snackBar);
    });
  }

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
    _updateUsername() async {
      setState(() {
        isLoading = true;
      });
      var firebaseUser = FirebaseAuth.instance.currentUser!;
      await FireStoreMethods().deleteUsername(username);
      await FirebaseFirestore.instance
          .collection("usernames")
          .doc(firstName)
          .set({
            'username': firstName,
            'uid': firebaseUser.uid,
          })
          .then((value) {})
          .catchError((e) {
            if (kDebugMode) {
              print(e);
            }
          });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .update({
            'username': firstName,
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
      showSnackBar(context, 'Username has been updated', 3, () {
        Navigator.pushNamed(context, EditUserScreenFire.routeName);
      }, 'Go Back');
      await Future.delayed(const Duration(seconds: 3));
      Navigator.pushNamed(context, EditUserScreenFire.routeName);

      //TODO ALSO UPDATE COMMENT DOCUMENTS WHERE THE USER COMMENT
    }

    return Scaffold(
      backgroundColor: const Color(0xffcbcbcb),
      appBar: AppBar(
        title: const Text(''),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Form(
            key: _formKey,
            child: FutureBuilder(
              future: fetch,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                      color: Colors.blue,
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 90),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Choose a new username',
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        child: tc.text == username
                            ? const Text(
                                'This is your current username so it\'s... taken!',
                                textAlign: TextAlign.right,
                              )
                            : const SizedBox.shrink(),
                      ),
                      SizedBox(
                        child: avail == true
                            ? const Text(
                                'This username is already taken ):',
                                textAlign: TextAlign.right,
                              )
                            : const SizedBox.shrink(),
                      ),
                      SizedBox(
                        child: isChecking == true
                            ? const Text(
                                'checking username availability...',
                                textAlign: TextAlign.right,
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: tc,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          LowerCaseTextFormatter(),
                        ],
                        textInputAction: TextInputAction.next,
                        maxLength: 15,
                        onSaved: (newValue) => firstName,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            firstName = value;
                            removeError(error: kNamelNullError);
                          }
                          return;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            addError(error: kNamelNullError);
                            return "";
                          } else if (value.length < 3) {
                            addError(error: kShortUsernameError);
                            return '';
                          } else {
                            removeError(error: kShortUsernameError);
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white70,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 13, vertical: 13),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFFffffff), width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFFffffff), width: 1.0),
                          ),
                          hintStyle: const TextStyle(color: Color(0xFFAFAFAF)),
                          // labelText: "Name or Nickname",
                          hintText: username,
                          // If  you are using latest version of flutter then label text and hint text shown like this
                          // if you r using flutter less then 1.20.* then maybe this is not working properly
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    child: isAvail == true
                                        ? const Icon(
                                            Entypo.check,
                                            size: 18,
                                            color: Colors.green,
                                          )
                                        : const SizedBox.shrink()),
                                const SizedBox(
                                  width: 5,
                                ),
                                Container(
                                    child: avail == true
                                        ? const Icon(
                                            Typicons.cancel_circled_outline,
                                            size: 18,
                                            color: Colors.red,
                                          )
                                        : const SizedBox.shrink()),
                                const SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: isChecking == false
                                      ? const Icon(
                                          Iconic.at,
                                          size: 18,
                                          color: Colors.grey,
                                        )
                                      : Container(
                                          margin: const EdgeInsets.all(18),
                                          height: 10,
                                          width: 10,
                                          child:
                                              const CircularProgressIndicator(
                                            color: Colors.green,
                                            strokeWidth: 1.5,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      FormError(errors: errors),
                      const SizedBox(
                        height: 20,
                      ),
                      TextButton(
                        onPressed: () async {
                          setState(() {
                            avail = false;
                            isAvail = false;
                          });
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            KeyboardUtil.hideKeyboard(context);
                            setState(() {
                              isChecking = true;
                              avail = false;
                              isAvail = false;
                            });
                            await FirebaseFirestore.instance
                                .collection('usernames')
                                .doc(firstName)
                                .get()
                                .then((doc) async {
                              if (doc.exists) {
                                setState(() {
                                  isChecking = false;
                                  avail = true;
                                });
                              } else {
                                setState(() {
                                  isChecking = false;
                                  avail = false;
                                  isAvail = true;
                                });
                                await Future.delayed(
                                    const Duration(seconds: 1));
                                _updateUsername();
                              }
                            });
                          } else {}
                        },
                        child: isLoading == true
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.blue,
                                  strokeWidth: 1.5,
                                ),
                              )
                            : const Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
