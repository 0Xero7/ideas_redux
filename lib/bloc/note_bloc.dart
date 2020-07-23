import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideas_redux/bloc_events/note_event.dart';
import 'package:ideas_redux/database/notesdb.dart';
import 'package:ideas_redux/models/notemodel.dart';
import 'package:ideas_redux/state/note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc(NoteState initialState) : super(initialState) {
    initialState = NoteState();
  }

  @override
  Stream<NoteState> mapEventToState(NoteEvent event) async* {
    switch (event.eventType) {
      case EventType.add:
        var key = await NotesDB.addNote(event.newNote);
        event.newNote.id = key;

        NoteState newState = NoteState.from(state);
        if (event.newNote != null) newState.addNote(event.newNote);

        yield newState;
        break;
      
      case EventType.delete:
        await NotesDB.deleteNote(event.newNote);
        
        NoteState newState = NoteState.from(state);
        newState.deleteNote(event.newNote);

        yield newState;
        break;

      case EventType.deleteWithID:
        await NotesDB.deleteNoteWithID(event.noteId);

        NoteState newState = NoteState.from(state);
        newState.deleteNoteWithID(event.noteId);

        yield newState;
        break;

      case EventType.update:
        await NotesDB.updateNote(event.newNote);

        NoteState newState = NoteState.from(state);
        newState.updateNote(event.oldNote, event.newNote);

        yield newState;
        break;

      case EventType.moveToArchived:
        NoteState newState = NoteState.from(state);
        var _note = newState.noteRef[event.noteId];

        await NotesDB.moveToArchived(_note);
        newState.moveNoteToArchived(_note);

        yield newState;
        break;

      case EventType.unarchive:
        NoteState newState = NoteState.from(state);
        final _note = newState.noteRef[event.noteId];

        await NotesDB.unarchive(_note);
        newState.unarchiveNoteWithId(_note);

        yield newState;
        break;


      default: throw Exception('Event ${event.eventType}  found');
    }
  }

}
