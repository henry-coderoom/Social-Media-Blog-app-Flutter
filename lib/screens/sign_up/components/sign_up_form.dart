import 'package:bbarena_app_com/authServices.dart';
import 'package:bbarena_app_com/screens/login_success/login_success_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bbarena_app_com/helper/keyboard.dart';
import 'package:bbarena_app_com/components/form_error.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/iconic_icons.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../constants.dart';
import '../../../helper/wallet_creation.dart';
import '../../../size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:styled_text/styled_text.dart';

import '../../sign_in/sign_in_screen.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

enum Create { yes, no }

class _SignUpFormState extends State<SignUpForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final tc = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late String firstName;
  late String email;
  late String password;
  late String nameInput;
  late String defaultImage;
  late String pprivateKey;
  late String userPhrase;
  String? confirmPassword;
  String about = '/344*7^*!!@!%??/-=12@';
  DateTime dateJoined = DateTime.now();

  bool remember = false;
  bool isLoading = false;
  bool isChecking = false;
  bool avail = false;
  bool isAvail = false;
  final List<String?> passwordErrors = [];

  final List<String?> usernameerrors = [];
  final List<String?> emailErrors = [];

  bool isGoogleLoading = false;
  bool isBaseLoading = false;
  bool isAppleLoading = false;

  Create _create = Create.no;

  fetchUserImage() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc('defaultUserImage')
        .get()
        .then((ds) {
      defaultImage = ds['defaultImage'];
    }).catchError((e) {
      final snackBar = SnackBar(content: Text(e.toString()));
      Scaffold.of(context).showSnackBar(snackBar);
    });
  }

  void addPasswordError({String? error}) {
    if (!passwordErrors.contains(error)) {
      setState(() {
        passwordErrors.add(error);
      });
    }
  }

  void addEmailError({String? error}) {
    if (!emailErrors.contains(error)) {
      setState(() {
        emailErrors.add(error);
      });
    }
  }

  void addUsernameError({String? error}) {
    if (!usernameerrors.contains(error)) {
      setState(() {
        usernameerrors.add(error);
      });
    }
  }

  void removePasswordError({String? error}) {
    if (passwordErrors.contains(error)) {
      setState(() {
        passwordErrors.remove(error);
      });
    }
  }

  void removeEmailError({String? error}) {
    if (emailErrors.contains(error)) {
      setState(() {
        emailErrors.remove(error);
      });
    }
  }

  void removeUsernameError({String? error}) {
    if (usernameerrors.contains(error)) {
      setState(() {
        usernameerrors.remove(error);
      });
    }
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
          'about': about,
          'uid': user.uid,
          'Email': user.email,
      'isPhoneVerified' : false,
      'isVerified' : false,
          'isAdmin': false,
          'isSuperAdmin': false,
          'password': user.uid,
          'privateKey': privKey,
          'publicKey': pubKey,
          'walletCreated': false,
          'phrase': phrase,
          'dateJoined': dateJoined,
        })
        .then((value) {})
        .catchError((e) {
          if (kDebugMode) {
            print(e);
          }
        });
  }

  @override
  void dispose() {
    tc.dispose();
    super.dispose();
  }

  Future<void> userPrivateKey() async {
    WalletAddress service = WalletAddress();
    final mnemonic = service.generateMnemonic();
    final privateKey = await service.getPrivateKey(mnemonic);
    setState(() {
      pprivateKey = privateKey.toString();
      userPhrase = mnemonic.toString();
    });
  }

  Future<String> userPublicKey() async {
    WalletAddress service = WalletAddress();
    final publicKey = await service.getPublicKey(pprivateKey);
    return publicKey.toString();
  }

  _popSignupPage() async {
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 2);
  }

  @override
  Widget build(BuildContext context) {
    //Firebase Signup Function
    Future<void> storeNewUser(user) async {
      String displayName =
          tc.text.isEmpty ? '/344*7^*!!@!%??/-=13434xxww77+-0@2@' : tc.text;
      String url = defaultImage;
      String privKey = _create == Create.yes ? pprivateKey : '';
      String pubKey = _create == Create.yes ? await userPublicKey() : '';
      String phrase = _create == Create.yes ? userPhrase : '';

      bool isCreated = _create == Create.yes ? true : false;
      await FirebaseFirestore.instance
          .collection("usernames")
          .doc(firstName)
          .set({
            'username': firstName,
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
            'url': url,
            'displayName': displayName,
            'username': firstName,
            'about': about,
            'uid': user.uid,
            'Email': user.email,
        'isPhoneVerified' : false,
        'isVerified' : false,
            'isAdmin': false,
            'isSuperAdmin': false,
            'password': password,
            'privateKey': privKey,
            'publicKey': pubKey,
            'walletCreated': isCreated,
            'phrase': phrase,
            'dateJoined': dateJoined,
          })
          .then((value) {})
          .catchError((e) {
            if (kDebugMode) {
              print(e);
            }
          });
    }

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
              isGoogleLoading = false;
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

            _popSignupPage();
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
            final String? photoUrl = googleUser.photoURL ?? defaultImage;

            await storeNewUserGoogle(googleUser, username!, name!, photoUrl!);
            setState(() {
              isGoogleLoading = false;
            });
            _popSignupPage();
          }
        });
      } else {
        setState(() {
          isGoogleLoading = false;
        });
      }
    }

    Future<void> _signUpFirebase() async {
      if (_create == Create.yes) {
        userPrivateKey();
      }
      try {
        final newUser = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        final baseUser = newUser.user;

        await storeNewUser(baseUser);
        setState(() {
          isBaseLoading = false;
        });

        if (_create == Create.yes) {
          Navigator.pushNamed(context, LoginSuccessScreen.routeName);
        } else {
          _popSignupPage();
        }
      } catch (e) {
        print(e.toString());
        if (e.toString() ==
            '[firebase_auth/email-already-in-use] The email address is already in use by another account.') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 6),
              content: IntrinsicWidth(
                child: Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_rounded,
                        color: Colors.yellow.shade300,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Expanded(
                        child: Text(
                          'The email address you entered is already registered with another user',
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
              duration: const Duration(seconds: 6),
            ),
          );
        }
        setState(() {
          isBaseLoading = false;
        });
      }
    }
    //Firebase signup function ends

    return WillPopScope(
      onWillPop: () => _popSignupPage(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: tc,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              maxLength: 20,
              onChanged: (value) {
                nameInput = value;
              },
              decoration: InputDecoration(
                  counterText: '',
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
                  hintText: "Your Name (Optional)",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  suffixIcon: const Icon(
                    Linecons.user,
                    size: 18,
                    color: Colors.grey,
                  )),
            ),
            SizedBox(height: getProportionateScreenHeight(5)),
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
            buildFirstNameFormField(),
            FormError(errors: usernameerrors),
            SizedBox(height: getProportionateScreenHeight(15)),
            buildEmailFormField(),
            FormError(errors: emailErrors),
            SizedBox(height: getProportionateScreenHeight(15)),
            buildPasswordFormField(),
            FormError(errors: passwordErrors),
            SizedBox(height: getProportionateScreenHeight(15)),
            buildRadioWidget(),
            SizedBox(height: getProportionateScreenHeight(15)),
            SizedBox(height: getProportionateScreenHeight(10)),
            buildButtons(
                'Sign Up',
                const Icon(
                  Icons.person_add,
                  color: Colors.white,
                ), () async {
              if (isBaseLoading == false &&
                  isAppleLoading == false &&
                  isGoogleLoading == false) {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    isBaseLoading = true;
                  });
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
                        isBaseLoading = false;
                      });
                    } else {
                      setState(() {
                        isChecking = false;
                        avail = false;
                        isAvail = true;
                      });
                      await Future.delayed(const Duration(seconds: 1));
                      _signUpFirebase();
                    }
                  });
                } else {}
              }
            }, Colors.transparent, Colors.blueAccent, Colors.white,
                isBaseLoading),
            const SizedBox(
              height: 5,
            ),
            TextButton(
              child: const Center(
                child: Text(
                  'Login instead',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, SignInScreen.routeName);
              },
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
              if (isBaseLoading == false &&
                  isAppleLoading == false &&
                  isGoogleLoading == false) {
                setState(() {
                  isGoogleLoading = true;
                });
                _googleSignIn();
              }
            }, Colors.grey.shade300, Colors.white, Colors.black,
                isGoogleLoading),
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
                isAppleLoading),
          ],
        ),
      ),
    );
  }

  // TextFormField buildDisplayNameFormField() {
  //   return ;
  // }

  TextFormField buildFirstNameFormField() {
    return TextFormField(
      // focusNode: node,
      // controller: tc,
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
          removeUsernameError(error: kNamelNullError);
          removeUsernameError(error: kShortUsernameError);
        }
        return;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addUsernameError(error: kNamelNullError);
          return "";
        } else if (value.length < 3) {
          addUsernameError(error: kShortUsernameError);
          return '';
        } else {
          removeUsernameError(error: kShortUsernameError);
        }
        return null;
      },

      decoration: InputDecoration(
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        counterText: '',
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
        hintText: "Choose a username",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: Row(
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
                      child: const CircularProgressIndicator(
                        color: Colors.green,
                        strokeWidth: 1.5,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  late bool _passwordSee;

  @override
  void initState() {
    fetchUserImage();
    super.initState();
    _passwordSee = false;
  }

  Column buildRadioWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        IntrinsicWidth(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Radio<Create>(
                value: Create.yes,
                groupValue: _create,
                onChanged: (Create? value) {
                  setState(() {
                    _create = value!;
                  });
                },
              ),
              const Expanded(
                  child: Text('Also create new wallet address for me')),
            ],
          ),
        ),
        IntrinsicWidth(
          child: Row(
            children: [
              Radio<Create>(
                value: Create.no,
                groupValue: _create,
                onChanged: (Create? value) {
                  setState(() {
                    _create = value!;
                  });
                },
              ),
              const Expanded(
                  child: Text('I will create or import my wallet later')),
            ],
          ),
        ),
      ],
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: !_passwordSee,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
      ],
      onSaved: (newValue) => password,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removePasswordError(error: kPassNullError);
          removePasswordError(error: kPassNullError);
        }
        password = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addPasswordError(error: kPassNullError);
          return "";
        } else if (value.length < 6) {
          addPasswordError(error: kShortPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        errorMaxLines: null,
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
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
        hintText: "Enter new password",

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
                  color: Colors.black38,
                ),
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
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email,
      textInputAction: TextInputAction.done,
      onChanged: (value) {
        email = value;
        if (value.isNotEmpty) {
          removeEmailError(error: kEmailNullError);
          removeEmailError(error: kInvalidEmailError);
        } else if (emailValidatorRegExp.hasMatch(value)) {
          removeEmailError(error: kInvalidEmailError);
        }
        return;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addEmailError(error: kEmailNullError);
          return "";
        } else if (!emailValidatorRegExp.hasMatch(value)) {
          addEmailError(error: kInvalidEmailError);
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
          Linecons.mail,
          size: 18,
          color: Colors.grey,
        ),
      ),
    );
  }
}

Container buildButtons(String buttonText, Widget leadIcon, Function() function,
    Color borderColor, Color bgColor, Color textColor, bool isLoad) {
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

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
        text: newValue.text.toLowerCase(), selection: newValue.selection);
  }
}
