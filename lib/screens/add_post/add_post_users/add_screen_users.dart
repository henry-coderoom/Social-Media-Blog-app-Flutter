import 'dart:typed_data';
import 'package:bbarena_app_com/screens/add_post/add_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bbarena_app_com/resource/firebase_methods.dart';
import 'package:bbarena_app_com/helper/utils.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:uuid/uuid.dart';

import 'package:bbarena_app_com/components/form_error.dart';
import 'package:bbarena_app_com/helper/keyboard.dart';

import '../../../size_config.dart';
import 'add_post_video_users.dart';

class AddPostScreenUser extends StatefulWidget {
  static String routeName = "/addPostUsers";

  const AddPostScreenUser({Key? key}) : super(key: key);

  @override
  _AddPostScreenUserState createState() => _AddPostScreenUserState();
}

class _AddPostScreenUserState extends State<AddPostScreenUser> {
  Uint8List? _file;
  Uint8List? _file1;
  Uint8List? _file2;
  Uint8List? _file3;
  Uint8List? _file4;
  Uint8List? _file5;

  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String url;
  late String username;
  late String userId;
  late bool isAdmin;

  var fetch;

  @override
  void initState() {
    fetch = newFetch();
    super.initState();
    streamCat = streamCate();
  }

  final List<String?> errors = [];
  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  var streamCat;

  Stream<QuerySnapshot> streamCate() {
    return FirebaseFirestore.instance
        .collection('categories')
        .orderBy('num', descending: false)
        .snapshots();
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  newFetch() async {
    final firebaseUser = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get()
        .then((ds) {
      url = ds['url'];
      username = ds['username'];
      userId = ds['uid'];
      isAdmin = ds['isAdmin'];
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  var focusNode = FocusNode();

  String selectedValueCat = 'Select Category';

  _switch() {
    Navigator.pop(context);
    Navigator.pushNamed(context, AddVideoPostScreenUsers.routeName);
  }

  _confirmBack() {
    if (_titleController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty) {
      KeyboardUtil.hideKeyboard(context);
      _confirmDiscard('back');
    } else {
      Navigator.pop(context);
    }
  }

  Future<bool> _confirmDiscard(String id) {
    throw showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              content: const Text(
                'All progress will be lost',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.transparent, elevation: 0),
                  child: const Text(
                    'Keep editing',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  //exit the app
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.transparent, elevation: 0),
                  child: const Text('Discard',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  onPressed: (id == 'switch')
                      ? () {
                          Navigator.pop(context);
                          _switch();
                        }
                      : () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                )
              ],
            ));
  }

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text('Add photo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          children: <Widget>[
            SimpleDialogOption(
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 10, bottom: 15),
              child: const Text('Choose photo or GIF from gallery',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              onPressed: () async {
                Navigator.pop(context);
                Uint8List file = await pickImage(ImageSource.gallery);
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.only(
                right: 40,
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

  _selectMoreImage(BuildContext parentContext, int fileN) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text('Add more',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          children: <Widget>[
            SimpleDialogOption(
              padding: const EdgeInsets.only(left: 30, top: 10, bottom: 15),
              child: const Text('Choose more media',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              onPressed: () async {
                Navigator.pop(context);
                Uint8List file = await pickImage(ImageSource.gallery);
                if (fileN == 1) {
                  setState(() {
                    _file1 = file;
                  });
                } else if (fileN == 2) {
                  setState(() {
                    _file2 = file;
                  });
                } else if (fileN == 3) {
                  setState(() {
                    _file3 = file;
                  });
                } else if (fileN == 4) {
                  setState(() {
                    _file4 = file;
                  });
                } else {
                  setState(() {
                    _file5 = file;
                  });
                }
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.only(
                right: 40,
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

  void uploadPost(
    String uid,
    String username,
    String profImage,
  ) async {
    try {
      final String imageId = const Uuid().v1();
      final String imageTitle = _titleController.text;
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child("userPostImages/$imageTitle - mainImage - $imageId");
      UploadTask uploadTask = storageReference.putData(_file!);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      final String postImage = downloadUrl;

      String media1 = '';
      String media2 = '';
      String media3 = '';
      String media4 = '';
      String media5 = '';

      String videoLink = 'with';
      String description = _descriptionController.text.isEmpty
          ? ''
          : _descriptionController.text;
      String res = await FireStoreMethods().uploadPostUser(
        _titleController.text,
        description,
        uid,
        username,
        profImage,
        postImage,
        videoLink,
        selectedValueCat,
        media1,
        media2,
        media3,
        media4,
        media5,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, 'Post published!', 2, () {}, '');
        clearImage();
        clearMoreImage(1);
        setState(() {
          _titleController.text = '';
          _descriptionController.text = '';
        });
      } else {
        showSnackBar(context, res, 3, () {}, '');
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void uploadPostWith2Images(
    String uid,
    String username,
    String profImage,
    String media1,
  ) async {
    try {
      final String imageId = const Uuid().v1();
      final String imageTitle = _titleController.text;
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child("userPostImages/$imageTitle - mainImage - $imageId");
      UploadTask uploadTask = storageReference.putData(_file!);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      final String postImage = downloadUrl;
      String media2 = '';
      String media3 = '';
      String media4 = '';
      String media5 = '';

      String videoLink = 'with';
      String description = _descriptionController.text.isEmpty
          ? ''
          : _descriptionController.text;
      String res = await FireStoreMethods().uploadPostUser(
        _titleController.text,
        description,
        uid,
        username,
        profImage,
        postImage,
        videoLink,
        selectedValueCat,
        media1,
        media2,
        media3,
        media4,
        media5,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, 'Post published!', 2, () {}, '');
        clearImage();
        clearMoreImage(1);
        setState(() {
          _titleController.text = '';
          _descriptionController.text = '';
        });
      } else {
        showSnackBar(context, res, 3, () {}, '');
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      // showSnackBar(
      //   context,
      //   err.toString(),
      // );
    }
  }

  void uploadPostWith3Images(
    String uid,
    String username,
    String profImage,
    String media1,
    String media2,
  ) async {
    try {
      final String imageId = const Uuid().v1();
      final String imageTitle = _titleController.text;
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child("userPostImages/$imageTitle - mainImage - $imageId");
      UploadTask uploadTask = storageReference.putData(_file!);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      final String postImage = downloadUrl;
      String media3 = '';
      String media4 = '';
      String media5 = '';

      String videoLink = 'with';
      String description = _descriptionController.text.isEmpty
          ? ''
          : _descriptionController.text;
      String res = await FireStoreMethods().uploadPostUser(
        _titleController.text,
        description,
        uid,
        username,
        profImage,
        postImage,
        videoLink,
        selectedValueCat,
        media1,
        media2,
        media3,
        media4,
        media5,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, 'Post published!', 2, () {}, '');
        clearImage();
        clearMoreImage(1);
        setState(() {
          _titleController.text = '';
          _descriptionController.text = '';
        });
      } else {
        showSnackBar(context, res, 3, () {}, '');
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void uploadPostWith4Images(
    String uid,
    String username,
    String profImage,
    String media1,
    String media2,
    String media3,
  ) async {
    try {
      final String imageId = const Uuid().v1();
      final String imageTitle = _titleController.text;
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child("userPostImages/$imageTitle - mainImage - $imageId");
      UploadTask uploadTask = storageReference.putData(_file!);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      final String postImage = downloadUrl;
      String media4 = '';
      String media5 = '';

      String videoLink = 'with';
      String description = _descriptionController.text.isEmpty
          ? ''
          : _descriptionController.text;
      String res = await FireStoreMethods().uploadPostUser(
        _titleController.text,
        description,
        uid,
        username,
        profImage,
        postImage,
        videoLink,
        selectedValueCat,
        media1,
        media2,
        media3,
        media4,
        media5,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, 'Post published!', 2, () {}, '');
        clearImage();
        clearMoreImage(1);
        setState(() {
          _titleController.text = '';
          _descriptionController.text = '';
        });
      } else {
        showSnackBar(context, res, 3, () {}, '');
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void uploadPostWith5Images(
    String uid,
    String username,
    String profImage,
    String media1,
    String media2,
    String media3,
    String media4,
  ) async {
    try {
      final String imageId = const Uuid().v1();
      final String imageTitle = _titleController.text;
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child("userPostImages/$imageTitle - mainImage - $imageId");
      UploadTask uploadTask = storageReference.putData(_file!);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      final String postImage = downloadUrl;
      String media5 = '';

      String videoLink = 'with';
      String description = _descriptionController.text.isEmpty
          ? ''
          : _descriptionController.text;
      String res = await FireStoreMethods().uploadPostUser(
        _titleController.text,
        description,
        uid,
        username,
        profImage,
        postImage,
        videoLink,
        selectedValueCat,
        media1,
        media2,
        media3,
        media4,
        media5,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, 'Post published!', 2, () {}, '');
        clearImage();
        clearMoreImage(1);
        setState(() {
          _titleController.text = '';
          _descriptionController.text = '';
        });
      } else {
        showSnackBar(context, res, 3, () {}, '');
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void uploadPostWith6Images(
    String uid,
    String username,
    String profImage,
    String media1,
    String media2,
    String media3,
    String media4,
    String media5,
  ) async {
    try {
      final String imageId = const Uuid().v1();
      final String imageTitle = _titleController.text;
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child("userPostImages/$imageTitle - mainImage - $imageId");
      UploadTask uploadTask = storageReference.putData(_file!);
      String downloadUrl = await (await uploadTask).ref.getDownloadURL();
      final String postImage = downloadUrl;
      String videoLink = 'with';
      String description = _descriptionController.text.isEmpty
          ? ''
          : _descriptionController.text;
      String res = await FireStoreMethods().uploadPostUser(
        _titleController.text,
        description,
        uid,
        username,
        profImage,
        postImage,
        videoLink,
        selectedValueCat,
        media1,
        media2,
        media3,
        media4,
        media5,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, 'Post published!', 2, () {}, '');
        clearImage();
        clearMoreImage(1);
        setState(() {
          _titleController.text = '';
          _descriptionController.text = '';
        });
      } else {
        showSnackBar(context, res, 3, () {}, '');
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  void clearMoreImage(int fileN) {
    if (fileN == 1) {
      setState(() {
        _file1 = null;
        _file2 = null;
        _file3 = null;
        _file4 = null;
        _file5 = null;
      });
    } else if (fileN == 2) {
      setState(() {
        _file2 = null;
        _file3 = null;
        _file4 = null;
        _file5 = null;
      });
    } else if (fileN == 3) {
      setState(() {
        _file3 = null;
        _file4 = null;
        _file5 = null;
      });
    } else if (fileN == 4) {
      setState(() {
        _file4 = null;
        _file5 = null;
      });
    } else {
      setState(() {
        _file5 = null;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _confirmBack(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFE0E0E0),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _confirmBack();
            },
          ),
          title: const Text(
            'Create new post',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          actions: <Widget>[
            TextButton(
              onPressed: isLoading
                  ? () {}
                  : () async {
                      if (_formKey.currentState!.validate() && _file != null) {
                        setState(() {
                          isLoading = true;
                        });
                        if (_file1 == null) {
                          uploadPost(
                            userId,
                            username,
                            url,
                          );
                        } else if (_file2 == null) {
                          UploadTask upload1 = FirebaseStorage.instance
                              .ref()
                              .child(
                                  "userPostImages/${_titleController.text} - media1")
                              .putData(_file1!);
                          String media1 =
                              await (await upload1).ref.getDownloadURL();
                          uploadPostWith2Images(userId, username, url, media1);
                        } else if (_file3 == null) {
                          UploadTask upload1 = FirebaseStorage.instance
                              .ref()
                              .child(
                                  "userPostImages/${_titleController.text} - media1")
                              .putData(_file1!);
                          UploadTask upload2 = FirebaseStorage.instance
                              .ref()
                              .child(
                                  "userPostImages/${_titleController.text} - media2")
                              .putData(_file2!);
                          String media1 =
                              await (await upload1).ref.getDownloadURL();
                          String media2 =
                              await (await upload2).ref.getDownloadURL();
                          uploadPostWith3Images(
                              userId, username, url, media1, media2);
                        } else if (_file4 == null) {
                          UploadTask upload1 = FirebaseStorage.instance
                              .ref()
                              .child(
                                  "userPostImages/${_titleController.text} - media1")
                              .putData(_file1!);
                          UploadTask upload2 = FirebaseStorage.instance
                              .ref()
                              .child(
                                  "userPostImages/${_titleController.text} - media2")
                              .putData(_file2!);
                          UploadTask upload3 = FirebaseStorage.instance
                              .ref()
                              .child(
                                  "userPostImages/${_titleController.text} - media3")
                              .putData(_file3!);
                          String media1 =
                              await (await upload1).ref.getDownloadURL();
                          String media2 =
                              await (await upload2).ref.getDownloadURL();
                          String media3 =
                              await (await upload3).ref.getDownloadURL();
                          uploadPostWith4Images(
                              userId, username, url, media1, media2, media3);
                        } else if (_file5 == null) {
                          UploadTask upload1 = FirebaseStorage.instance
                              .ref()
                              .child(
                                  "userPostImages/${_titleController.text} - media1")
                              .putData(_file1!);
                          UploadTask upload2 = FirebaseStorage.instance
                              .ref()
                              .child(
                                  "userPostImages/${_titleController.text} - media2")
                              .putData(_file2!);
                          UploadTask upload3 = FirebaseStorage.instance
                              .ref()
                              .child(
                                  "userPostImages/${_titleController.text} - media3")
                              .putData(_file3!);
                          UploadTask upload4 = FirebaseStorage.instance
                              .ref()
                              .child(
                                  "userPostImages/${_titleController.text} - media4")
                              .putData(_file4!);
                          String media1 =
                              await (await upload1).ref.getDownloadURL();
                          String media2 =
                              await (await upload2).ref.getDownloadURL();
                          String media3 =
                              await (await upload3).ref.getDownloadURL();
                          String media4 =
                              await (await upload4).ref.getDownloadURL();

                          uploadPostWith5Images(userId, username, url, media1,
                              media2, media3, media4);
                        } else {
                          UploadTask upload1 = FirebaseStorage.instance
                              .ref()
                              .child(
                                  "userPostImages/${_titleController.text} - media1")
                              .putData(_file1!);
                          UploadTask upload2 = FirebaseStorage.instance
                              .ref()
                              .child(
                                  "userPostImages/${_titleController.text} - media2")
                              .putData(_file2!);
                          UploadTask upload3 = FirebaseStorage.instance
                              .ref()
                              .child(
                                  "userPostImages/${_titleController.text} - media3")
                              .putData(_file3!);
                          UploadTask upload4 = FirebaseStorage.instance
                              .ref()
                              .child(
                                  "userPostImages/${_titleController.text} - media4")
                              .putData(_file4!);
                          UploadTask upload5 = FirebaseStorage.instance
                              .ref()
                              .child(
                                  "userPostImages/${_titleController.text} - media5")
                              .putData(_file5!);
                          String media1 =
                              await (await upload1).ref.getDownloadURL();
                          String media2 =
                              await (await upload2).ref.getDownloadURL();
                          String media3 =
                              await (await upload3).ref.getDownloadURL();
                          String media4 =
                              await (await upload4).ref.getDownloadURL();
                          String media5 =
                              await (await upload5).ref.getDownloadURL();

                          uploadPostWith6Images(userId, username, url, media1,
                              media2, media3, media4, media5);
                        }
                      } else {
                        setState(() {
                          isLoading = false;
                        });
                        showSnackBar(
                            context, 'Check all required fields', 2, () {}, '');
                      }
                    },
              child: isLoading
                  ? Row(
                      children: const [
                        SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator()),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Uploading...',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0),
                        )
                      ],
                    )
                  : const Text(
                      "Post",
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                    ),
            )
          ],
        ),
        // POST FORM
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Form(
            key: _formKey,
            child: FutureBuilder(
              future: fetch,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return JumpingDotsProgressIndicator(
                    fontSize: 30,
                  );
                }
                return Column(
                  children: <Widget>[
                    IntrinsicWidth(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.only(
                                      top: 10,
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Text(
                                    'Post with photos',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  )),
                            ),
                            const SizedBox(
                              width: 50,
                            ),
                            Expanded(
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.only(
                                      top: 10,
                                    ),
                                  ),
                                  onPressed: () {
                                    if (_titleController.text.isNotEmpty ||
                                        _descriptionController
                                            .text.isNotEmpty) {
                                      KeyboardUtil.hideKeyboard(context);
                                      _confirmDiscard('switch');
                                    } else {
                                      _switch();
                                    }
                                  },
                                  child: const Text(
                                    'Post with videos',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              url,
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              textInputAction: TextInputAction.done,
                              textCapitalization: TextCapitalization.sentences,
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  removeError(
                                      error:
                                          'Title is required for creating new post');
                                } else {}
                                return;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  addError(
                                      error:
                                          'Title is required for creating new post');
                                  return "";
                                } else if (value.length > 150) {
                                  addError(error: 'kShortUsernameError');
                                  return '';
                                } else {
                                  removeError(error: 'kShortUsernameError');
                                }
                                return null;
                              },
                              controller: _titleController,
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: "Title...",
                                hintStyle:
                                    const TextStyle(color: Color(0x43000000)),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: getProportionateScreenWidth(20),
                                    vertical: getProportionateScreenWidth(9)),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                              ),
                              maxLength: 60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    StreamBuilder<QuerySnapshot>(
                        stream: streamCat,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: DropdownButtonFormField(
                              value: selectedValueCat,
                              decoration: InputDecoration(
                                focusedBorder: InputBorder.none,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.white, width: 2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.white, width: 2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                filled: true,
                                fillColor: const Color(0x08000000),
                              ),
                              validator: (value) {
                                if (value == "Select Category") {
                                  addError(error: 'Select a category');
                                  return "";
                                }
                                return null;
                              },
                              dropdownColor: Colors.white,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedValueCat = newValue.toString();
                                });
                                if (newValue != "Select Category") {
                                  removeError(error: 'Select a category');
                                } else {}
                              },
                              items: snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                return DropdownMenuItem<String>(
                                    value: document['category'],
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          child: document['catUrl']
                                                  .contains('noImage')
                                              ? const SizedBox.shrink()
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  child: Image.network(
                                                    document['catUrl'],
                                                    height: 30,
                                                    width: 30,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                        ),
                                        Text(document['category'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ));
                              }).toList(),
                            ),
                          );
                        }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: FormError(errors: errors),
                    ),
                    const Divider(),
                    SizedBox(
                      width: SizeConfig.screenWidth * 0.8,
                      child: RawKeyboardListener(
                        focusNode: focusNode,
                        onKey: (event) {
                          if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                            const newText = '<br></br>';
                            final updatedText =
                                _descriptionController.text + newText;
                            _descriptionController.value =
                                _descriptionController.value.copyWith(
                              text: updatedText,
                              selection: TextSelection.collapsed(
                                  offset: updatedText.length),
                            );
                          }
                        },
                        child: TextField(
                          maxLength: 4950,
                          textInputAction: TextInputAction.newline,
                          textCapitalization: TextCapitalization.sentences,
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: "(Optional) Write a description...",
                            hintStyle:
                                const TextStyle(color: Color(0x43000000)),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: getProportionateScreenWidth(20),
                                vertical: getProportionateScreenWidth(9)),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          ),
                          maxLines: 8,
                        ),
                      ),
                    ),
                    const Divider(),
                    SizedBox(
                      child: _file == null
                          ? Center(
                              child: Column(
                                children: [
                                  const Text(
                                    'Select post image (required)',
                                    style: TextStyle(
                                      color: Color(0x43000000),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.upload,
                                    ),
                                    onPressed: () => _selectImage(context),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                Container(
                                  height: 150,
                                  width: 150,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                    fit: BoxFit.fill,
                                    alignment: FractionalOffset.topCenter,
                                    image: MemoryImage(_file!),
                                  )),
                                ),
                                TextButton(
                                    onPressed: () {
                                      clearImage();
                                      setState(() {});
                                    },
                                    child: const Text('Remove'))
                              ],
                            ),
                    ),
                    const Divider(),
                    const Text(
                      'Add more images (optional)',
                      style: TextStyle(
                        color: Color(0x43000000),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: _file1 == null
                                ? Center(
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline_outlined,
                                      ),
                                      onPressed: () {
                                        if (_file != null) {
                                          _selectMoreImage(context, 1);
                                        } else {
                                          showSnackBar(
                                              context,
                                              'Select post image first.',
                                              3,
                                              () {},
                                              '');
                                        }
                                      },
                                    ),
                                  )
                                : Column(
                                    children: [
                                      Container(
                                        height: 50.0,
                                        width: 50.0,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                          fit: BoxFit.fill,
                                          alignment: FractionalOffset.topCenter,
                                          image: MemoryImage(_file1!),
                                        )),
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            clearMoreImage(1);
                                          },
                                          child: const Text('Remove'))
                                    ],
                                  ),
                          ),
                          const Divider(),
                          SizedBox(
                            child: _file1 == null
                                ? const SizedBox.shrink()
                                : SizedBox(
                                    child: _file2 == null
                                        ? Center(
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons
                                                    .add_circle_outline_outlined,
                                              ),
                                              onPressed: () =>
                                                  _selectMoreImage(context, 2),
                                            ),
                                          )
                                        : Column(
                                            children: [
                                              Container(
                                                height: 50.0,
                                                width: 50.0,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                  fit: BoxFit.fill,
                                                  alignment: FractionalOffset
                                                      .topCenter,
                                                  image: MemoryImage(_file2!),
                                                )),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    clearMoreImage(2);
                                                  },
                                                  child: const Text('Remove'))
                                            ],
                                          ),
                                  ),
                          ),
                          const Divider(),
                          SizedBox(
                            child: _file2 == null
                                ? const SizedBox.shrink()
                                : SizedBox(
                                    child: _file3 == null
                                        ? Center(
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons
                                                    .add_circle_outline_outlined,
                                              ),
                                              onPressed: () =>
                                                  _selectMoreImage(context, 3),
                                            ),
                                          )
                                        : Column(
                                            children: [
                                              Container(
                                                height: 50.0,
                                                width: 50.0,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                  fit: BoxFit.fill,
                                                  alignment: FractionalOffset
                                                      .topCenter,
                                                  image: MemoryImage(_file3!),
                                                )),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    clearMoreImage(3);
                                                  },
                                                  child: const Text('Remove'))
                                            ],
                                          ),
                                  ),
                          ),
                          const Divider(),
                          SizedBox(
                            child: _file3 == null
                                ? const SizedBox.shrink()
                                : SizedBox(
                                    child: _file4 == null
                                        ? Center(
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons
                                                    .add_circle_outline_outlined,
                                              ),
                                              onPressed: () =>
                                                  _selectMoreImage(context, 4),
                                            ),
                                          )
                                        : Column(
                                            children: [
                                              Container(
                                                height: 50.0,
                                                width: 50.0,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                  fit: BoxFit.fill,
                                                  alignment: FractionalOffset
                                                      .topCenter,
                                                  image: MemoryImage(_file4!),
                                                )),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    clearMoreImage(4);
                                                  },
                                                  child: const Text('Remove'))
                                            ],
                                          ),
                                  ),
                          ),
                          const Divider(),
                          SizedBox(
                            child: _file4 == null
                                ? const SizedBox.shrink()
                                : SizedBox(
                                    child: _file5 == null
                                        ? Center(
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons
                                                    .add_circle_outline_outlined,
                                              ),
                                              onPressed: () =>
                                                  _selectMoreImage(context, 5),
                                            ),
                                          )
                                        : Column(
                                            children: [
                                              Container(
                                                height: 50.0,
                                                width: 50.0,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                  fit: BoxFit.fill,
                                                  alignment: FractionalOffset
                                                      .topCenter,
                                                  image: MemoryImage(_file5!),
                                                )),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    clearMoreImage(5);
                                                  },
                                                  child: const Text('Remove'))
                                            ],
                                          ),
                                  ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    TextButton(
                        onPressed: (isAdmin)
                            ? () {
                                Navigator.pushNamed(
                                    context, AddPostScreen.routeName);
                              }
                            : () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Row(
                                    children: const [
                                      Icon(
                                        MfgLabs.attention_alt,
                                        color: Colors.red,
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text('Only Admin Access.'),
                                    ],
                                  ),
                                  duration: const Duration(seconds: 2),
                                ));
                              },
                        child: const Text(
                          'isAdmin?',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    const SizedBox(
                      height: 100,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
