import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final Function onPressed;
  final Widget child;
  final bool disabled;
  RoundButton({this.onPressed, this.child, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: disabled,
      child: Opacity(
        opacity: disabled ? 0.3 : 1.0,
        child: Material(
          borderRadius: BorderRadius.circular(40),
          color: disabled ? Theme.of(context).disabledColor : Theme.of(context).highlightColor,

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
        ),
      ),
    );   
  }
}