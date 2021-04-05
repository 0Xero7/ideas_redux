import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ideas_redux/activeTopicBookkeeper.dart';
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
  int _indexBeforeSearch = 0;

  List<NoteModel> _deleted;
  
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    ActiveTopic.activeTopicIndex = BlocProvider.of<TopicBloc>(context).state.topicList[0];

    _tabController = TabController(
      vsync: this,
      length: BlocProvider.of<TopicBloc>(context).state.topics.length
    );
    _tabController.addListener(() {
      print('changing');
      ActiveTopic.activeTopicIndex = 
        BlocProvider.of<TopicBloc>(context).state.topicList[_tabController.index];
    });

    _deleted = [];
  }

  Widget _buildHeader(BuildContext ctx) {
    final SelectionState _state = Provider.of<SelectionState>(ctx);
    
    return AnimatedPosOp(
      hidden: true,
      opacity: _state.selecting ? 0 : 1,
      top: 20,
      left: _state.selecting ? 0 : 18,

      duration: Duration(milliseconds: 100),
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

  Future<bool> _getDeleteConfirmation(context) async {
    final bool res = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Warning'),
        content: Text('Delete all selected notes?'),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context, false); },
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context, true);
            },
            child: Text(
              'Delete',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        ],
      ),
    );

    return res;
  }
  
  Widget _buildSelectionMenuRight(BuildContext ctx) {
    final SelectionState _state = Provider.of<SelectionState>(ctx);
    print(_state.pinnedParityPreserved);
    
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
            disabled: !_state.pinnedParityPreserved,
            onPressed: () async {
              for (int id in _state.selection) {
                BlocProvider.of<NoteBloc>(context).add(
                  _state.pinned == 0 ? NoteEvent.pin( id ) : NoteEvent.unpin( id ) );
              }
              _state.clearSelection();
            },
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Transform.rotate(
                angle: 25 * 3.14159 / 180,
                child: Icon(_state.pinned == 0 ? 
                  MaterialCommunityIcons.pin_outline :
                  MaterialCommunityIcons.pin_off_outline, size: 20,)
              ),
            ),
          ),
          const SizedBox(width: 10,),
          RoundButton(
            onPressed: () async {
              for (int id in _state.selection)
                BlocProvider.of<NoteBloc>(context).add( NoteEvent.moveToArchived( id ) );
              _state.clearSelection();
            },
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Feather.archive, size: 17,),
            ),
          ),
          const SizedBox(width: 10,),
          RoundButton(
            onPressed: () async {
              var res = await _getDeleteConfirmation(context);
              if (!res) return;

              for (int id in _state.selection) {
                _deleted.add( NoteModel.from( BlocProvider.of<NoteBloc>(context).state.noteRef[id] ) );
                BlocProvider.of<NoteBloc>(context).add( NoteEvent.deleteNoteWithID(id) );
              }
              _state.clearSelection();

              
              await ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () { 
                      for (var x in _deleted) {
                        BlocProvider.of<NoteBloc>(context).add( NoteEvent.addNote(x) );
                      }
                    },
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3),
                )
              ).closed;
              
              _deleted.clear();
            },
            child: Padding(
              padding: const EdgeInsets.all(3.5),
              child: Icon(Feather.trash, size: 18, color: Colors.red.shade400,),
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

      duration: Duration(milliseconds: _state.selecting ? 50 : 100),
      curve: Curves.easeOutCubic,

      child: RoundButton(
        child: Hero(
          tag: 'search_icon',
          child: Icon(Icons.search)
        ),
        onPressed: () {
          setState(() => searching = !searching);
          
          if (searching) {
            _indexBeforeSearch = _tabController.index;
            _tabController = TabController(
              length: BlocProvider.of<TopicBloc>(context).state.topics.length + 1, 
              vsync: this, 
              initialIndex: 0
            );
          } else {
            var _length = BlocProvider.of<TopicBloc>(context).state.topics.length;
            _tabController = TabController(
              length: _length, 
              vsync: this, 
              initialIndex: (_indexBeforeSearch < BlocProvider.of<TopicBloc>(context).state.topics.length ? _indexBeforeSearch : 0)
            );
          }

          _tabController.addListener(() {
            ActiveTopic.activeTopicIndex = 
              BlocProvider.of<TopicBloc>(context).state.topicList[_tabController.index];
          });
        },
      )
    );
  }

  String _searchString = "";

  Stream<List<int>> _getFilteredTopicNotes(BuildContext context, NoteState state, int topicId, String searchString) async* {
    List<int> res = [];

    if (state.notesInCategory[topicId] == null) yield res;
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

  Stream<List<int>> _getFilteredNotes(BuildContext context, NoteState state, String searchString) async* {
    List<int> res = [];

    for (var model in state.noteRef.values) {
        if (model.title.toLowerCase().contains(searchString)) {
          res.add(model.id);
          yield res;
        }
    }

    yield res;

    // if (state.notesInCategory[topicId] == null) yield res;
    // else {
    //   for (var modelId in state.notesInCategory[topicId]) {
    //     if (state.noteRef[modelId].title.toLowerCase().contains(searchString)) {
    //       res.add(modelId);
    //       yield res;
    //     }
    //   }
    // }

    // yield res;
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

  Widget buildStaggeredGridView(int topicKey, [bool isSearchResults = false]) {
    var gridView = BlocConsumer<NoteBloc, NoteState>(
      listener: (_, __) {},
      builder: (cxt, noteList) {
        return StreamBuilder(
          stream: isSearchResults ? _getFilteredNotes(context, noteList, _searchString) : _getFilteredTopicNotes(context, noteList, topicKey, _searchString),
          builder: (context, snapshot) {
            // _rc = snapshot.data?.length ?? 0;
            return ((snapshot.data?.length ?? 0) == 0) ?
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
            itemBuilder: (_, index) {
              return NoteCard( noteList.noteRef[snapshot.data[index]] );
            }
          );
          },
        );
      }
    );

    return gridView;
  }

  @override
  Widget build(BuildContext context) {
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
              top: searching ? 130 : 77,
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
                          indicatorPadding: EdgeInsets.only(
                            left: 5, right: 5, bottom: 3
                          ),

                          tabs: List.generate(
                            state.topics.length + (searching ? 1 : 0), 
                            (index) {
                              return Tab(
                                child: Text((searching && index == 0 ? "Search Results" :
                                  state.topics[state.topicList[index - (searching ? 1 : 0)]].topicName), 
                                style: Theme.of(context).textTheme.subtitle1,),
                              );
                            }
                          )
                        )
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: List.generate(
                            BlocProvider.of<TopicBloc>(context).state.topics.length + (searching ? 1 : 0), 
                            (index) {
                              if (searching && index == 0) return buildStaggeredGridView(
                                0,
                                true
                              );
                              else return buildStaggeredGridView(
                                BlocProvider.of<TopicBloc>(context).state.topicList[index - (searching ? 1 : 0)]
                              );
                            }
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
}