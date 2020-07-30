import 'package:flutter/material.dart';
import 'package:ideas_redux/state/settings_state.dart';
import 'package:ideas_redux/widgets/pagewrapper.dart';
import 'package:provider/provider.dart';

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
    return Consumer<SettingsState>(
      builder: (context, state, child) => PageWrapper(
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
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 85,
                decoration: BoxDecoration(
                  color: Theme.of(context).bottomAppBarColor
                ),
              ),
            ),

            Positioned(
              top: 20,
              left: 20,
              child: Text(
                'Settings',
                style: Theme.of(context).textTheme.headline4,
              ),
            ),

            Positioned(
              top: 85,
              bottom: 0,
              left: 0,
              right: 0,
              child: ListView(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                children: [
                  SwitchListTile(
                    onChanged: (e) async {
                      await state.setDarkTheme(e);
                    },
                    value: state.darkTheme,
                    title: Text('Dark Theme'),
                  ),
                  Divider(
                    indent: 10,
                    endIndent: 10,
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.info_outline),
                        const SizedBox(width: 5,),
                        Text('About'),
                      ],
                    ),
                    onTap: () {},
                  ),
                  Divider(
                    indent: 10,
                    endIndent: 10,
                  ),
                  // ListTile(
                  //   subtitle: Text('Like the app?', style: Theme.of(context).textTheme.subtitle2,),
                  // ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.play_arrow),
                        const SizedBox(width: 5,),
                        Text('Rate on Google Play!'),
                      ],
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.store),
                        const SizedBox(width: 5,),
                        Text('Buy me a coffee!'),
                      ],
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            )
          ]
        )
      ),
    );
  }
}