import 'dart:typed_data';
import 'package:bbarena_app_com/screens/add_post/add_post_users/add_screen_users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bbarena_app_com/resource/firebase_methods.dart';
import 'package:bbarena_app_com/helper/utils.dart';
import 'package:progress_indicators/progress_indicators.dart';

import '../../../components/form_error.dart';
import '../../../helper/keyboard.dart';
import '../../../size_config.dart';

class AddVideoPostScreenUsers extends StatefulWidget {
  static String routeName = "/addPostVideoUsers";

  const AddVideoPostScreenUsers({Key? key}) : super(key: key);

  @override
  _AddVideoPostScreenUsersState createState() =>
      _AddVideoPostScreenUsersState();
}

class _AddVideoPostScreenUsersState extends State<AddVideoPostScreenUsers> {
  Uint8List? _file2;
  Uint8List? _file3;
  Uint8List? _file4;
  Uint8List? _file5;

  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _videoLinkCtr = TextEditingController();
  final TextEditingController _videoLinkCtr2 = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String url;
  late String username;
  late String userId;

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

  // String selectedValueSection = "Select Section";
  String selectedValueCat = 'Select Category';

  _confirmBack() {
    if (_titleController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty) {
      KeyboardUtil.hideKeyboard(context);
      _confirmDiscard('back');
    } else {
      Navigator.pop(context);
    }
  }

  _switch() {
    Navigator.pop(context);
    Navigator.pushNamed(context, AddPostScreenUser.routeName);
  }

  Future<bool> _confirmDiscard(String id) {
    throw showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              content: const Text('All progress will be lost',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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

  _selectMoreMedia(BuildContext parentContext, int fileN) async {
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
                if (fileN == 1) {
                } else if (fileN == 2) {
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file2 = file;
                  });
                } else if (fileN == 3) {
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file3 = file;
                  });
                } else if (fileN == 4) {
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file4 = file;
                  });
                } else {
                  Uint8List file = await pickImage(ImageSource.gallery);
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
      final String videoLink = _videoLinkCtr.text;
      String media1 = '';
      String media2 = '';
      String media3 = '';
      String media4 = '';
      String media5 = '';

      String postImage = 'postWithVideo';
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
        showSnackBar(context, 'Post submitted!', 2, () {}, '');
        clearMoreMedia(1);
        clearMoreMedia(2);
        setState(() {
          _titleController.text = '';
          _descriptionController.text = '';
          _videoLinkCtr2.text = '';
          _videoLinkCtr.text = '';
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

  void uploadPostWith2Videos(
    String uid,
    String username,
    String profImage,
    String video2,
  ) async {
    try {
      final String videoLink = _videoLinkCtr.text;

      String media2 = '';
      String media3 = '';
      String media4 = '';
      String media5 = '';

      String postImage = 'postWithVideo';
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
        video2,
        media2,
        media3,
        media4,
        media5,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, 'Post submitted!', 2, () {}, '');
        clearMoreMedia(1);
        clearMoreMedia(2);
        setState(() {
          _titleController.text = '';
          _descriptionController.text = '';
          _videoLinkCtr2.text = '';
          _videoLinkCtr.text = '';
        });
      } else {
        showSnackBar(context, res, 3, () {}, '');
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, err.toString(), 3, () {}, '');
    }
  }

  void uploadPostWith1Image(
    String uid,
    String username,
    String profImage,
    String video2,
    String media2,
  ) async {
    try {
      final String videoLink = _videoLinkCtr.text;
      String media3 = '';
      String media4 = '';
      String media5 = '';

      String postImage = 'postWithVideo';
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
        video2,
        media2,
        media3,
        media4,
        media5,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, 'Post submitted!', 2, () {}, '');
        clearMoreMedia(1);
        clearMoreMedia(2);
        setState(() {
          _titleController.text = '';
          _descriptionController.text = '';
          _videoLinkCtr2.text = '';
          _videoLinkCtr.text = '';
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
    String video2,
    String media2,
    String media3,
  ) async {
    try {
      final String videoLink = _videoLinkCtr.text;
      String media4 = '';
      String media5 = '';

      String postImage = 'postWithVideo';
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
        video2,
        media2,
        media3,
        media4,
        media5,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, 'Post submitted!', 2, () {}, '');
        clearMoreMedia(1);
        clearMoreMedia(2);
        setState(() {
          _titleController.text = '';
          _descriptionController.text = '';
          _videoLinkCtr2.text = '';
          _videoLinkCtr.text = '';
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

  void uploadPostWith3Images(
    String uid,
    String username,
    String profImage,
    String video2,
    String media2,
    String media3,
    String media4,
  ) async {
    try {
      final String videoLink = _videoLinkCtr.text;

      String media5 = '';

      String postImage = 'postWithVideo';
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
        video2,
        media2,
        media3,
        media4,
        media5,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, 'Post submitted!', 2, () {}, '');
        clearMoreMedia(1);
        clearMoreMedia(2);
        setState(() {
          _titleController.text = '';
          _descriptionController.text = '';
          _videoLinkCtr2.text = '';
          _videoLinkCtr.text = '';
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
    String video2,
    String media2,
    String media3,
    String media4,
    String media5,
  ) async {
    try {
      final String videoLink = _videoLinkCtr.text;
      String postImage = 'postWithVideo';
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
        video2,
        media2,
        media3,
        media4,
        media5,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, 'Post submitted!', 2, () {}, '');
        clearMoreMedia(1);
        clearMoreMedia(2);
        setState(() {
          _titleController.text = '';
          _descriptionController.text = '';
          _videoLinkCtr2.text = '';
          _videoLinkCtr.text = '';
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

  void clearMoreMedia(int fileN) {
    if (fileN == 1) {
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
    _videoLinkCtr.dispose();
    _videoLinkCtr2.dispose();
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
                      if (_formKey.currentState!.validate() &&
                          _videoLinkCtr.text.isNotEmpty) {
                        setState(() {
                          isLoading = true;
                        });
                        if (_videoLinkCtr2.text.isEmpty && _file2 == null) {
                          uploadPost(
                            userId,
                            username,
                            url,
                          );
                        } else if (_videoLinkCtr2.text.isNotEmpty &&
                            _file2 == null) {
                          final String video2Link = _videoLinkCtr2.text;
                          uploadPostWith2Videos(
                              userId, username, url, video2Link);
                        } else if (_file2 != null && _file3 == null) {
                          if (_videoLinkCtr2.text.isNotEmpty) {
                            final String video2Link = _videoLinkCtr2.text;

                            UploadTask upload2 = FirebaseStorage.instance
                                .ref()
                                .child(
                                    "userPostImages/${_titleController.text} - media2")
                                .putData(_file2!);
                            String media2 =
                                await (await upload2).ref.getDownloadURL();
                            uploadPostWith1Image(
                                userId, username, url, video2Link, media2);
                          }
                          UploadTask upload2 = FirebaseStorage.instance
                              .ref()
                              .child(
                                  "userPostImages/${_titleController.text} - media2")
                              .putData(_file2!);

                          String media2 =
                              await (await upload2).ref.getDownloadURL();
                          String video2Link = '';
                          uploadPostWith1Image(
                              userId, username, url, video2Link, media2);
                        } else if (_file3 != null && _file4 == null) {
                          if (_videoLinkCtr2.text.isNotEmpty) {
                            final String video2Link = _videoLinkCtr2.text;

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
                            String media2 =
                                await (await upload2).ref.getDownloadURL();
                            String media3 =
                                await (await upload3).ref.getDownloadURL();
                            uploadPostWith2Images(userId, username, url,
                                video2Link, media2, media3);
                          }
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

                          String media2 =
                              await (await upload2).ref.getDownloadURL();
                          String media3 =
                              await (await upload3).ref.getDownloadURL();
                          String video2Link = '';
                          uploadPostWith2Images(userId, username, url,
                              video2Link, media2, media3);
                        } else if (_file4 != null && _file5 == null) {
                          if (_videoLinkCtr2.text.isNotEmpty) {
                            final String video2Link = _videoLinkCtr2.text;

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
                            String media2 =
                                await (await upload2).ref.getDownloadURL();
                            String media3 =
                                await (await upload3).ref.getDownloadURL();
                            String media4 =
                                await (await upload4).ref.getDownloadURL();
                            uploadPostWith3Images(userId, username, url,
                                video2Link, media2, media3, media4);
                          }
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

                          String media2 =
                              await (await upload2).ref.getDownloadURL();
                          String media3 =
                              await (await upload3).ref.getDownloadURL();
                          String media4 =
                              await (await upload4).ref.getDownloadURL();
                          String video2Link = '';
                          uploadPostWith3Images(userId, username, url,
                              video2Link, media2, media3, media4);
                        } else if (_file5 != null) {
                          if (_videoLinkCtr2.text.isNotEmpty) {
                            final String video2Link = _videoLinkCtr2.text;

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
                            String media2 =
                                await (await upload2).ref.getDownloadURL();
                            String media3 =
                                await (await upload3).ref.getDownloadURL();
                            String media4 =
                                await (await upload4).ref.getDownloadURL();
                            String media5 =
                                await (await upload5).ref.getDownloadURL();
                            uploadPostWith4Images(userId, username, url,
                                video2Link, media2, media3, media4, media5);
                          }
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

                          String media2 =
                              await (await upload2).ref.getDownloadURL();
                          String media3 =
                              await (await upload3).ref.getDownloadURL();
                          String media4 =
                              await (await upload4).ref.getDownloadURL();
                          String media5 =
                              await (await upload5).ref.getDownloadURL();
                          String video2Link = '';

                          uploadPostWith4Images(userId, username, url,
                              video2Link, media2, media3, media4, media5);
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
                          'Posting...',
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
            child: Column(
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
                              onPressed: () {
                                if (_titleController.text.isNotEmpty ||
                                    _descriptionController.text.isNotEmpty) {
                                  KeyboardUtil.hideKeyboard(context);
                                  _confirmDiscard('switch');
                                } else {
                                  _switch();
                                }
                              },
                              child: const Text(
                                'Post with photos',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
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
                              onPressed: () {},
                              child: const Text(
                                'Post with videos',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                FutureBuilder(
                  future: fetch,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return JumpingDotsProgressIndicator(
                        fontSize: 30,
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
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
                              maxLength: 150,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(),
                StreamBuilder<QuerySnapshot>(
                    stream: streamCat,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 4.0),
                                              child: ClipRRect(
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
                        hintStyle: const TextStyle(color: Color(0x43000000)),
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
                  width: SizeConfig.screenWidth * 0.8,
                  child: TextFormField(
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.none,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        removeError(
                            error: 'A video link is required for video posts');
                      } else {}
                      return;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        addError(
                            error: 'A video link is required for video posts');
                        return "";
                      } else if (value.length > 60) {
                        addError(error: 'kShortUsernameError');
                        return '';
                      } else {
                        removeError(error: 'kShortUsernameError');
                      }
                      return null;
                    },
                    controller: _videoLinkCtr,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: "(required) paste video link...",
                      hintStyle: const TextStyle(color: Color(0x43000000)),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: getProportionateScreenWidth(20),
                          vertical: getProportionateScreenWidth(9)),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                const Divider(),
                const Divider(),
                SizedBox(
                  width: SizeConfig.screenWidth * 0.8,
                  child: TextFormField(
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.none,
                    controller: _videoLinkCtr2,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: "(optional) paste second video link...",
                      hintStyle: const TextStyle(color: Color(0x43000000)),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: getProportionateScreenWidth(20),
                          vertical: getProportionateScreenWidth(9)),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                const Divider(),
                const Text(
                  'You can add images (optional)',
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
                      const Divider(),
                      SizedBox(
                        child: _file2 == null
                            ? Center(
                                child: IconButton(
                                  icon: const Icon(
                                    Entypo.picture,
                                  ),
                                  onPressed: () => _selectMoreMedia(context, 2),
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
                                      image: MemoryImage(_file2!),
                                    )),
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        clearMoreMedia(2);
                                      },
                                      child: const Text('Remove'))
                                ],
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
                                            Icons.add_circle_outline_outlined,
                                          ),
                                          onPressed: () =>
                                              _selectMoreMedia(context, 3),
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
                                              alignment:
                                                  FractionalOffset.topCenter,
                                              image: MemoryImage(_file3!),
                                            )),
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                clearMoreMedia(3);
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
                                            Icons.add_circle_outline_outlined,
                                          ),
                                          onPressed: () =>
                                              _selectMoreMedia(context, 4),
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
                                              alignment:
                                                  FractionalOffset.topCenter,
                                              image: MemoryImage(_file4!),
                                            )),
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                clearMoreMedia(4);
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
                                            Icons.add_circle_outline_outlined,
                                          ),
                                          onPressed: () =>
                                              _selectMoreMedia(context, 5),
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
                                              alignment:
                                                  FractionalOffset.topCenter,
                                              image: MemoryImage(_file5!),
                                            )),
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                clearMoreMedia(5);
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
                  height: 200,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
