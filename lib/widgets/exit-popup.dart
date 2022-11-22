import 'dart:io';
import 'package:flutter/material.dart';

Future<bool> showExitPopup(context) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: SizedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Do you want to exit?",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.transparent, elevation: 0),
                        child: const Text('Exit',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        onPressed: () {
                          exit(0);
                        },
                      ),
                    ),
                    const SizedBox(width: 0),
                    Expanded(
                        child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.transparent, elevation: 0),
                      child: const Text('Back',
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ))
                  ],
                )
              ],
            ),
          ),
        );
      });
}
