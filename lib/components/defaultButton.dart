import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DefaultButton extends StatefulWidget {
  const DefaultButton(
      {Key? key,
      required this.onTap,
      this.icon,
      required this.withIcon,
      required this.textColor,
      required this.bgColor,
      required this.borderColor,
      required this.buttonText})
      : super(key: key);
  final Function() onTap;
  final icon;
  final bool withIcon;
  final String buttonText;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  @override
  State<DefaultButton> createState() => DefaultButtonState();
}

class DefaultButtonState extends State<DefaultButton> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: widget.bgColor,
          side: BorderSide(
            color: widget.borderColor,
          ),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
        ),
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          await widget.onTap();
          setState(() {
            isLoading = false;
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              child: (isLoading)
                  ? SizedBox(
                      height: 12,
                      width: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: widget.textColor,
                      ),
                    )
                  : Icon(
                      widget.icon,
                      size: 16,
                      color: widget.textColor,
                    ),
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              widget.buttonText,
              style: TextStyle(
                  color: widget.textColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
