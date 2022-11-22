// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:fluttericon/typicons_icons.dart';
import 'package:flutter/material.dart';
import 'package:bbarena_app_com/helper/wallet_creation.dart';
import '../../helper/keyboard.dart';
import '../../helper/utils.dart';
import '../../helper/wallet_creation.dart';
import '../../size_config.dart';

class ImportWallet extends StatefulWidget {
  final Function() refreshWallet;
  final Function() popCreateScreen;

  const ImportWallet(
      {Key? key, required this.refreshWallet, required this.popCreateScreen})
      : super(key: key);
  static String routeName = '/importWallet';

  @override
  State<ImportWallet> createState() => _ImportWalletState();
}

class _ImportWalletState extends State<ImportWallet> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController privController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int? selected;
  String? pubAddress;
  String? privAddress;
  String? userPhrase;
  String? userKey;
  String? username;
  bool? isCreated;
  bool isLoading = false;
  bool _switchValue = false;
  bool fecthInitData = true;
  bool revealPhrase = true;
  bool _switchValue2 = false;
  bool isNotValid = false;
  bool _revealKey = true;
  bool isValid = false;
  bool isPhraseEmpty = false;
  final List<String?> errors = [];

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

  FocusNode textSecondFocusNode = FocusNode();

  navigateWallet() async {
    widget.popCreateScreen();
    widget.refreshWallet();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    privController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _onBackPressed() {
      throw navigateWallet();
    }

    return WillPopScope(
      onWillPop: () => _onBackPressed(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black12,
          title: const Center(
            child: Text(
              "Import Wallet",
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
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: buildPrivKeyWidget(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      child: (isPhraseEmpty)
                          ? buildEmptyPhraseWidget()
                          : (isNotValid == true)
                              ? buildInvalidPhraseWidget()
                              : const SizedBox.shrink(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        primary: Colors.black,
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
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 45.0),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.file_download_outlined,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Import',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                      onPressed: (isLoading == true)
                          ? () {}
                          : () async {
                              setState(() {
                                isLoading = true;
                              });
                              if (privController.text.isNotEmpty) {
                                KeyboardUtil.hideKeyboard(context);
                                setState(() {
                                  isValid = bip39
                                      .validateMnemonic(privController.text);
                                });
                              } else {
                                setState(() {
                                  FocusScope.of(context)
                                      .requestFocus(textSecondFocusNode);
                                  isPhraseEmpty = true;
                                  isLoading = false;
                                });
                              }
                              if (isValid) {
                                setState(() {
                                  isNotValid = false;
                                });
                                try {
                                  if (isCreated! == true) {
                                    if (_switchValue == true &&
                                        _switchValue2 == true) {
                                      WalletAddress service = WalletAddress();
                                      final mnemonic = privController.text;
                                      final privateKey =
                                          await service.getPrivateKey(mnemonic);
                                      final publicKey = await service
                                          .getPublicKey(privateKey);
                                      privAddress = privateKey.toString();
                                      pubAddress = publicKey.toString();
                                      await addUserDetails(
                                          privAddress!, pubAddress!, mnemonic);
                                      newFetch();
                                      setState(() {
                                        isLoading = false;
                                        _switchValue2 = false;
                                        _switchValue = false;
                                        privController.text = '';
                                      });
                                      showImportSuccess();
                                      await Future.delayed(
                                          const Duration(milliseconds: 1500));
                                      navigateWallet();
                                    } else {
                                      showTermsAgreAlert();
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  } else {
                                    if (_switchValue == true) {
                                      WalletAddress service = WalletAddress();
                                      final mnemonic = privController.text;
                                      final privateKey =
                                          await service.getPrivateKey(mnemonic);
                                      final publicKey = await service
                                          .getPublicKey(privateKey);
                                      privAddress = privateKey.toString();
                                      pubAddress = publicKey.toString();
                                      await addUserDetails(
                                          privAddress!, pubAddress!, mnemonic);
                                      showImportSuccess();
                                      newFetch();
                                      setState(() {
                                        isLoading = false;
                                        _switchValue2 = false;
                                        _switchValue = false;
                                        privController.text = '';
                                      });
                                      await Future.delayed(
                                          const Duration(milliseconds: 1500));
                                      navigateWallet();
                                    } else {
                                      showTermsAgreAlert();
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  }
                                } catch (e) {}
                              } else {
                                setState(() {
                                  isLoading = false;
                                  isNotValid = true;
                                });
                              }
                            },
                    ),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.transparent, elevation: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.arrow_back_sharp,
                              size: 16,
                              color: Colors.blue,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Go back',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                        onPressed: () {
                          navigateWallet();
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
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

  Container buildEmptyPhraseWidget() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ElevatedButton(
        style:
            ElevatedButton.styleFrom(primary: Colors.transparent, elevation: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(
              height: 12,
            ),
            Text(
              'A seed phrase is required to import wallet!',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            Divider(
              color: Color(0xFFF1F1F1),
            ),
          ],
        ),
        onPressed: () {},
      ),
    );
  }

  Container buildInvalidPhraseWidget() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: const Color(0xFFF1F1F1), elevation: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            ListTile(
              leading: const Text(
                'Invalid seed phrase, please make sure;',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
              trailing: GestureDetector(
                  onTap: () {
                    setState(() {
                      isNotValid = false;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: Icon(
                      Typicons.cancel_circled_outline,
                      color: Colors.grey.shade400,
                      size: 18,
                    ),
                  )),
            ),
            const Divider(
              color: Colors.black,
            ),
            const Text(
              'The words are seperated by single space \nThe words are in the correct order \nThe words are all in lowercase and spelled correctly \nThe words are exactly 12 or 24 in number',
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
        onPressed: () {},
      ),
    );
  }

  TextFormField buildPrivKeyWidget() {
    return TextFormField(
      controller: privController,
      onChanged: (String v) {
        setState(() {
          isNotValid = false;
        });
        if (v.isNotEmpty) {
          setState(() {
            isPhraseEmpty = false;
          });
        }
      },
      focusNode: textSecondFocusNode,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0),
        ),
        hintStyle: const TextStyle(color: Color(0xFFAFAFAF)),
        // labelText: "Password",
        hintText: "enter your mnemonic/recovery seed phrase...",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  showTermsAgreAlert() {
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
          Text('Please agree to the condition(s) before proceeding.'),
        ],
      ),
      duration: const Duration(milliseconds: 1500),
    ));
  }

  showImportSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.black,
      content: Row(
        children: const [
          Icon(
            MfgLabs.ok_circled,
            color: Colors.green,
          ),
          SizedBox(
            width: 10,
          ),
          Text('Wallet has been imported successfully!'),
        ],
      ),
      duration: const Duration(milliseconds: 5000),
    ));
  }
}
