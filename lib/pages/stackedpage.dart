import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideas_redux/bloc/topic_bloc.dart';
import 'package:ideas_redux/bloc_events/topic_event.dart';
import 'package:ideas_redux/models/notemodel.dart';
import 'package:ideas_redux/models/topicmodel.dart';
import 'package:ideas_redux/pages/mainpages/archived.dart';
import 'package:ideas_redux/pages/mainpages/notes.dart';
import 'package:ideas_redux/pages/mainpages/settings.dart';
import 'package:ideas_redux/pages/mainpages/topics.dart';
import 'package:ideas_redux/testdata/testnotes.dart';
import 'package:ideas_redux/widgets/pagewrapper.dart';

class StackedPage extends StatefulWidget {
  @override
  _StackedPageState createState() => _StackedPageState();
}

enum AppState {
  atNotes,
  atTopics,
  atArchived,
  atSettings,
  addingTopic,
}

class _StackedPageState extends State<StackedPage> {
  int currentIndex = 0;
  AppState _appState = AppState.atNotes;

  void changeAppState(AppState newState) {
    switch (newState) {
      case AppState.atNotes: 
        setState(() {
          currentIndex = 0;
          _appState = newState;
        });
        break;
      case AppState.atTopics: 
        setState(() {
          currentIndex = 1;
          _appState = newState;
        });
        break;
      case AppState.atArchived: 
        setState(() {
          currentIndex = 2;
          _appState = newState;
        });
        break;
      case AppState.atSettings: 
        setState(() {
          currentIndex = 3;
          _appState = newState;
        });
        break;
      case AppState.addingTopic:
        setState(() {
          _appState = newState;
        });
        break;
    }
  }

  final List<Widget> _pages = [ Notes(), Topics(), Archived(), SettingsPage() ];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _buildBottomBar(context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      //color: Colors.white,

      child: Container(
        child: Row(
          mainAxisAlignment: currentIndex <= 1 ? MainAxisAlignment.spaceBetween : MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                FlatButton(child: Icon(Icons.home), onPressed: () { changeAppState(AppState.atNotes); },),
                FlatButton(child: Icon(Icons.category), onPressed: () { changeAppState(AppState.atTopics); },),
              ],
            ),
            Row(
              children: [
                FlatButton(child: Icon(Icons.archive), onPressed: () { changeAppState(AppState.atArchived); },),
                FlatButton(child: Icon(Icons.settings), onPressed: () { changeAppState(AppState.atSettings); },),
              ],
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: _buildBottomBar(context),
      
      floatingActionButton: (currentIndex == 0 || currentIndex == 1) ?
        FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async { 
            switch (currentIndex) {
              case 0:
                final _state = BlocProvider.of<TopicBloc>(context).state.topics.keys.first;
                Navigator.pushNamed(context, '/editentry', arguments: NoteModel.empty(_state)); 
                break;
              case 1:
                changeAppState(AppState.addingTopic);
                var res = await showDialog(
                  context: context,
                  builder: (ctx) {
                    TextEditingController controller = TextEditingController();

                    return WillPopScope(
                      onWillPop: () async { changeAppState(AppState.atTopics); return true; },
                      child: AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: controller,
                            )
                          ],
                        ),
                        actions: [
                          FlatButton(child: Text('Cancel', style: Theme.of(context).textTheme.subtitle1,), textColor: Colors.red,  onPressed: () => Navigator.pop(context, null),),
                          FlatButton(child: Text('Save', style: Theme.of(context).textTheme.subtitle1,), onPressed: () => Navigator.pop(context, controller.text),),
                        ],
                      ),
                    );
                  }
                );

                if (res != null)
                  BlocProvider.of<TopicBloc>(context).add( TopicEvent.addTopic( TopicModel(-1, res) ) );
                break;
            }
          },
        ) :
        null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      body: SafeArea(
        top: true,
        child: IndexedStack(
          index: currentIndex,
          children: [
            AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              opacity: currentIndex == 0 ? 1 : 0,
              child: _pages[0],
            ),
            AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              opacity: currentIndex == 1 ? 1 : 0,
              child: _pages[1],
            ),
            AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              opacity: currentIndex == 2 ? 1 : 0,
              child: _pages[2],
            ),
            AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              opacity: currentIndex == 3 ? 1 : 0,
              child: _pages[3],
            ),
          ]
        )
      )
    );
  }
}