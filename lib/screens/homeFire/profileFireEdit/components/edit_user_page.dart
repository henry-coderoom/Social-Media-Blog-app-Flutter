import 'dart:async';
import 'package:bbarena_app_com/screens/homeFire/profileFire/profile_screen.dart';
import 'package:bbarena_app_com/screens/homeFire/profileFireEdit/edit_username.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../components/form_error.dart';
import '../../../../constants.dart';
import '../../../../helper/keyboard.dart';
import '../../../../size_config.dart';
import 'dart:io';

class EditUser extends StatefulWidget {
  const EditUser({Key? key}) : super(key: key);

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final _formKey = GlobalKey<FormState>();
  final List<String?> errors = [];
  late String firstName;
  late String displayName;
  late String newAbout;
  late String aboutOld;
  late String displayNameOld;
  bool isLoading = false;

  get username => firstName;
  get about => newAbout;

  var fetch;

  late String url;
  @override
  initState() {
    fetch = newFetch();
    super.initState();
  }

  newFetch() async {
    final firebaseUser = FirebaseAuth.instance.currentUser!;
    if (firebaseUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get()
          .then((ds) {
        url = ds['url'];
        displayNameOld = ds['displayName'];
        aboutOld = ds['about'];
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 6),
          ),
        );
      });
    }
  }

  Future uploadImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemp = File(image.path);

      //Upload to Firebase
      CollectionReference comm = FirebaseFirestore.instance
          .collection('posts')
          .doc()
          .collection('comments');
      if (image != null) {
        setState(() {
          isLoading = true;
        });

        //Uploading the new image to storage
        final firebaseUser = FirebaseAuth.instance.currentUser!;
        final String uids = firebaseUser.uid;
        final Reference storageReference = FirebaseStorage.instance
            .ref()
            .child("userProfileImages/userImages - $uids");
        UploadTask uploadTask = storageReference.putFile(imageTemp);
        String downloadUrl = await (await uploadTask).ref.getDownloadURL();

        //Updating users' document and users comments with the new image
        final CollectionReference users =
            FirebaseFirestore.instance.collection("users");
        final String uid = firebaseUser.uid;
        String url = downloadUrl;
        await users
            .doc(uid)
            .update({'url': url, 'newImage': url}).then((value2) {
          FirebaseFirestore.instance
              .collection('posts')
              .doc()
              .collection('comments')
              .where('uid', isEqualTo: uid)
              .get()
              .then((value) => value.docs.forEach((element) {
                    element.data().update('profilePic', (value) => 'url');
                  }));
        });
        final result = await users.doc(uid).get();
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile Image Updated!'),
            ),
          );
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('No Image Path Received');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text('Choose a new display picture',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.only(left: 30, top: 10, bottom: 15),
                child: const Text('Select from Gallery',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                onPressed: () async {
                  uploadImage();
                  Navigator.pop(context);
                  newFetch();
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.only(
                right: 20,
                bottom: 10,
              ),
              child: const Text(
                "Cancel",
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
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
    saveUserDataDisplayName() async {
      var firebaseUser = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .update({
            'displayName': displayName,
          })
          .then((value) {})
          .catchError((e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
              ),
            );
          });
    }

    saveUserDataAbout() async {
      var firebaseUser = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .update({
            'about': about,
          })
          .then((value) {})
          .catchError((e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
              ),
            );
          });
    }

    //Function called when the 'Save Changes' button is clicked
    Future<void> _saveChanges() async {
      setState(() {
        isLoading = true;
      });
      KeyboardUtil.hideKeyboard(context);
      try {
        saveUserDataDisplayName();
        saveUserDataAbout();
        Navigator.popAndPushNamed(context, ProfileScreenFire.routeName);
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved!'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    }

    // For Navigation when back button is pressed
    Future<bool> _onBackPressed() {
      throw Navigator.popAndPushNamed(context, ProfileScreenFire.routeName);
    }

    return RefreshIndicator(
      strokeWidth: 1,
      color: Colors.black38,
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          fetch = newFetch();
        });
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: WillPopScope(
          onWillPop: () => _onBackPressed(),
          child: Form(
            key: _formKey,
            child: FutureBuilder(
              future: fetch,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        color: Colors.blue,
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: getProportionateScreenWidth(20)),
                      child: Column(
                        children: [
                          const SizedBox(height: 10), // 4%
                          Text("Update Profile", style: headingStyle),
                          const SizedBox(
                            height: 15,
                          ),
                          Wrap(children: const [
                            Text('Upload New Display Picture')
                          ]),
                          const SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 125,
                      width: 125,
                      child: Stack(
                        fit: StackFit.expand,
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(url),
                          ),
                          Positioned(
                            child: SizedBox(
                              height: 125,
                              width: 125,
                              child: GestureDetector(
                                child: Container(
                                  child: (isLoading)
                                      ? const SizedBox(
                                          width: 46,
                                          height: 46,
                                          child: CircularProgressIndicator(
                                            color: Colors.black,
                                            strokeWidth: 1.5,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.add_a_photo_outlined,
                                          size: 38,
                                          color: Colors.white,
                                        ),
                                  decoration: BoxDecoration(
                                    color: const Color(0x76000000),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  // height: 125,
                                  // width: 125,
                                ),
                                onTap: () => _selectImage(context),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    SizedBox(height: getProportionateScreenHeight(10)),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, bottom: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Text(
                            'Update display name',
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    buildDisplayNameFormField(),
                    SizedBox(height: getProportionateScreenHeight(10)),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, bottom: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Text(
                            'Update your bio',
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    buildAboutForm(),
                    SizedBox(height: getProportionateScreenHeight(25)),
                    FormError(errors: errors),
                    GestureDetector(
                      onTap: _saveChanges,
                      child: Container(
                        height: 40,
                        width: 180,
                        decoration: BoxDecoration(
                            color: const Color(0xFF000000),
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
                                        color: Colors.white,
                                        strokeWidth: 1.5,
                                      ),
                                    )
                                  : const Text('Save Changes',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, EditUsername.routename),
                      child: const Text(
                        'Change username',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: SizeConfig.screenHeight * 0.04),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  buildDisplayNameFormField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Center(
        child: TextFormField(
          textCapitalization: TextCapitalization.words,
          maxLength: 20,
          textInputAction: TextInputAction.next,
          onSaved: (newValue) => displayName,
          onChanged: (value) {
            if (value.isNotEmpty) {
              displayName = value;
              removeError(error: kNamelNullError);
            }
            return;
          },
          validator: (value) {
            if (value!.isEmpty) {
              addError(error: kNamelNullError);
            } else if (value.length > 20) {
              return 'The Display Name entered is too long, shouldn\'t be more than 20 characters';
            }
            return null;
          },
          decoration: InputDecoration(
              counterText: "",
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
              hintText:
                  displayNameOld.contains('/344*7^*!!@!%??/-=13434xxww77+-0@2@')
                      ? 'Add a display name'
                      : displayNameOld,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: const Icon(
                Icons.person_outline_rounded,
                color: Colors.grey,
              )),
        ),
      ),
    );
  }

  buildAboutForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Center(
        child: TextFormField(
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          maxLines: 4,
          maxLength: 200,
          onSaved: (newValue) => newAbout,
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
            // labelText: 'Edit About',
            hintText: aboutOld.contains('/344*7^*!!@!%??/-=12@')
                ? 'Describe yourself to the community memebers, you can also mention your social handles for people to connect with you...'
                : aboutOld,
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              newAbout = value;
              removeError(error: kNamelNullError);
            }
            newAbout = about;
          },
          validator: (value) {
            if (value!.isEmpty) {
              return null;
            } else if (value.length > 200) {
              return 'Your description is too long.';
            }
            return null;
          },
        ),
      ),
    );
  }
}
