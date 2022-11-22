// ignore_for_file: file_names

import 'package:bbarena_app_com/components/modal_box.dart';
import 'package:bbarena_app_com/screens/wallet_screens/import_wallet_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:bbarena_app_com/helper/wallet_creation.dart';
import 'package:flutter/services.dart';
import '../../helper/utils.dart';
import '../../size_config.dart';
import '../white_screen.dart';

class CreateWallet extends StatefulWidget {
  const CreateWallet({
    Key? key,
    required this.refreshWallet,
  }) : super(key: key);
  static String routeName = '/createWallet';
  final Function() refreshWallet;

  @override
  State<CreateWallet> createState() => _CreateWallet();
}

class _CreateWallet extends State<CreateWallet> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int? selected;
  String? pubAddress;
  String? privAddress;
  String? userPhrase;
  String? username;
  bool? isCreated;
  bool isNewCreated = false;

  bool isLoading = false;
  bool _switchValue = false;
  bool fecthInitData = true;
  bool revealPhrase = true;
  bool _switchValue2 = false;

  @override
  void initState() {
    super.initState();
    newFetch();
  }

  newFetch() async {
    final firebaseUser = _auth.currentUser!;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get()
        .then((ds) {
      username = ds['username'];
      privAddress = ds['privateKey'];
      userPhrase = ds['phrase'];
      pubAddress = ds['publicKey'];
      isCreated = ds['walletCreated'];
    }).catchError((e) {
      showSnackBar(context, e.toString(), 2, () {}, '');
    });
    setState(() {
      fecthInitData = false;
    });
  }

  navigate() {
    widget.refreshWallet();
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _onBackPressed() {
      throw navigate();
    }

    return WillPopScope(
      onWillPop: () => _onBackPressed(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black12,
          title: const Center(
            child: Text(
              "Create New Wallet",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        body: (fecthInitData)
            ? const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                    strokeWidth: 1.5,
                  ),
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    SizedBox(height: getProportionateScreenHeight(60)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        children: [
                          Switch(
                            value: _switchValue,
                            onChanged: (value) {
                              setState(() {
                                _switchValue = value;
                              });
                            },
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          const Expanded(
                            child: Text(
                                'By continuing, you agree to our privacy poliy and terms.'),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: (isCreated!)
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30.0),
                              child: Row(
                                children: [
                                  Switch(
                                    value: _switchValue2,
                                    onChanged: (value) {
                                      setState(() {
                                        _switchValue2 = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  const Expanded(
                                    child: Text(
                                        'I have saved or backed-up my Private Key and Recovery Phrase for the current wallet address so I can import it later'),
                                  )
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                        child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        primary: Colors.lightBlue,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                      ),
                      child: (isLoading)
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 1.5,
                              ),
                            )
                          : Wrap(
                              alignment: WrapAlignment.center,
                              children: const [
                                Icon(Icons.add),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  'Create new wallet',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                      onPressed: (isLoading)
                          ? () {}
                          : () async {
                              setState(() {
                                isLoading = true;
                              });
                              if (isCreated!) {
                                if (_switchValue == true &&
                                    _switchValue2 == true) {
                                  WalletAddress service = WalletAddress();
                                  final mnemonic = service.generateMnemonic();
                                  final privateKey =
                                      await service.getPrivateKey(mnemonic);
                                  final publicKey =
                                      await service.getPublicKey(privateKey);
                                  privAddress = privateKey.toString();
                                  pubAddress = publicKey.toString();
                                  await addUserDetails(
                                      privAddress!, pubAddress!, mnemonic);
                                  newFetch();
                                  setState(() {
                                    isLoading = false;
                                    _switchValue2 = false;
                                    _switchValue = false;
                                    isNewCreated = true;
                                  });
                                  _modalBoxWalletCreate(context);
                                } else {
                                  showAgreeToast();
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              } else {
                                if (_switchValue == true) {
                                  WalletAddress service = WalletAddress();
                                  final mnemonic = service.generateMnemonic();
                                  final privateKey =
                                      await service.getPrivateKey(mnemonic);
                                  final publicKey =
                                      await service.getPublicKey(privateKey);
                                  privAddress = privateKey.toString();
                                  pubAddress = publicKey.toString();
                                  await addUserDetails(
                                      privAddress!, pubAddress!, mnemonic);
                                  newFetch();
                                  _modalBoxWalletCreate(context);
                                  setState(() {
                                    isLoading = false;
                                    _switchValue2 = false;
                                    _switchValue = false;
                                    isNewCreated = true;
                                  });
                                } else {
                                  showAgreeToast();
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                            },
                    )),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.transparent, elevation: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.file_download_outlined,
                              color: Colors.blue,
                              size: 20,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              'Import wallet',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImportWallet(
                                  refreshWallet: () {
                                    navigate();
                                  },
                                  popCreateScreen: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                ),
                              ));
                        },
                        //exit the app
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Column(
                      children: (isNewCreated)
                          ? [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'New Wallet Details',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  GestureDetector(
                                    child: SizedBox(
                                      child: (revealPhrase)
                                          ? Row(
                                              children: const [
                                                Text(
                                                  'Hide',
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                ),
                                                SizedBox(
                                                  width: 2,
                                                ),
                                                Icon(
                                                  Icons.visibility_off_outlined,
                                                  color: Colors.blue,
                                                  size: 16,
                                                )
                                              ],
                                            )
                                          : Row(
                                              children: const [
                                                Text(
                                                  'Show',
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                ),
                                                SizedBox(
                                                  width: 2,
                                                ),
                                                Icon(
                                                  Icons.visibility_outlined,
                                                  color: Colors.blue,
                                                  size: 16,
                                                )
                                              ],
                                            ),
                                    ),
                                    onTap: (revealPhrase)
                                        ? () {
                                            setState(() {
                                              revealPhrase = false;
                                            });
                                          }
                                        : () {
                                            setState(() {
                                              revealPhrase = true;
                                            });
                                          },
                                    //exit the app
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: (revealPhrase)
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin:
                                                    const EdgeInsets.all(10),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          primary: const Color(
                                                              0xFFF1F1F1),
                                                          elevation: 0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      const Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    20.0),
                                                        child: Text(
                                                          "Mnemonic Seed Phrase",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Text(
                                                        '$userPhrase',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      Center(
                                                        child: QrImage(
                                                          data: userPhrase!,
                                                          size: 150.0,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      const Divider(
                                                        color: Colors.black,
                                                      ),
                                                      const SizedBox(
                                                        height: 8,
                                                      ),
                                                      const Center(
                                                        child: Icon(
                                                          Icons.copy_all_sharp,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      const Center(
                                                        child: Text(
                                                          'Copy to clipboard',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                    ],
                                                  ),
                                                  onPressed: () async {
                                                    await Clipboard.setData(
                                                        ClipboardData(
                                                            text: userPhrase));
                                                    showTextCopied(
                                                        'Recovery phrase Copied!');
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10.0),
                                                child: Expanded(
                                                  child: Text(
                                                    "Be sure to copy and securely save your Seed Phrase and Private Key, you'll need them to recover your wallet. Do not disclose your Private Key or Seed Phrase, anybody with any of these information can transfer your tokens",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color:
                                                          Colors.red.shade500,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Divider(),
                                              Container(
                                                margin:
                                                    const EdgeInsets.all(10),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          primary: const Color(
                                                              0xFFF1F1F1),
                                                          elevation: 0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      const Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    20.0),
                                                        child: Text(
                                                          "Wallet Private Key",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Text(
                                                        '$privAddress',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      const Divider(
                                                        color: Colors.black,
                                                      ),
                                                      const SizedBox(
                                                        height: 8,
                                                      ),
                                                      const Center(
                                                        child: Icon(
                                                          Icons.copy_all_sharp,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      const Center(
                                                        child: Text(
                                                          'Copy to clipboard',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                    ],
                                                  ),
                                                  onPressed: () async {
                                                    await Clipboard.setData(
                                                        ClipboardData(
                                                            text: privAddress));
                                                    showTextCopied(
                                                        'Private Key Copied!');
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                  Center(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.transparent,
                                          elevation: 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.arrow_back_sharp,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            'Back to wallet',
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                        ],
                                      ),
                                      onPressed: () {
                                        navigate();
                                      },
                                      //exit the app
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              )
                            ]
                          : [const SizedBox.shrink()],
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> addUserDetails(
      String privateKey, String publicKey, String phrase) async {
    var firebaseUser = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .update({
          'privateKey': privateKey,
          'phrase': phrase,
          'publicKey': publicKey,
          'walletCreated': true,
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

  SingleChildScrollView buildWalletCreated() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -15),
              blurRadius: 20,
              color: const Color(0xFF747474).withOpacity(0.15),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
          maxWidth: MediaQuery.of(context).size.width,
          minHeight: 100.0, //min height you want to take by container
          maxHeight: 400.0, //max height you want to take by container
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              MfgLabs.ok_circled,
              size: 50,
              color: Colors.green,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'New wallet created successfully! Don\'t forget to save your seed phrase in order to be able access the wallet anywhere.',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Close',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ))
          ],
        ),
      ),
    );
  }

  showAgreeToast() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.black,
      content: Row(
        children: const [
          Icon(
            MfgLabs.attention_alt,
            color: Colors.red,
          ),
          SizedBox(
            width: 10,
          ),
          Text('Agree to the conditions before proceeding.'),
        ],
      ),
      duration: const Duration(milliseconds: 1500),
    ));
  }

  void _modalBoxWalletCreate(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x88000000),
      context: context,
      builder: (context) {
        return ModalBox(
          refresh: () {},
          modalWidget: buildWalletCreated(),
        );
      },
    );
  }

  void showTextCopied(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.blue,
      content: Row(
        children: [
          const Icon(
            Icons.copy_sharp,
            color: Colors.white,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(text),
        ],
      ),
      duration: const Duration(milliseconds: 1500),
    ));
  }
}
