import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bbarena_app_com/components/form_error.dart';
import 'package:bbarena_app_com/helper/keyboard.dart';
import 'package:bbarena_app_com/screens/forgot_password/forgot_password_screen.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../authServices.dart';
import '../../../constants.dart';
import '../../../size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignForm extends StatefulWidget {
  const SignForm({Key? key}) : super(key: key);

  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  late String email;
  late String password;
  bool? remember = false;
  late String _defaultImage;
  bool isLoading = false;
  final List<String?> errors = [];
  final String _about = '/344*7^*!!@!%??/-=12@';
  final DateTime _dateJoined = DateTime.now();
  bool _isGoogleLoading = false;
  bool _isBaseLoading = false;
  final bool _isAppleLoading = false;
  final TextEditingController _passFormController = TextEditingController();
  final TextEditingController _emailFormController = TextEditingController();

  @override
  initState() {
    fetchUserImage();
    _passwordSee = false;
    super.initState();
  }

  Future<void> storeNewUserGoogle(
      User user, String username, String name, String photoUrl) async {
    String privKey = '';
    String pubKey = '';
    String phrase = '';
    await FirebaseFirestore.instance
        .collection("usernames")
        .doc(username)
        .set({
          'username': username,
          'uid': user.uid,
        })
        .then((value) {})
        .catchError((e) {
          if (kDebugMode) {
            print(e);
          }
        });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
          'newImage': '!@!@',
          'url': photoUrl,
          'displayName': name,
          'username': username,
          'about': _about,
          'uid': user.uid,
          'Email': user.email,
          'isPhoneVerified': false,
          'isVerified': false,
          'isAdmin': false,
          'isSuperAdmin': false,
          'password': user.uid,
          'privateKey': privKey,
          'publicKey': pubKey,
          'walletCreated': false,
          'phrase': phrase,
          'dateJoined': _dateJoined,
        })
        .then((value) {})
        .catchError((e) {
          if (kDebugMode) {
            print(e);
          }
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

  fetchUserImage() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc('defaultUserImage')
        .get()
        .then((ds) {
      _defaultImage = ds['defaultImage'];
    }).catchError((e) {
      final snackBar = SnackBar(content: Text(e.toString()));
      Scaffold.of(context).showSnackBar(snackBar);
    });
  }

  _popLoginPage() async {
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 1);
  }

  Color loginButtonBG = Colors.blue.shade200;

  Future<void> _googleSignIn() async {
    final googleUser = await AuthServices.signInWithGoogle(context: context);
    if (googleUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(googleUser.uid)
          .get()
          .then((doc) async {
        if (doc.exists) {
          setState(() {
            _isGoogleLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Success!'),
                ],
              ),
            ),
          );
          int count = 0;
          Navigator.of(context).popUntil((_) => count++ >= 3);
        } else {
          final String num = const Uuid().v1();
          final String trimmed = num.substring(0, num.length - 32);
          final String? googleUserEmail = googleUser.email;
          final nameToCheck =
              googleUserEmail?.substring(0, googleUserEmail.length - 10);
          final bool isNameAvail = await FirebaseFirestore.instance
              .collection('usernames')
              .doc(nameToCheck)
              .get()
              .then((doc) {
            return doc.exists;
          });
          final String? username =
              (isNameAvail == false) ? nameToCheck : nameToCheck! + trimmed;
          final String? name = googleUser.displayName;
          final String? photoUrl = googleUser.photoURL ?? _defaultImage;

          await storeNewUserGoogle(googleUser, username!, name!, photoUrl!);
          setState(() {
            _isGoogleLoading = false;
          });
          int count = 0;
          Navigator.of(context).popUntil((_) => count++ >= 3);
        }
      });
    } else {
      setState(() {
        _isGoogleLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailFormController.dispose();
    _passFormController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _popLoginPage(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildButtons(
                'Continue With Google',
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: SvgPicture.asset(
                    'assets/icons/google-icon.svg',
                    height: 20,
                    width: 20,
                  ),
                ), () async {
              if (_isBaseLoading == false &&
                  _isAppleLoading == false &&
                  _isGoogleLoading == false) {
                setState(() {
                  _isGoogleLoading = true;
                });
                _googleSignIn();
              }
            }, Colors.grey.shade300, Colors.white, Colors.black,
                _isGoogleLoading),
            const SizedBox(
              height: 0,
            ),
            buildButtons(
                'Continue With Apple ID',
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: SvgPicture.asset(
                    'assets/icons/apple_logo.svg',
                    color: Colors.black,
                    height: 22,
                    width: 22,
                  ),
                ), () async {
              // if (isBaseLoading == false &&
              //     isAppleLoading == false &&
              //     isGoogleLoading == false) {
              //   setState(() {
              //     isAppleLoading = true;
              //   });
              //   _googleSignIn();
              // }
            }, Colors.grey.shade300, Colors.white, Colors.black,
                _isAppleLoading),
            const SizedBox(
              height: 10,
            ),
            const Center(
              child: Text(
                'OR',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            buildEmailFormField(),
            SizedBox(height: getProportionateScreenHeight(15)),
            buildPasswordFormField(),
            FormError(errors: errors),
            SizedBox(height: getProportionateScreenHeight(20)),
            buildButtons(
                'Login',
                const Icon(
                  Icons.login_sharp,
                  color: Colors.white,
                ), () async {
              if (_passFormController.text.isNotEmpty &&
                  _emailFormController.text.isNotEmpty) {
                if (_isBaseLoading == false &&
                    _isAppleLoading == false &&
                    _isGoogleLoading == false) {
                  setState(() {
                    _isBaseLoading = true;
                  });
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    setState(() {
                      isLoading = true;
                    });
                    KeyboardUtil.hideKeyboard(context);
                    try {
                      await _auth.signInWithEmailAndPassword(
                          email: email, password: password);
                      final loggedUser = FirebaseAuth.instance.currentUser?.uid;
                      if (loggedUser != null) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(loggedUser)
                            .update({'password': password});
                      }
                      Navigator.pop(context);
                      Navigator.pop(context);
                    } catch (e) {
                      if (e.toString() ==
                          '[firebase_auth/wrong-password] The password is invalid or the user does not have a password.') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 6),
                            content: IntrinsicWidth(
                              child: Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person_add_disabled_outlined,
                                      color: Colors.yellow.shade700,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Expanded(
                                      child: Text(
                                        'The password you entered is not correct. Click on "Forgot password" to reset your password if this persists',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if (e.toString() ==
                          '[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 5),
                            content: IntrinsicWidth(
                              child: Expanded(
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.person_add_disabled_outlined,
                                      color: Colors.yellow,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Text(
                                        'There is no account registered with the email address you entered.',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                          ),
                        );
                      }
                      setState(() {
                        _isBaseLoading = false;
                      });
                    }
                    // if all are valid then go to success screen
                  } else {
                    setState(() {
                      _isBaseLoading = false;
                    });
                  }
                }
              } else {}
            }, Colors.transparent, loginButtonBG, Colors.white, _isBaseLoading),
            IntrinsicWidth(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    value: remember,
                    activeColor: kPrimaryColor,
                    onChanged: (value) {
                      setState(() {
                        remember = value;
                      });
                    },
                  ),
                  const Expanded(child: Text("Remember me")),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, ForgotPasswordScreen.routeName),
                      child: const Expanded(
                        child: Text(
                          "Forgot Password",
                          style:
                              TextStyle(decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  late bool _passwordSee;

  TextFormField buildPasswordFormField() {
    return TextFormField(
      controller: _passFormController,
      obscureText: !_passwordSee,
      textInputAction: TextInputAction.done,
      onSaved: (newValue) => password,
      onChanged: (value) {
        setState(() {
          loginButtonBG = Colors.blue.shade200;
        });
        if (value.isNotEmpty) {
          password = value;
          if (value.isNotEmpty && _emailFormController.text.isNotEmpty) {
            setState(() {
              loginButtonBG = Colors.blue;
            });
          } else if (value.isEmpty || _emailFormController.text.isEmpty) {
            loginButtonBG = Colors.blue.shade200;
            setState(() {
              loginButtonBG = Colors.blue.shade200;
            });
          }
        } else if (value.length >= 6) {}
        return;
      },
      decoration: InputDecoration(
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        errorMaxLines: null,
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
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
        hintText: "Enter your password",
        // If  you are using latest version of flutter then label text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: SizedBox(
          width: 90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _passwordSee = !_passwordSee;
                  });
                },
                icon: Icon(
                    _passwordSee ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black38),
              ),
              const Icon(
                Linecons.lock,
                size: 20,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      controller: _emailFormController,
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email,
      textInputAction: TextInputAction.next,
      onChanged: (value) {
        setState(() {
          loginButtonBG = Colors.blue.shade200;
        });
        if (value.isNotEmpty) {
          removeError(error: kEmailNullError);
          removeError(error: kInvalidEmailError);
          email = value;
          if (value.isNotEmpty && _passFormController.text.isNotEmpty) {
            setState(() {
              loginButtonBG = Colors.blue;
            });
          } else if (value.isEmpty || _passFormController.text.isEmpty) {
            loginButtonBG = Colors.blue.shade200;
            setState(() {
              loginButtonBG = Colors.blue.shade200;
            });
          }
        } else if (emailValidatorRegExp.hasMatch(value)) {
          removeError(error: kInvalidEmailError);
        }
        return;
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
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        errorMaxLines: null,
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
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
        hintText: "Enter your email",
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

  Container buildButtons(
      String buttonText,
      Widget leadIcon,
      Function() function,
      Color borderColor,
      Color bgColor,
      Color textColor,
      bool isLoad) {
    return Container(
      margin: const EdgeInsets.only(top: 0, bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 0,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: bgColor,
          side: BorderSide(color: borderColor),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
        ),

        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            dense: true,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            leading: (isLoad == true)
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.grey.shade400,
                      strokeWidth: 1.5,
                    ),
                  )
                : leadIcon,
            title: Center(
              child: (isLoad)
                  ? Text(
                      'Processing...',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w800),
                    )
                  : Text(
                      buttonText,
                      style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                          fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ),
        onPressed: () {
          function();
        },
        //exit the app
      ),
    );
  }
}
