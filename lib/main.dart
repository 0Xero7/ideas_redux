import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:ideas_redux/bloc/note_bloc.dart';
import 'package:ideas_redux/bloc/topic_bloc.dart';
import 'package:ideas_redux/database/notesdb.dart';
import 'package:ideas_redux/database/topicsdb.dart';
import 'package:ideas_redux/pages/stackedpage.dart';
import 'package:ideas_redux/routes/routegenerator.dart';
import 'package:ideas_redux/state/note_state.dart';
import 'package:ideas_redux/state/topic_state.dart';
import 'package:ideas_redux/testdata/testnotes.dart';
import 'package:ideas_redux/themes.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: move this to a dedicated loading page
  await TopicsDB.initDB();
  var _topics = await TopicsDB.loadTopics();

  TopicState _topicState = TopicState();
  for (var i in _topics)
    _topicState.addTopic(i);

  NoteState _state = NoteState();

  await NotesDB.initDB();
  var _notes = await NotesDB.loadNotes();
  for (var i in _notes)
    _state.addNote(i);

  runApp(MyApp(_state, _topicState));
}

class MyApp extends StatelessWidget {
  NoteState _state;
  TopicState _topicState;
  MyApp(this._state, this._topicState);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => NoteBloc(_state),
        ),
        BlocProvider(
          create: (context) => TopicBloc(_topicState),
        )
      ],
      
      child: MaterialApp(
        title: 'inScribe',
        theme: darkTheme,

        initialRoute: '/',
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}