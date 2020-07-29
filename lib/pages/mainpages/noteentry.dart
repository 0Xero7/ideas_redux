import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideas_redux/bloc/note_bloc.dart';
import 'package:ideas_redux/bloc/topic_bloc.dart';
import 'package:ideas_redux/bloc_events/note_event.dart';
import 'package:ideas_redux/models/datamodels/checklistmodel.dart';
import 'package:ideas_redux/models/datamodels/textdatamodel.dart';
import 'package:ideas_redux/models/notemodel.dart';
import 'package:ideas_redux/state/topic_state.dart';
import 'package:ideas_redux/widgets/back.dart';
import 'package:ideas_redux/widgets/pagewrapper.dart';
import 'package:ideas_redux/widgets/visual/checklist.dart';

enum NoteEntryMode {
  ReadingMode,
  EditMode,
  ReorderMode
}

class NoteEntry extends StatefulWidget {
  NoteEntryMode entryMode = NoteEntryMode.EditMode;

  NoteModel model, oldModel;
  NoteEntry(this.model) {
    oldModel = NoteModel.from(model);
  }

  @override
  State<StatefulWidget> createState() {
    return _NoteEntry();    
  }
}

class _NoteEntry extends State<NoteEntry> {
  @override
  void initState() {
    super.initState();
  }

  Future saveNote() async {
    if (widget.model.id == -1) BlocProvider.of<NoteBloc>(context).add( NoteEvent.addNote(widget.model) );
    else BlocProvider.of<NoteBloc>(context).add( NoteEvent.updateNote(widget.oldModel, widget.model) );
  }

  Widget _buildNonReorderList() {
    List<Widget> res = List<Widget>();

    for (var i in widget.model.data) {
      switch (i.runtimeType) {
        case TextDataModel:
          res.add(
            Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.startToEnd,
              onDismissed: (direction) {
                setState(() {
                  widget.model.data.remove(i);
                });
              },

              background: Container(
                color: Colors.red.shade100,
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    Text('Delete')
                  ],
                ),
              ),

              child: Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: TextField(
                    controller: TextEditingController(text: (i as TextDataModel).data),
                    onChanged: (s) => (i as TextDataModel).data = s,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Note",
                      isDense: true
                    ),
                    style: Theme.of(context).textTheme.subtitle1,
                    maxLines: null,
                  ),
                ),
              ),
            )
          );
          break;

        case ChecklistModel:
          res.add(
            Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.startToEnd,
              background: Container(
                color: Colors.red.shade100,
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    Text('Delete')
                  ],
                ),
              ),
              onDismissed: (direction) => setState(() => widget.model.data.remove(i)),
              child: Container(
                key: UniqueKey(),
                child: Padding(
                  padding: const EdgeInsets.only(right: 10, left: 2),
                  child: Checklist(i as ChecklistModel)
                ),
              ),
            )
          );
          break;
      }
    }

    return ListView(
      children: res,
    );
  }

  Widget _buildReorderableList(BuildContext context) {
    List<Widget> res = List<Widget>();

    for (var i in widget.model.data) {
      switch (i.runtimeType) {
        case TextDataModel:
          res.add(
            Container(
              key: UniqueKey(),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                    child: widget.entryMode == NoteEntryMode.ReorderMode ? Icon(Icons.drag_handle) : Container(height: 24,),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: TextField(
                        controller: TextEditingController(text: (i as TextDataModel).data),
                        onChanged: (s) => (i as TextDataModel).data = s,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Note",
                          isDense: true
                        ),
                        style: Theme.of(context).textTheme.subtitle1,
                        maxLines: null,
                      ),
                    ),
                  )
                ],
              ),
            )
          );
          break;

        case ChecklistModel:
          res.add(
            Container(
              key: UniqueKey(),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                    child: widget.entryMode == NoteEntryMode.ReorderMode ? Icon(Icons.drag_handle) : Container(height: 24,),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Checklist(i as ChecklistModel)
                    ),
                  )
                ],
              ),
            )
          );
          break;
      }
    }

    return ReorderableListView(
      onReorder: (oldIndex, newIndex) {
        print(oldIndex.toString() + "," + newIndex.toString());

        if (oldIndex == newIndex) return;
        if (newIndex < 0) newIndex = 0;
        if (newIndex >= widget.model.data.length) newIndex = widget.model.data.length - 1;

        setState(() {
          var _temp = widget.model.data[oldIndex];
          widget.model.data[oldIndex] = widget.model.data[newIndex];
          widget.model.data[newIndex] = _temp;
        });
      },
      children: res,
    );
  }

  Widget _buildTopicButton(BuildContext context) {
    final TopicState state = BlocProvider.of<TopicBloc>(context).state;

    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Material(
          color: Theme.of(context).buttonColor,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),

            onTap: () async {
              var _itKeys = state.topics.keys.iterator;
              _itKeys.moveNext();

              var res = await showDialog(
                barrierColor: Colors.black.withAlpha(1),
                
                context: context,
                builder: (context) => Stack(
                  children: [
                    Positioned(
                      top: 132,
                      left: 59,
                      right: 8,

                      child: Container(
                        //height: 300,

                        child: Material(
                          elevation: 5,
                          shadowColor: Colors.black26,
                          color: Theme.of(context).buttonColor,
                          borderRadius: BorderRadius.circular(8),

                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                Text(
                                  state.topics[widget.model.topicId].topicName,
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                                Divider(),
                                ConstrainedBox(
                                  constraints: BoxConstraints.loose(
                                    Size(double.infinity, 150)
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: state.topics.length,
                                    itemBuilder: (context, index) {
                                      final topicName = state.topics[ _itKeys.current ].topicName;
                                      final topicID = _itKeys.current;
                                      _itKeys.moveNext();

                                      return Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => Navigator.pop(context, topicID),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(topicName, style: Theme.of(context).textTheme.subtitle1),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]
                )
              );
              
              if (res != null) {
                setState(() {
                  widget.model.topicId = res;
                });
              }
            },

            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(state.topics[widget.model.topicId].topicName, style: Theme.of(context).textTheme.subtitle1,),
                  Icon(Icons.arrow_drop_down)
                ],
              ),
            ),
          ),
        )
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 15,
            child: Back(
              onPressed: () async {
                  await saveNote();
              },
            )
          ),

          Positioned(
            top: 32,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Editing',
                style: Theme.of(context).textTheme.subtitle1,
              )
            ),
          ),
          
          Positioned(
            top: 20,
            right: 15,
            child: Material(
              borderRadius: BorderRadius.circular(40),
              color: Theme.of(context).highlightColor,

              child: InkWell(
                borderRadius: BorderRadius.circular(40),
                onTap: () { 
                  setState(() {
                    widget.entryMode = widget.entryMode == NoteEntryMode.ReorderMode ? 
                      NoteEntryMode.EditMode : NoteEntryMode.ReorderMode;
                  });
                },

                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.shuffle),
                ),
              ),
            )
          ),

          Positioned(
            top: 80,
            left:  0,
            right: 0,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: TextField(
                    controller: TextEditingController(text: widget.model.title),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.all(10),                
                      hintText: "Title",
                    ),
                    onChanged: (e) => widget.model.title = e,
                    
                    style: Theme.of(context).textTheme.headline6
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const SizedBox(width: 13),
                    Text('Topic', style: Theme.of(context).textTheme.subtitle1),
                    Expanded(child: _buildTopicButton(context)),
                  ],
                ),
                Divider()
              ]
            ),
          ),

          Positioned(
            top: 180,
            left: 0,
            right: 0,
            bottom: 0,
            
            child: widget.entryMode == NoteEntryMode.ReorderMode ? _buildReorderableList(context) : _buildNonReorderList(),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,

            child: Container(
              height: 50,
              color: Theme.of(context).cardColor.withAlpha(10),

              child: Row(
                children: [
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      icon: Icon(Icons.text_format),
                      onPressed: () {
                        setState(() {
                          widget.model.data.add(TextDataModel(''));
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    icon: Icon(Icons.list),
                    onPressed: () {
                      setState(() {
                        widget.model.data.add(
                          ChecklistModel.emptyWithEntry()
                        );
                      });
                    },
                  )
                ],
              ),
            )
          ),

          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //     child: Padding(
          //       padding: const EdgeInsets.symmetric(horizontal: 10),
          //       child: Row(
          //         children: [
          //           SizedBox(
          //             width: 40,
          //             height: 40,
          //             child: MaterialButton(
          //               padding: EdgeInsets.zero,
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(20)
          //               ),
          //               onPressed: () {
          //                 setState(() {
          //                   widget.model.data.add(TextDataModel(''));
          //                 });
          //               },
          //               child: Icon(Icons.text_format),
          //             ),
          //           ),
          //           const SizedBox(width: 5),
          //           IconButton(
          //             icon: Icon(Icons.list),
          //             onPressed: () {
          //               setState(() {
          //                 widget.model.data.add(
          //                   ChecklistModel.emptyWithEntry()
          //                 );
          //               });
          //             },
          //           )
          //         ],
          //       ),
          //     ),
          //   ),
          
        ],
      ),
    ); 
  }
}