import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final Function onPressed;
  final Widget child;
  RoundButton({this.onPressed, this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(40),
      color: Theme.of(context).highlightColor,

      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () { 
          if (onPressed != null) onPressed();
        },

        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: child,
        ),
      ),
    );   
  }
}