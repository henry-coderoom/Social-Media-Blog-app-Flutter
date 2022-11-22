import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart';

bool connectionStatus = true;
Future check() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      connectionStatus = true;
    }
  } on SocketException catch (_) {
    connectionStatus = false;
  }
}

class DeletedUserScreen extends StatefulWidget {
  static String routeName = "/deletedUserPage";

  const DeletedUserScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<DeletedUserScreen> createState() => DeletedUserScreenState();
}

class DeletedUserScreenState extends State<DeletedUserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        title: const Text(""),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: connectionStatus == false
                    ? SizedBox(
                        height: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 7,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.signal_cellular_off_outlined,
                                  size: 25,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'ERR: Check your internet connection \n and try again.',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            ElevatedButton(
                                onPressed: () async {
                                  await check();
                                  setState(() {});
                                },
                                child: const Text('Retry'))
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0, bottom: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Center(
                            child: SizedBox(
                              height: 145,
                              width: 145,
                              child: CircleAvatar(
                                backgroundImage: AssetImage(
                                    'assets/images/deleted_user.png'),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Column(
                            children: const [
                              Center(
                                child: AutoSizeText(
                                  '@anonnymous',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                  maxFontSize: 28,
                                  minFontSize: 22,
                                  maxLines: 3,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 5,
                      thickness: 8,
                      color: Color(0xFFE0E0E0),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 30, right: 30, bottom: 15, top: 30),
                        child: StyledText(
                          text:
                              '<bold>User no loger exist</bold>: This user might have been deleted or suspended.',
                          tags: {
                            'bold': StyledTextTag(
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            'b': StyledTextTag(
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          },
                          style: const TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFFAFAFAF)),
                        )),
                  ],
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
}
