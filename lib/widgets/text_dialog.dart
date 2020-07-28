import 'package:flutter/material.dart';

Future<T> showTextDialog<T>(BuildContext context, Function popScopeCallback) => showDialog(
  context: context,
  builder: (ctx) {
    TextEditingController controller = TextEditingController();

    return WillPopScope(
      onWillPop: () async { popScopeCallback(); return true; },
      child: AlertDialog(
        contentPadding: EdgeInsets.all(10),
        actionsPadding: EdgeInsets.all(0),
        buttonPadding: EdgeInsets.all(5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Stack(
          children: [
            Positioned(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(8)
                ),
              ),
            ),

            Positioned(
              top: 8,
              left: 8,
              right: 8,

              child: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  isCollapsed: true,
                  hintText: 'Topic name'
                ),
                style: Theme.of(context).textTheme.subtitle1,
              )
            ),
          ],
        ),

        actions: [
          FlatButton(
            child: Text(
              'Cancel', 
              style: Theme.of(context).textTheme.subtitle1,
            ), 
            textColor: Colors.red, 
            onPressed: () => Navigator.pop(context, null),
          ),
          FlatButton(
            child: Text(
              'Save', 
              style: Theme.of(context).textTheme.subtitle1,
            ), 
            onPressed: () => Navigator.pop(context, controller.text),
          ),
        ],
      ),
    );
  }
);