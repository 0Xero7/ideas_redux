import 'package:flutter/material.dart';

class PageWrapper extends StatelessWidget {
  final Widget child;
  ValueKey key;
  PageWrapper({this.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,// ?? UniqueKey(),
      body: SafeArea(
        top: true,
        child: child,
      ),
    );   
  }
}