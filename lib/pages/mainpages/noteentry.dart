import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:ideas_redux/bloc/note_bloc.dart';
import 'package:ideas_redux/bloc/topic_bloc.dart';
import 'package:ideas_redux/bloc_events/note_event.dart';
import 'package:ideas_redux/models/datamodels/checklistmodel.dart';
import 'package:ideas_redux/models/datamodels/imagedatamodel.dart';
import 'package:ideas_redux/models/datamodels/textdatamodel.dart';
import 'package:ideas_redux/models/notemodel.dart';
import 'package:ideas_redux/state/topic_state.dart';
import 'package:ideas_redux/widgets/back.dart';
import 'package:ideas_redux/widgets/pagewrapper.dart';
import 'package:ideas_redux/widgets/visual/checklist.dart';
import 'package:ideas_redux/widgets/visual/roundbutton.dart';
import 'package:image_picker/image_picker.dart';

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
    if (widget.model.title == null || widget.model.title.trim() == '') return;
    if (widget.model.data == null || widget.model.data.length == 0) return;

    widget.model.updatedOn = DateTime.now().millisecondsSinceEpoch;

    if (widget.model.id == -1) {
      widget.model.createdOn = widget.model.updatedOn;
      BlocProvider.of<NoteBloc>(context).add( NoteEvent.addNote(widget.model) );
    }
    else {
      BlocProvider.of<NoteBloc>(context).add( NoteEvent.updateNote(widget.oldModel, widget.model) );
    }
  }


  Widget _buildNonReorderList() {
    print("called");
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
      padding: EdgeInsets.only(bottom: 40),
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
          color: Theme.of(context).canvasColor,
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
                      top: 133,
                      left: 8,
                      right: 8,

                      child: Container(
                        child: Material(
                          elevation: 5,
                          shadowColor: Colors.black26,
                          color: Theme.of(context).bottomAppBarColor,
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

  Widget _buildListChild(BuildContext context, int index) {
    final i = widget.model.data[index];

    switch (widget.model.data[index].runtimeType) {
      case TextDataModel:
        return Container(
          child: Padding(
            padding: const EdgeInsets.only(left: 13),
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
        );
          break;

      case ChecklistModel:
        return Container(
          key: UniqueKey(),
          child: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Checklist(i as ChecklistModel)
          ),
        );
        break;

      case ImageDataModel:
        return Container(
          key: UniqueKey(),
          child: Image.file(File.fromRawPath( utf8.encode((i as ImageDataModel).path)) ),
        );
        break;
    }
  }

  Widget _buildTopBar(context) => Column(
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
          // const SizedBox(width: 13),
          // Text('Topic', style: Theme.of(context).textTheme.subtitle1),
          Expanded(child: _buildTopicButton(context)),
        ],
      ),
      Divider()
    ]
  );

  final scaffoldState = ScaffoldState();

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async { await saveNote(); return true; },
      child: PageWrapper(
        key: ValueKey(scaffoldState),
        child: Stack(
          children: [
            ReorderableList(
              onReorder: (draggedItem, newPosition) {
                final int from = widget.model.data.indexWhere((model) => model.id == (draggedItem as ValueKey).value);
                final int to = widget.model.data.indexWhere((model) => model.id == (newPosition as ValueKey).value);
                // final int to = (newPosition as ValueKey).value;

                final _draggedItem = widget.model.data[from];
                // print('$from -> $to');
                setState(() {
                  widget.model.data.removeAt(from);
                  widget.model.data.insert(to, _draggedItem);
                });
                return true;
              },
              child: CustomScrollView(
                slivers: [
                  SliverStickyHeader(
                    sticky: true,

                    header: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          height: 80,
                          color: Theme.of(context).canvasColor.withAlpha(200),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Back(
                                  onPressed: () async {
                                      await saveNote();
                                  },
                                ),
                                RoundButton(
                                  child: Icon(MaterialIcons.more_vert),
                                  onPressed: () async { 
                                    var t = await showMenu(
                                      context: context, 
                                      position: RelativeRect.fromLTRB(10000, 42, 0, 0), 
                                      items: [
                                        PopupMenuItem(
                                          child: Row(
                                            children: [
                                              Icon(widget.model.protected ? Icons.lock_open : Icons.lock_outline, size: 18,),
                                              const SizedBox(width: 5,),
                                              Padding(
                                                padding: EdgeInsets.only(top: 2),
                                                child: Text(
                                                  !widget.model.protected ? 
                                                    'Protect' : 'Remove protection',
                                                )
                                              )
                                            ],
                                          ),
                                          value: 'protect',
                                        ),
                                        PopupMenuItem(
                                          child: Row(
                                            children: [
                                              Icon(Icons.archive, size: 18,),
                                              const SizedBox(width: 5,),
                                              Padding(
                                                padding: EdgeInsets.only(top: 2),
                                                child: Text(
                                                  'Archive',
                                                )
                                              )
                                            ],
                                          ),
                                          value: 'archived',
                                        ),
                                        PopupMenuItem(
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline, size: 18,),
                                              const SizedBox(width: 5,),
                                              Padding(
                                                padding: EdgeInsets.only(top: 2),
                                                child: Text(
                                                  'Delete',
                                                )
                                              )
                                            ],
                                          ),
                                          value: 'delete',
                                        ),
                                      ],
                                    );

                                    switch (t) {
                                      case 'protect':
                                        widget.model.protected = !widget.model.protected;
                                        await saveNote();
                                        break;
                                    }
                                    print(t);
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final int size = (2 * widget.model.data.length - 1);

                          if (index == 0) return _buildTopBar(context);
                          
                          if (index >= 1 && index <= (2 * widget.model.data.length) - 1) {
                            int _id = (index - 1) ~/ 2;
                            if ((index - 1) % 2 == 0) return ReorderableItem(
                                key: ValueKey(widget.model.data[_id].id),
                                childBuilder: (context, reorderState) => Opacity(
                                  opacity: reorderState == ReorderableItemState.placeholder ? 0 : 1,
                                  child: Dismissible(
                                    key: UniqueKey(),
                                    direction: DismissDirection.startToEnd,
                                    onDismissed: (direction) {
                                      setState(() => widget.model.data.removeAt(_id));
                                    },

                                    background: Container(
                                      color: Colors.red.shade400,
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 2.0, left: 10, right: 4),
                                            child: const Icon(Feather.trash, color: Colors.white, size: 16),
                                          ),
                                          const Text('Delete', style: TextStyle(color: Colors.white, fontSize: 15),)
                                        ],
                                      ),
                                    ),

                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 7, right: 10),
                                      child: Row(
                                        children: [
                                          ReorderableListener(
                                            child: Icon(MaterialCommunityIcons.drag),
                                          ),
                                          Expanded(child: _buildListChild(context, _id)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            else return Divider(thickness: 0, color: Theme.of(context).dividerColor.withAlpha(10));
                          }
                          
                          return const SizedBox(height: 60); // end padding
                        },

                        childCount: 1 + (2 * widget.model.data.length - 1) + 1,
                      )
                    )
                  )
                ],
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,

              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                  child: Container(
                    height: 50,
                    color: Theme.of(context).cardColor.withAlpha(170),

                    child: Row(
                      mainAxisSize: MainAxisSize.max,
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
                        ),
                        const SizedBox(width: 5),
                        Builder(
                          builder: (context) => IconButton(
                            icon: Icon(Feather.image, size: 21,),
                            onPressed: () async {
                              var picker = ImagePicker();

                              var src = await showModalBottomSheet(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                context: context,
                                builder: (context) => Container(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Choose a source', style: Theme.of(context).textTheme.subtitle1,),
                                      FlatButton(
                                        onPressed: () => Navigator.pop(context, ImageSource.camera),
                                        child: Row(
                                          children: [
                                            Icon(Feather.camera, size: 20),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 7, top: 2.5),
                                              child: Text('Camera'),
                                            )
                                          ],
                                        ),
                                      ),
                                      FlatButton(
                                        onPressed: () => Navigator.pop(context, ImageSource.gallery),
                                        child: Row(
                                          children: [
                                            Icon(Feather.image, size: 20),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 7, top: 2.5),
                                              child: Text('Gallery'),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                              if (src == null) return;

                              var file = await picker.getImage(source: src);

                              if (file != null) {
                                setState(() {
                                  widget.model.data.add(ImageDataModel(file.path));
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ),
          ]
        )
      ),
    );
  }
}