// ignore_for_file: file_names
import 'package:bbarena_app_com/components/modal_box.dart';
import 'package:bbarena_app_com/screens/wallet_screens/import_wallet_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bbarena_app_com/screens/wallet_screens/create_wallet.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttericon/zocial_icons.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:http/http.dart';
import 'package:flutter/services.dart';
import '../../components/auth_options_container.dart';
import '../../helper/utils.dart';
import '../white_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with AutomaticKeepAliveClientMixin<WalletScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Client httpClient;
  late web3.Web3Client ethClient;
  String privAddress = "";
  web3.EthereumAddress targetAddress = web3.EthereumAddress.fromHex(
      "0xfed0d2b05602d8b3b0fe5b7eb80f124ee98013cd");
  int? balance;
  var fetchForModal;
  var credentials;
  bool isFirstVal = true;
  bool? isCreated;
  bool isLoadingBal = true;
  String? pubAddress;
  String? profPic;
  String? username;
  int myAmount = 5;
  bool isLoading = false;
  bool? loggedInUser;

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = web3.Web3Client(
        "https://rinkeby.infura.io/v3/4c98357a2edc4fce82379fe98baa9f97",
        httpClient);
    details();
    fetchForModal = details();
    FirebaseAuth.instance.authStateChanges().listen((loggedUser) {
      if (loggedUser != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(loggedUser.uid)
            .get()
            .then((doc) {
          if (doc.exists) {
            details();
            fetchForModal = details();
            setState(() {});
          } else {
            Future.delayed(const Duration(milliseconds: 1000)).then((value) {
              details();
              fetchForModal = details();
              setState(() {});
            });
          }
        });
      } else {
        details();
        fetchForModal = details();
        setState(() {});
      }
    });
  }

  resetUserWallet() async {
    setState(() {
      isLoading = true;
    });
    var firebaseUser = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .update({
          'phrase': '',
          'privateKey': '',
          'publicKey': '',
          'walletCreated': false,
        })
        .then((value) {})
        .catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
            ),
          );
        });
    details();
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context);
  }

  details() async {
    if (FirebaseAuth.instance.currentUser != null) {
      final firebaseUser = _auth.currentUser!;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get()
          .then((ds) {
        username = ds['username'];
        profPic = ds['url'];
        privAddress = ds['privateKey'];
        pubAddress = ds['publicKey'];
        isCreated = ds['walletCreated'];
      }).catchError((e) {
        showSnackBar(context, e.toString(), 2, () {}, '');
      });
      setState(() {
        isFirstVal = false;
        loggedInUser = true;
      });
      var temp = web3.EthPrivateKey.fromHex(privAddress);
      credentials = temp.address;
      balance = await getBalance(credentials);
    } else {
      setState(() {
        isFirstVal = false;
        loggedInUser = false;
      });
    }
  }

  void _showModalAuthOptions(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x88000000),
      context: context,
      builder: (context) {
        return ModalBox(
          refresh: () {},
          modalWidget: AuthOptionsContainer(
            leadingText:
                'Securely store and watch your crypto assets and also access other wallet features, sign up or sign in below.',
            topIcon: Icon(
              Zocial.bitcoin,
              size: 40,
              color: Colors.teal.shade900,
            ),
            refresh: () {},
          ),
        );
      },
    );
  }

  void _modalBoxReset(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x88000000),
      context: context,
      builder: (context) {
        return ModalBox(
          refresh: () {},
          modalWidget: buildResetModalAlert(),
        );
      },
    );
  }

  void _modalBoxAddWallet(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x88000000),
      context: context,
      builder: (context) {
        return ModalBox(
          refresh: () {
            details();
          },
          modalWidget: buildAddWalletModal(),
        );
      },
    );
  }

  Future<web3.DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi/abi.json");
    String contractAddress = "0x4a151003126f41c5cb23e31f5f29da05676e9cae";
    final contract = web3.DeployedContract(
        web3.ContractAbi.fromJson(abi, "Gold"),
        web3.EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<int> getBalance(web3.EthereumAddress credentialAddress) async {
    List<dynamic> result = await query("balanceOf", [credentialAddress]);
    var data = result[0];
    setState(() {
      isLoadingBal = false;
    });
    return data;
  }

  Future<String> sendCoin() async {
    var bigAmount = BigInt.from(myAmount);
    var response = await submit("transfer", [targetAddress, bigAmount]);
    return response;
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    web3.DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    web3.EthPrivateKey key = web3.EthPrivateKey.fromHex(privAddress);
    web3.Transaction transaction = web3.Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: args,
        maxGas: 100000);
    print(transaction.nonce);
    final result =
        await ethClient.sendTransaction(key, transaction, chainId: 4);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return (isFirstVal)
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
        : Center(
            child: (loggedInUser!)
                ? Center(
                    child: (isCreated!)
                        ? ListView(
                            children: [
                              Container(
                                color: Colors.blue[600],
                                height: 150,
                                alignment: Alignment.center,
                                child: Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        image: DecorationImage(
                                            image: NetworkImage(profPic!),
                                            scale: 0.1))),
                              ),
                              Container(
                                margin: const EdgeInsets.all(20),
                                child: Text(
                                  username!,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(5),
                                alignment: Alignment.center,
                                height: 100,
                                width: MediaQuery.of(context).size.width,
                                // color: Colors.black,
                                child: const Text(
                                  "Balance",
                                  style: TextStyle(
                                      fontSize: 70,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(5),
                                alignment: Alignment.center,
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                // color: Colors.black,
                                child: Center(
                                  child: (isLoadingBal)
                                      ? const SizedBox(
                                          width: 25,
                                          height: 25,
                                          child: CircularProgressIndicator(
                                            color: Colors.blue,
                                            strokeWidth: 1.5,
                                          ),
                                        )
                                      : Text(
                                          balance == null
                                              ? "0 GLD"
                                              : "$balance GLD",
                                          style: const TextStyle(
                                              fontSize: 50,
                                              color: Colors.blueAccent,
                                              fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                              Container(
                                  margin: const EdgeInsets.all(20),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      var response = await sendCoin();
                                      print(response);
                                    },
                                    child: const Text("Send Money"),
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.green)),
                                  )),
                              Container(
                                  margin: const EdgeInsets.all(20),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _modalBoxReset(context);
                                    },
                                    child: const Text("Reset Wallet"),
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.red)),
                                  )),
                              Container(
                                  margin: const EdgeInsets.all(10),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      credentials != null
                                          ? getBalance(credentials)
                                          : print("credentials null");
                                    },
                                    child: const Text("Refresh Page"),
                                  )),
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 30, right: 30),
                                alignment: Alignment.bottomRight,
                                child: FloatingActionButton(
                                  onPressed: () {
                                    _modalBoxAddWallet(context);
                                  },
                                  child: const Icon(Icons.add),
                                ),
                              ),
                            ],
                          )
                        : //todo Name This Alert For Signed Users
                        AlertDialog(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0))),
                            content: const Text(
                              'No Active Wallet!',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.transparent, elevation: 0),
                                child: const Text(
                                  'Create Wallet',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => WhiteScreen(
                                                refresh: () {},
                                                routename: CreateWallet(
                                                  refreshWallet: () {
                                                    details();
                                                  },
                                                ),
                                                whatToDo: '',
                                              )));
                                },
                                //exit the app
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.transparent, elevation: 0),
                                child: const Text(
                                  'Import Wallet',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ImportWallet(
                                          refreshWallet: () {
                                            details();
                                          },
                                          popCreateScreen: () {},
                                        ),
                                      ));
                                },
                                //exit the app
                              ),
                            ],
                          ),
                  ) //todo Name This Alert For LoggedOut Users
                : AlertDialog(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    content: const Text(
                      'No Active Wallet!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.transparent, elevation: 0),
                        child: const Text(
                          'Create Wallet',
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        onPressed: () {
                          _showModalAuthOptions(context);
                        },
                        //exit the app
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.transparent, elevation: 0),
                        child: const Text(
                          'Import Wallet',
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        onPressed: () {
                          _showModalAuthOptions(context);
                        },
                        //exit the app
                      ),
                    ],
                  ),
          );
  }

  CustomContainer buildAddWalletModal() {
    return CustomContainer(
      refresh: () {},
      childWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Change Wallet?',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(
            height: 10,
          ),
          SvgPicture.asset(
            'assets/icons/rocket_out.svg',
            width: 70,
            height: 70,
            color: Colors.redAccent.shade200,
          ),
          const SizedBox(
            height: 10,
          ),
          Wrap(children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Note: Importing or creating a new wallet will replace the current active wallet.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            )
          ]),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: IntrinsicWidth(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                      ),
                      child: (isLoading)
                          ? const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 35.0),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 1.5,
                                ),
                              ),
                            )
                          : const Center(
                              child: Text(
                                'Create New Wallet',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WhiteScreen(
                                      routename: CreateWallet(
                                        refreshWallet: () {
                                          details();
                                        },
                                      ),
                                      refresh: () {},
                                      whatToDo: '',
                                    )));
                      },
                      //exit the app
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                        side: BorderSide(color: Colors.redAccent.shade200),
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 17.0),
                        child: Text(
                          'Import Wallet',
                          style: TextStyle(
                              color: Colors.redAccent.shade200,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ImportWallet(
                                      refreshWallet: () {
                                        details();
                                      },
                                      popCreateScreen: () {},
                                    )));
                      },
                      //exit the app
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  CustomContainer buildResetModalAlert() {
    return CustomContainer(
      childWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin:
                const EdgeInsets.only(right: 20, left: 20, top: 25, bottom: 15),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              border: Border.all(
                color: Colors.black12,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text(
                  'wallet - ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                FutureBuilder(
                  future: fetchForModal,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Text('please wait...',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.black54));
                    }
                    return Text(
                      pubAddress!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black54),
                    );
                  },
                ),
              ],
            ),
          ),
          const Text(
            'Reset Wallet?',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(
            height: 10,
          ),
          SvgPicture.asset(
            'assets/icons/rocket_out.svg',
            width: 70,
            height: 70,
            color: Colors.redAccent.shade200,
          ),
          const SizedBox(
            height: 10,
          ),
          Wrap(children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                  'This will delete the current active wallet so before you proceed, make sure you\'ve correctly backed-up your recovery phrase. You can only regain access to this wallet with the seed phrase.',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            )
          ]),
          const SizedBox(
            height: 30,
          ),
          IntrinsicWidth(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                    ),
                    child: (isLoading)
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 35.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 1.5,
                              ),
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.0),
                            child: Text(
                              'Proceed',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                    onPressed: (isLoading)
                        ? () {}
                        : () {
                            Navigator.pop(context);
                            _modalBoxReset(context);
                            resetUserWallet();
                          },
                    //exit the app
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      side: BorderSide(color: Colors.redAccent.shade200),
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Go Back',
                        style: TextStyle(
                            color: Colors.redAccent.shade200,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    //exit the app
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
      refresh: () {},
    );
  }

  @override
  bool get wantKeepAlive => true;
}
