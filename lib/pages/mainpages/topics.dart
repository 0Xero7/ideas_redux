import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart' as reoderable;
import 'package:ideas_redux/bloc/note_bloc.dart';
import 'package:ideas_redux/bloc/topic_bloc.dart';
import 'package:ideas_redux/bloc_events/note_event.dart';
import 'package:ideas_redux/bloc_events/topic_event.dart';
import 'package:ideas_redux/models/notemodel.dart';
import 'package:ideas_redux/models/topicmodel.dart';
import 'package:ideas_redux/state/selection_state.dart';
import 'package:ideas_redux/state/topic_state.dart';
import 'package:ideas_redux/widgets/animatedposop.dart';
import 'package:ideas_redux/widgets/back.dart';
import 'package:ideas_redux/widgets/pagewrapper.dart';
import 'package:ideas_redux/widgets/visual/roundbutton.dart';
import 'package:provider/provider.dart';
import 'package:random_color/random_color.dart';

class Topics extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Topics();
  }
}

class _Topics extends State<Topics> {
  bool searchSelected = false;

  Future<bool> _deleteTopicsConfirm(BuildContext context, SelectionState state) async {
    final bool res = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Warning'),
        content: Text('Deleting topics will move the notes assigned to them into "Others".'),
        actions: [
          FlatButton(
            onPressed: () { Navigator.pop(context, false); },
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          FlatButton(
            onPressed: () { Navigator.pop(context, true); },
            child: Text(
              'Continue',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        ],
      ),
    );

    return res;
  }
  
  Widget _buildHeader(BuildContext ctx) {
    final SelectionState _state = Provider.of<SelectionState>(ctx);
    
    return AnimatedPosOp(
      hidden: true,
      opacity: _state.selecting ? 0 : 1,
      top: 20,
      left: _state.selecting ? 0 : 20,

      duration: Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,

      child: Text(
        'Topics',
        style: Theme.of(context).textTheme.headline4,
      ),
    );
  } 

  Widget _buildSelectionMenuLeft(BuildContext ctx) {
    final SelectionState _state = Provider.of<SelectionState>(ctx);
    
    return AnimatedPosOp(
      hidden: !_state.selecting,
      opacity: !_state.selecting ? 0 : 1,
      top: 25,
      left: !_state.selecting ? 0 : 15,

      duration: Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,

      child: Row(
        children: [
          Back(
            popRoute: false,
            onPressed: () => _state.clearSelection(),
            closeIcon: true,
          ),
          const SizedBox(width: 10),
          Text(
            '${_state.selection.length}',
            style: Theme.of(context).textTheme.headline6,
          ),
        ],
      ),
    );
  } 
  
  Widget _buildSelectionMenuRight(BuildContext ctx) {
    final SelectionState _state = Provider.of<SelectionState>(ctx);
    
    return AnimatedPosOp(
      hidden: !_state.selecting,
      opacity: !_state.selecting ? 0 : 1,
      top: 25,
      right: !_state.selecting ? 0 : 15,

      duration: Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,

      child: Row(
        children: [
          // RoundButton(
          //   onPressed: () async {
          //     // for (int id in _state.selection)
          //     //   BlocProvider.of<NoteBloc>(context).add( NoteEvent.moveToArchived( id ) );
          //     _state.clearSelection();
          //   },
          //   child: Icon(Icons.text),
          // ),
          // const SizedBox(width: 10,),
          RoundButton(
            onPressed: () async {
              if (_state.selection.contains(1)) {
                var _otherName = BlocProvider.of<TopicBloc>(context).state.topics[1].topicName;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cannot delete the "$_otherName" topic.'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2, milliseconds: 500),
                  )
                );
                return;
              }

              var res = await _deleteTopicsConfirm(context, _state);

              if (res != null && res) {
                var _notes = BlocProvider.of<NoteBloc>(context).state;
                
                for (var id in _state.selection) {
                  if (_notes.notesInCategory[id] != null) {
                    for (var _id in _notes.notesInCategory[id]) {
                      var newNote = NoteModel.from( _notes.noteRef[_id] );
                      newNote.topicId = 1;

                      BlocProvider.of<NoteBloc>(context).add( NoteEvent.updateNote(_notes.noteRef[_id], newNote) );
                    }
                  }

                  BlocProvider.of<TopicBloc>(context).add( TopicEvent.deleteTopicWithID(id) );
                }
                BlocProvider.of<TopicBloc>(context).add( TopicEvent.fixOrdering() );

                _state.clearSelection();
              }
            },
              // for (int id in _state.selection)
              //   BlocProvider.of<NoteBloc>(context).add( NoteEvent.deleteNoteWithID(id) );
              // _state.clearSelection();
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Icon(Feather.trash, size: 20, color: Colors.red.shade400),
            ),
          ),
          const SizedBox(width: 10),
          RoundButton(
            onPressed: () async {
              var res = await showMenu(
                context: context,
                position: RelativeRect.fromLTRB(2000, 95, 0, 0),
                items: [
                  PopupMenuItem(
                    enabled: _state.selection.length == 1,
                    value: 'rename',
                    child: Text('Rename'),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: Text('Archive Notes'),
                  ),
                ]
              );

              switch (res) {
                case 'rename':
                  assert(_state.selection.length == 1); // sanity check

                  var _selectedID = _state.selection.first;

                  var _rename = await showDialog(
                    context: context,
                    builder: (ctx) {
                      TextEditingController controller = TextEditingController();

                      return WillPopScope(
                        onWillPop: () async { return true; },
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

                  if (_rename != null) {
                    // TODO: fix order to order before
                    BlocProvider.of<TopicBloc>(context).add( TopicEvent.updateTopic( TopicModel(_selectedID, _rename, 10) ) );
                    _state.clearSelection();
                  }

                  break;
              }
            },
            child: Icon(Icons.arrow_drop_down),
          ),
        ],
      ),
    );
  } 

  Stream<List<int>> someStream(BuildContext context, String searchString) async* {
    List<int> res = [];
    final state = BlocProvider.of<TopicBloc>(context).state;

    for (int i = 0; i < state.topics.length; ++i) {
      if (state.topics[state.topicList[i]].topicName.toLowerCase().contains(searchString)) {
        res.add(state.topicList[i]);
      }
    }

    yield res;
  }

  String s = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { 
        setState(() => searchSelected = false);
        FocusScope.of(context).requestFocus(FocusNode()); 
      },

      child: ChangeNotifierProvider<SelectionState>(
        create: (context) => SelectionState(),
        builder: (context, child) => PageWrapper(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: Theme.of(context).bottomAppBarColor
                  ),
                ),
              ),

              _buildHeader(context),
              _buildSelectionMenuLeft(context),
              _buildSelectionMenuRight(context),

              Positioned(
                top: 79,
                left:  15,
                right: 15,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    // border: Border.all(
                    //   color: searchSelected ? Theme.of(context).buttonColor : Colors.transparent,
                    //   width: searchSelected ? 0.5 : 0
                    // ),
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(8)
                  ),
                ),
              ),

              Positioned(
                top: 87,
                right: 25,
                child: Icon(Icons.search, color: Theme.of(context).iconTheme.color.withAlpha(140)),
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
                    isCollapsed: true,
                    hintText: 'Search'
                  ),
                  onChanged: (str) => setState(() => this.s = str),
                  style: Theme.of(context).textTheme.subtitle1,
                )
              ),

              Positioned(
                top: 130,
                left: 0,
                right: 0,
                bottom: 0,

                child: BlocBuilder<TopicBloc, TopicState>(
                  builder: (context, state) { 
                    final _selection = Provider.of<SelectionState>(context);
                    final state = BlocProvider.of<TopicBloc>(context).state;

                    var lst = state.topicList;

                    return reoderable.ReorderableList(
                      onReorderDone: (_) {
                        BlocProvider.of<TopicBloc>(context).add(
                          TopicEvent.reorder());
                      },
                      onReorder: (draggedItem, newPosition) { 
                        var _old = draggedItem as ValueKey;
                        var _new = newPosition as ValueKey;

                        int from = state.topicList.indexWhere((element) => element == _old.value);
                        int to = state.topicList.indexWhere((element) => element == _new.value);

                        if (from == to) return true;

                        int oldVal = state.topicList[from];
                        var tempList = List<int>();
                        int originalId = state.topicList[from];

                        for (int i = 0; i < state.topics.length; ++i) tempList.add(state.topicList[i]);
                        tempList.removeAt(from);
                        tempList.insert(to, originalId);

                        var _t = List<int>(32);
                        for (int i = 0; i < state.topics.length; ++i) {
                          _t[i] = tempList[i];
                        }

                        setState(() {
                          lst = _t;
                          state.topicList = lst;
                        });


                        // BlocProvider.of<TopicBloc>(context).add(
                        //   TopicEvent.reorder(from, to));

                        return true;
                      },
                      child: CustomScrollView(
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, idx) {
                                return reoderable.ReorderableItem(
                                  key: ValueKey(lst[idx]),
                                  childBuilder: (context, reorderState) => Opacity(
                                    opacity: reorderState == reoderable.ReorderableItemState.placeholder ? 0 : 1,
                                    child: MaterialButton(
                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 17),
                                      
                                      onPressed: () { _selection.toggleSelection(lst[idx], false); },
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                              flex: 0,
                                              child: reoderable.ReorderableListener(
                                                child: Icon(MaterialCommunityIcons.drag_vertical),
                                              ),
                                            ),
                                            Icon( _selection.contains(lst[idx]) ? Icons.check_box : Icons.check_box_outline_blank),
                                            const SizedBox(width: 5),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Text( 
                                                state.topics[lst[idx]].topicName ?? "", 
                                                textAlign: TextAlign.start,
                                                style: Theme.of(context).textTheme.subtitle1
                                              ),
                                            ),
                                          ],
                                        )
                                      ),
                                    ),
                                  )
                                );
                              },
                              childCount: state.topics.length,
                            ),
                          )
                        ],
                      )
                    );
                  }
                )
              )
            ]
          )
        ),
      ),
    );
  }
}