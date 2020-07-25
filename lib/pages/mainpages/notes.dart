import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ideas_redux/bloc/note_bloc.dart';
import 'package:ideas_redux/bloc/topic_bloc.dart';
import 'package:ideas_redux/bloc_events/note_event.dart';
import 'package:ideas_redux/bloc_events/topic_event.dart';
import 'package:ideas_redux/models/datamodels/textdatamodel.dart';
import 'package:ideas_redux/models/notemodel.dart';
import 'package:ideas_redux/state/note_state.dart';
import 'package:ideas_redux/state/selection_state.dart';
import 'package:ideas_redux/state/topic_state.dart';
import 'package:ideas_redux/testdata/testnotes.dart';
import 'package:ideas_redux/widgets/animatedposop.dart';
import 'package:ideas_redux/widgets/back.dart';
import 'package:ideas_redux/widgets/pagewrapper.dart';
import 'package:ideas_redux/widgets/visual/notecard.dart';
import 'package:ideas_redux/widgets/visual/roundbutton.dart';
import 'package:provider/provider.dart';

class Notes extends StatefulWidget {
  NoteModel note = NoteModel();

  @override
  State<StatefulWidget> createState() {
    return _Notes();
  }
}

class _Notes extends State<Notes> with TickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    super.initState();
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
        'Notes',
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
          RoundButton(
            onPressed: () async {
              for (int id in _state.selection)
                BlocProvider.of<NoteBloc>(context).add( NoteEvent.moveToArchived( id ) );
              _state.clearSelection();
            },
            child: Icon(Icons.archive, color: Colors.black87,),
          ),
          const SizedBox(width: 10,),
          RoundButton(
            onPressed: () async {
              for (int id in _state.selection)
                BlocProvider.of<NoteBloc>(context).add( NoteEvent.deleteNoteWithID(id) );
              _state.clearSelection();
            },
            child: Icon(Icons.delete, color: Colors.red.shade400),
          ),
        ],
      ),
    );
  } 

  @override
  Widget build(BuildContext context) {
    _tabController = TabController(
      vsync: this,
      length: BlocProvider.of<TopicBloc>(context).state.topics.length
    );

    return ChangeNotifierProvider(
      create: (context) => SelectionState(),
      
      builder: (context, child) => PageWrapper(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,

              child: Container(
                height: 123,
                decoration: BoxDecoration(
                  color: Theme.of(context).bottomAppBarColor,
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 0),
                      color: Colors.black.withAlpha(12),
                      blurRadius: 5
                    )
                  ]
                ),
              ),
            ),

            _buildHeader(context),
            _buildSelectionMenuLeft(context),
            _buildSelectionMenuRight(context),


            Positioned(
              top: 80,
              left: 0,
              right: 0,
              bottom: 0,

              child: BlocConsumer<TopicBloc, TopicState>(
                listener: (context, state) {
                  _tabController = TabController(
                    length: state.topics.length,
                    vsync: this
                  );
                },
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 0,
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true, 
                          indicatorPadding: EdgeInsets.all(5),

                          tabs: List.generate(
                            state.topics.length, 
                            (index) => 
                              Tab(child: Text(state.topics.values.elementAt(index).topicName, style: Theme.of(context).textTheme.subtitle1,),)
                          )
                        )
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: List.generate(
                            BlocProvider.of<TopicBloc>(context).state.topics.length, 
                            (index) => buildStaggeredGridView(
                              BlocProvider.of<TopicBloc>(context).state.topics.keys.elementAt(index)
                            )
                          )
                        ),
                      ),
                    ],
                  );
                }
              )
            ),
          ],
        )
      ),
    );
  }

  Widget buildStaggeredGridView(int topicKey) => 
    BlocConsumer<NoteBloc, NoteState>(
      listener: (_, __) {},
      builder: (cxt, noteList) {
        return StaggeredGridView.countBuilder(
          padding: EdgeInsets.only(top: 10, left: 10, right: 10),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,

          itemCount: noteList.notesInCategory[topicKey]?.length ?? 0,
          staggeredTileBuilder: (index) => StaggeredTile.fit(1),
          itemBuilder: (_, index) => NoteCard( noteList.noteRef[noteList.notesInCategory[topicKey][index]] )
        );
      }
    );
}