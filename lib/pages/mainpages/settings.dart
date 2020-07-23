import 'package:flutter/material.dart';
import 'package:ideas_redux/widgets/pagewrapper.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsPage();
  }
}

class _SettingsPage extends State<SettingsPage> {
  bool searchSelected = false;

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () { 
                FocusScope.of(context).requestFocus(FocusNode());
                setState(() => searchSelected = false);
              },
            )
          ),

          Positioned(
            top: 20,
            left: 20,
            child: Text(
              'Settings',
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
        ]
      )
    );
  }
}