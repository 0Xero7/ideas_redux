import 'package:flutter/material.dart';

class Back extends StatelessWidget {
  Function onPressed;
  bool closeIcon;
  bool popRoute;
  Back({this.onPressed, this.popRoute = true, this.closeIcon = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(40),
      color: Theme.of(context).highlightColor,

      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () { 
          if (onPressed != null) onPressed();
          if (popRoute) Navigator.pop(context); 
        },

        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(closeIcon ? Icons.close : Icons.arrow_back),
        ),
      ),
    );   
  }
}