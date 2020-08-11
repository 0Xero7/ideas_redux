import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:ideas_redux/models/notemodel.dart';
import 'package:ideas_redux/testdata/testnotes.dart';
import 'package:path_provider/path_provider.dart';

class NotesDB {
  static Box _noteBox;

  static Future initDB() async {
    // initialize Hive database
    Directory docPath = await getApplicationDocumentsDirectory();
    Hive.init(docPath.path);
    
    // store notes in json format
    // await Hive.deleteBoxFromDisk("notes");
    _noteBox = await Hive.openBox<String>("notes");

    // DEV ONLY
    //await _noteBox.add( jsonEncode(TestNoteData.notes[0].toMap()) );
  }

  static Future<List<NoteModel>> loadNotes() async {
    var res = List<NoteModel>();

    for (var key in _noteBox.keys) {
      String json = _noteBox.get(key);

      print(json);
            
      var model = NoteModel.fromMap((jsonDecode(json)) as Map<String, dynamic>);
      model.id = key;

      res.add( model );
    }

    return res;
  }

  static Future<int> addNote(NoteModel note) async {
    var key = await _noteBox.add( jsonEncode(note.toMap()) );
    return key;
  }

  static Future updateNote(NoteModel note) async {
    await _noteBox.put(note.id, jsonEncode(note.toMap()));
  }

  static Future deleteNote(NoteModel note) async {
    await _noteBox.delete(note.id);
  }

  static Future deleteNoteWithID(int id) async {
    await _noteBox.delete(id);
  }

  static Future moveToArchived(NoteModel note) async {
    note.isArchived = true;
    await updateNote(note);
  }

  static Future unarchive(NoteModel note) async {
    note.isArchived = false;
    await updateNote(note);
  }
}