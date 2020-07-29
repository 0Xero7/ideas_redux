import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:ideas_redux/bloc/note_bloc.dart';
import 'package:ideas_redux/bloc/topic_bloc.dart';
import 'package:ideas_redux/bloc_events/topic_event.dart';
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
          ),
          const SizedBox(width: 10),
          Text(
            '${_state.selection.length} notes selected',
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
              var res = await _deleteTopicsConfirm(context, _state);

              if (res != null && res) {
                for (var id in _state.selection)
                  BlocProvider.of<TopicBloc>(context).add( TopicEvent.deleteTopicWithID(id) );

                _state.clearSelection();
              }
            },
              // for (int id in _state.selection)
              //   BlocProvider.of<NoteBloc>(context).add( NoteEvent.deleteNoteWithID(id) );
              // _state.clearSelection();
            child: Icon(Icons.delete, color: Colors.red.shade400),
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
                    BlocProvider.of<TopicBloc>(context).add( TopicEvent.updateTopic( TopicModel(_selectedID, _rename) ) );
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
    List<int> res = List<int>();
    final state = BlocProvider.of<TopicBloc>(context).state;

    for (var i in state.topics.values) {
      if (i.topicName.toLowerCase().contains(searchString)) {
        res.add(i.id);
        yield res;
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
                    
                    return StreamBuilder(
                      stream: someStream(context, s),
                      builder: (context, snapshot) {
                        return ReorderableList(
                          onReorder: (draggedItem, newPosition) { 
                            var _old = draggedItem as ValueKey;
                            var _new = draggedItem as ValueKey;
                            // print(_old.toString() + "," + _new.toString());
                            return true;
                          },
                          child: CustomScrollView(
                            slivers: [
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, id) {
                                    return ReorderableItem(
                                      key: ValueKey(id),
                                      childBuilder: (context, reorder_state) => MaterialButton(
                                        padding: EdgeInsets.symmetric(horizontal: 17, vertical: 17),
                                        
                                        onPressed: () { _selection.toggleSelection(snapshot.data[id]); },
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon( _selection.contains(snapshot.data[id]) ? Icons.check_box : Icons.check_box_outline_blank),
                                              const SizedBox(width: 5),
                                              Text( 
                                                state.topics[snapshot.data[id]].topicName ?? "", 
                                                textAlign: TextAlign.start,
                                                style: Theme.of(context).textTheme.subtitle1
                                              ),

                                              // TODO: Implement reorder later.
                                              // %%%% IT'S HARD %%%%
                                              // Expanded(
                                              //   child: Align(
                                              //     alignment: Alignment.centerRight,
                                              //     child: ReorderableListener(
                                              //       child: Container(
                                              //         child: Icon(Icons.drag_handle),
                                              //       ),
                                              //     ),
                                              //   ),
                                              // )
                                            ],
                                          )
                                        ),
                                      )
                                    );
                                  },
                                  childCount: snapshot.data.length,
                                ),
                              )
                            ],
                          )
                        );
                        
                        
                        return ListView.separated(
                        separatorBuilder: (context, index) => Divider(
                          height: 0, thickness: 0,
                          indent: 10,
                          endIndent: 10,
                        ),

                        itemCount: snapshot.data.length,
                        itemBuilder: (_, id) => MaterialButton(
                          padding: EdgeInsets.symmetric(horizontal: 17, vertical: 17),
                          
                          onPressed: () { _selection.toggleSelection(snapshot.data[id]); },
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon( _selection.contains(snapshot.data[id]) ? Icons.check_box : Icons.check_box_outline_blank),
                                const SizedBox(width: 5),
                                Text( 
                                  state.topics[snapshot.data[id]].topicName ?? "", 
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context).textTheme.subtitle1
                                ),
                              ],
                            )
                          ),
                        )
                      );
                      },
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