import 'package:flutter/material.dart';
import 'package:ideas_redux/widgets/back.dart';
import 'package:ideas_redux/widgets/pagewrapper.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      child: Stack(
        children: [
          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   child: Container(
          //     height: 85,
          //     decoration: BoxDecoration(
          //       color: Theme.of(context).bottomAppBarColor
          //     ),
          //   ),
          // ),

          Positioned(
            top: 20,
            left: 15,
            child: Row(
              children: [
                Back(popRoute: true,),
                const SizedBox(width: 10),
                Text(
                  'About',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            ),
          ),

          Positioned(
            top: 100,
            left: 0,
            right: 0,

            child: Center(
              child: Text(
                'inScribe',
                style: Theme.of(context).textTheme.headline2,
              )
            ),
          ),
          Positioned(
            top: 170,
            left: 0,
            right: 0,

            child: Center(
              child: Opacity(
                opacity: 0.4,
                child: Text(
                  'version 300720b0',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              )
            ),
          ),
          Positioned(
            top: 260,
            left: 0,
            right: 0,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      'Created & Maintained by',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                FlatButton(
                  onPressed: () {},
                  child: Text(
                    '@0xero7',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                )
              ],
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,

            child: Column(
              children: [
                Center(
                  child: FlatButton(
                    child: Text(
                      'Privacy Policy',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    onPressed: () {
                      
                    },
                  )
                ),
                Center(
                  child: FlatButton(
                    child: Text(
                      'Licenses',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    onPressed: () {
                      showLicensePage(context: context);
                    },
                  )
                ),
              ],
            ),
          ),
        ]
      )
    );  
  }
}