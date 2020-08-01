import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ideas_redux/bloc/note_bloc.dart';
import 'package:ideas_redux/bloc/topic_bloc.dart';
import 'package:ideas_redux/bloc_events/note_event.dart';
import 'package:ideas_redux/bloc_events/topic_event.dart';
import 'package:ideas_redux/models/datamodels/textdatamodel.dart';
import 'package:ideas_redux/models/notemodel.dart';
import 'package:ideas_redux/pages/searchnotes.dart';
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
  bool searching = false;

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
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(FeatherIcons.archive, size: 17,),
            ),
          ),
          const SizedBox(width: 10,),
          RoundButton(
            onPressed: () async {
              for (int id in _state.selection)
                BlocProvider.of<NoteBloc>(context).add( NoteEvent.deleteNoteWithID(id) );
              _state.clearSelection();
            },
            child: Padding(
              padding: const EdgeInsets.all(3.5),
              child: Icon(FeatherIcons.trash, size: 18, color: Colors.red.shade400,),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchIcon(context) {
    final SelectionState _state = Provider.of<SelectionState>(context);
    
    return AnimatedPosOp(
      hidden: _state.selecting,
      opacity: _state.selecting ? 0 : 1,
      top: 25,
      right: _state.selecting ? 0 : 15,

      duration: Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,

      child: RoundButton(
        child: Hero(
          tag: 'search_icon',
          child: Icon(Icons.search)
        ),
        onPressed: () {
          setState(() => searching = !searching);
        },
      )
    );
  }

  String _searchString = "";
  Stream<List<int>> _getFilteredTopicNotes(BuildContext context, NoteState state, int topicId, String searchString) async* {
    var res = new List<int>();

    if (state.notesInCategory[topicId] == null) yield [];
    else {
      for (var modelId in state.notesInCategory[topicId]) {
        if (state.noteRef[modelId].title.toLowerCase().contains(searchString)) {
          res.add(modelId);
          yield res;
        }
      }
    }

    yield res;
  }

  Widget _buildSearchBox(context) {
    final TextEditingController controller = TextEditingController();
    final double width = MediaQuery.of(context).size.width / 2;

    return AnimatedPosOp(
      top: 85,
      left: searching ? 10 : width,
      right: 10,

      opacity: searching ? 1 : 0,
      hidden: !searching,

      duration: Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,

      child: Stack(
        children: [
          Positioned(
            child: Container(
              height: searching ? 40 : 0,
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(8)
              ),
            ),
          ),

          Positioned(
            top: 9,
            left: 8,
            right: 8,

            child: TextField(
              enabled: searching,
              onChanged: (value) => setState(() => this._searchString = value),
              autofocus: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                isCollapsed: true,
                hintText: 'Search'
              ),
              style: Theme.of(context).textTheme.subtitle1,
            )
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

              child: AnimatedContainer(
                height: searching ? 173 : 123,

                duration: Duration(milliseconds: 150),
                curve: Curves.easeOutCubic,

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
            _buildSearchIcon(context),
            _buildSearchBox(context),


            AnimatedPositioned(
              top: searching ? 130 : 80,
              left: 0,
              right: 0,
              bottom: 0,

              duration: Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,

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
        return StreamBuilder(
          stream: _getFilteredTopicNotes(context, noteList, topicKey, _searchString),
          builder: (context, snapshot) => ((snapshot.data?.length ?? 0) == 0) ?
            Center(
              child: Opacity(
                opacity: 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open, size: 40),
                    Text('Nothing here', style: Theme.of(context).textTheme.headline6,),
                  ],
                ),
              ),
            )
          : StaggeredGridView.countBuilder(
            padding: EdgeInsets.only(top: 10, left: 10, right: 10),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,

            itemCount: snapshot.data?.length ?? 0,
            staggeredTileBuilder: (index) => StaggeredTile.fit(1),
            itemBuilder: (_, index) => NoteCard( noteList.noteRef[snapshot.data[index]] )
          ),
        );
      }
    );
}