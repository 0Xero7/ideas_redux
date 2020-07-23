import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideas_redux/bloc/note_bloc.dart';
import 'package:ideas_redux/bloc/topic_bloc.dart';
import 'package:ideas_redux/state/topic_state.dart';
import 'package:ideas_redux/widgets/pagewrapper.dart';

class Topics extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Topics();
  }
}

class _Topics extends State<Topics> {
  bool searchSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { 
        setState(() => searchSelected = false);
        FocusScope.of(context).requestFocus(FocusNode()); 
      },

      child: PageWrapper(
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 20,
              child: Text(
                'Topics',
                style: Theme.of(context).textTheme.headline4,
              ),
            ),

            Positioned(
              top: 79,
              left:  15,
              right: 15,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: searchSelected ? Theme.of(context).accentColor : Colors.black12,
                    width: searchSelected ? 2 : 1
                  ),
                  color: Colors.black.withAlpha(6),
                  borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),

            Positioned(
              top: 87,
              right: 25,
              child: Icon(Icons.search, color: Colors.black54),
            ),

            Positioned(
              top: 88,
              left:  25,
              right: 55,
              child: TextField(
                onTap: () { setState(() => searchSelected = true); },
                onEditingComplete: () { setState(() => searchSelected = false); },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  isCollapsed: true
                ),
                style: Theme.of(context).textTheme.subtitle1,
              )
            ),

            Positioned(
              top: 125,
              left: 0,
              right: 0,
              bottom: 0,

              child: BlocBuilder<TopicBloc, TopicState>(
                builder: (context, state) { 
                  //final _state = BlocProvider.of<NoteBloc>(context);
                  return ListView.builder(
                    itemCount: state.topics.length,
                    itemBuilder: (_, index) => ListTile(
                      title: Text(state.topics.values.elementAt(index).topicName),
                      //subtitle: Text('${_state.state.notesInCategory[state.topics.keys.elementAt(index)].length}'),
                    ),
                  );
                }
              )
            )
          ]
        )
      ),
    );
  }
}