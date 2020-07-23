import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideas_redux/bloc/note_bloc.dart';
import 'package:ideas_redux/bloc/topic_bloc.dart';
import 'package:ideas_redux/bloc_events/note_event.dart';
import 'package:ideas_redux/models/datamodels/checklistmodel.dart';
import 'package:ideas_redux/models/datamodels/textdatamodel.dart';
import 'package:ideas_redux/models/notemodel.dart';
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

  List<Widget> _createNonReorderList() {
    List<Widget> res = List<Widget>();

    for (var i in widget.model.data) {
      switch (i.runtimeType) {
        case TextDataModel:
          res.add(Container(
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
          res.add(Container(
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

    return res;
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
            bottom: 0,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: DropdownButton(
                    elevation: 1,
                    isDense: true,
                    underline: Container(),
                    icon: Icon(Icons.arrow_drop_down),
                    value: widget.model.topicId,

                    items: List.generate(
                      BlocProvider.of<TopicBloc>(context).state.topics.length,
                      (index) => DropdownMenuItem(
                        value: BlocProvider.of<TopicBloc>(context).state.topics.values.elementAt(index).id,
                        child: Text('${BlocProvider.of<TopicBloc>(context).state.topics.values.elementAt(index).topicName}')
                      )
                    ),

                    onChanged: (e) { 
                      print(e); 
                      setState(() => widget.model.topicId = e);
                    },
                  )
                ),

                const SizedBox(height: 5),
                Divider()
              ]
            ),
          ),

          Positioned(
            top: 175,
            left: 0,
            right: 0,
            bottom: 0,
            
            child: ListView(
              children: _createNonReorderList(),
              
              
              // [
              //   Container(
              //     key: UniqueKey(),
              //     child: Row(
              //       children: [
              //         Padding(
              //           padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
              //           child: widget.entryMode == NoteEntryMode.ReorderMode ? Icon(Icons.drag_handle) : Container(height: 24,),
              //         ),

              //         Expanded(
              //           child: Padding(
              //             padding: const EdgeInsets.only(right: 10),
              //             child: TextField(
              //               decoration: InputDecoration(
              //                 border: InputBorder.none,
              //                 hintText: "Note",
              //                 isDense: true
              //               ),
              //               style: Theme.of(context).textTheme.subtitle1,
              //               maxLines: null,
              //             ),
              //           ),
              //         )
              //       ],
              //     ),
              //   ),

              //   // Container(
              //   //   key: UniqueKey(),

              //   //   child: Row(
              //   //     children: [
              //   //       Padding(
              //   //         padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
              //   //         child: widget.entryMode == NoteEntryMode.ReorderMode ? Icon(Icons.drag_handle) : Container(height: 24,),
              //   //       ),

              //   //       Expanded(
              //   //         child: Padding(
              //   //           padding: const EdgeInsets.only(right: 10),
              //   //           child: Checklist()
              //   //         )
              //   //       )
              //   //     ],
              //   //   ),
              //   // ),

              // ],
            ),
          )
        ],
      ),
    ); 
  }
}