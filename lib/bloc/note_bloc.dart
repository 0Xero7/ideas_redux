import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ideas_redux/bloc_events/note_event.dart';
import 'package:ideas_redux/crypto/crypto.dart';
import 'package:ideas_redux/database/notesdb.dart';
import 'package:ideas_redux/helpers/crypto_helper.dart';
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
        final secureStorage = FlutterSecureStorage();
        // is note protected? if so, encrypt it and remove data
        if (event.newNote.protected) {          
          var json = jsonEncode(event.newNote.getDataAsJson());
          event.newNote.data.clear();
          
          String _key, _iv;
          _key = randomString(32);
          _iv = randomString(16);

          // write key and iv to keystore
          await secureStorage.write(key: '${event.newNote.randomId}_key', value: _key);
          await secureStorage.write(key: '${event.newNote.randomId}_iv', value: _iv);

          event.newNote.encryptedData = encryptAES(json, _key, _iv);
        }

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
        final secureStorage = FlutterSecureStorage();
        // is note protected? if so, encrypt it, and remove the data part
        if (event.newNote.protected) {
          var json = jsonEncode(event.newNote.getDataAsJson());
          event.newNote.data.clear();
          
          String _key, _iv;
          // this means that the model was changed from unprotected to protected
          if (!event.oldNote.protected) {
            
            // create new key and iv
            _key = randomString(32);
            _iv = randomString(16);

            // write key and iv to keystore
            await secureStorage.write(key: '${event.newNote.randomId}_key', value: _key);
            await secureStorage.write(key: '${event.newNote.randomId}_iv', value: _iv);

            print(await secureStorage.read(key: '${event.newNote.randomId}_key'));
            print(await secureStorage.read(key: '${event.newNote.randomId}_iv'));
          } else { // this means that we are re-writing an already protected note
            // get key and iv from keystore
            _key = await secureStorage.read(key: '${event.newNote.randomId}_key');
            _iv  = await secureStorage.read(key: '${event.newNote.randomId}_iv');
          }

          event.newNote.encryptedData = encryptAES(json, _key, _iv);
        } else {
          if (event.oldNote.protected) {
            // changed from protected to unprotected
            // delete existing key and iv

            await secureStorage.delete(key: '${event.newNote.randomId}_key');
            await secureStorage.delete(key: '${event.newNote.randomId}_iv');
          }
        }

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

      case EventType.pin:
        NoteState newState = NoteState.from(state);
        final _note = newState.noteRef[event.noteId];

        await NotesDB.pinNote(_note);
        newState.pinNoteWithId(_note.id);

        yield newState;
        break;

      case EventType.unpin:
        NoteState newState = NoteState.from(state);
        final _note = newState.noteRef[event.noteId];

        await NotesDB.unpinNote(_note);
        newState.unpinNoteWithId(_note.id);

        yield newState;
        break;


      default: throw Exception('Event ${event.eventType}  found');
    }
  }

}
