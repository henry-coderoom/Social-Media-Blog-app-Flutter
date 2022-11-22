import 'dart:io';

import 'package:flutter/material.dart';

class ModalBox extends StatefulWidget {
  const ModalBox({Key? key, required this.refresh, required this.modalWidget})
      : super(key: key);
  final Function() refresh;
  final Widget modalWidget;
  @override
  State<ModalBox> createState() => ModalBoxState();
}

class ModalBoxState extends State<ModalBox> {
  @override
  void initState() {
    widget.refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        child: widget.modalWidget);
  }
}

class CustomContainer extends StatefulWidget {
  const CustomContainer(
      {Key? key, required this.refresh, required this.childWidget})
      : super(key: key);
  final Function() refresh;
  final Widget childWidget;
  @override
  State<CustomContainer> createState() => CustomContainerState();
}

class CustomContainerState extends State<CustomContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
        maxWidth: MediaQuery.of(context).size.width,
        minHeight: 100.0, //min height you want to take by container
        maxHeight: double.infinity, //max height you want to take by container
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -15),
            blurRadius: 20,
            color: const Color(0xFFDADADA).withOpacity(0.15),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SingleChildScrollView(
          scrollDirection: Axis.vertical, child: widget.childWidget),
    );
  }
}

class NoNetworkWidget extends StatefulWidget {
  final bool isConnected;
  final Function() reLoad;
  const NoNetworkWidget(
      {Key? key, required this.isConnected, required this.reLoad})
      : super(key: key);
  @override
  State<NoNetworkWidget> createState() => NoNetworkWidgetState();
}

class NoNetworkWidgetState extends State<NoNetworkWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: widget.isConnected == false
          ? IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: const [
                        SizedBox(
                          height: 5,
                        ),
                        Icon(
                          Icons.signal_cellular_off_outlined,
                          size: 25,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'ERR: Check your internet connection and try again.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        await widget.reLoad();
                        setState(() {});
                      },
                      child: const Text('Retry'))
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
