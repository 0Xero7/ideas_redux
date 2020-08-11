import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ideas_redux/bloc/note_bloc.dart';
import 'package:ideas_redux/bloc_events/note_event.dart';
import 'package:ideas_redux/state/note_state.dart';
import 'package:ideas_redux/state/selection_state.dart';
import 'package:ideas_redux/widgets/animatedposop.dart';
import 'package:ideas_redux/widgets/back.dart';
import 'package:ideas_redux/widgets/pagewrapper.dart';
import 'package:ideas_redux/widgets/visual/notecard.dart';
import 'package:ideas_redux/widgets/visual/roundbutton.dart';
import 'package:provider/provider.dart';

class Archived extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Archived();
  }
}

class _Archived extends State<Archived> {
  bool searchSelected = false;

  Widget _buildNameBar(BuildContext context) {
    final SelectionState state = Provider.of<SelectionState>(context);
    return AnimatedPosOp(
      top: 20,
      left: state.selecting ? 0 : 20,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      opacity:  state.selecting ? 0 : 1,
      hidden: true,

      child: Text(
        'Archived',
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

      duration: Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,

      child: Row(
        children: [
          RoundButton(
            onPressed: () async {
              for (int id in _state.selection)
                BlocProvider.of<NoteBloc>(context).add( NoteEvent.unarchive( id ) );
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
    return ChangeNotifierProvider<SelectionState>(
      create: (context) => SelectionState(),
      builder: (context, child) => PageWrapper(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () { 
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() => searchSelected = false);
                },
              )
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 85,
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

            _buildNameBar(context),
            _buildSelectionMenuLeft(context),
            _buildSelectionMenuRight(context),

            Positioned(
              top: 85,
              bottom: 0,
              left: 0,
              right: 0,            
              
              child: BlocConsumer<NoteBloc, NoteState>(
                listener: (context, state) {},
                builder: (ctx, state) {
                  var _it = state.archived.iterator;
                  _it.moveNext();

                  return StaggeredGridView.countBuilder(
                    padding: EdgeInsets.all(10),
                    crossAxisCount: 2,
                    staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                    itemCount: state.archived.length,

                    itemBuilder: (context, index) {
                      var _res = NoteCard(state.noteRef[ _it.current ]);
                      _it.moveNext();
                      return _res;
                    }
                  );
                }
              ),
            ),
          ]
        )
      ),
    );
  }
}