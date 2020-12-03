import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:ideas_redux/models/notemodel.dart';
import 'package:ideas_redux/testdata/testnotes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';


class NotesDB {
  static Box _noteBox;
  static DatabaseFactory _dbFactory;
  static Database db;

  static Future initDB() async {
    // initialize DBFactory
    _dbFactory = databaseFactoryIo;

    var docPath = await getApplicationDocumentsDirectory();
    var dbPath = join(docPath.path, 'notes.db');

    db = await _dbFactory.openDatabase(dbPath, version: 1, onVersionChanged: (d, x, y) {
      // TODO: Implement onVersionChanged() attribute
    });

    // // initialize Hive database
    // Directory docPath = await getApplicationDocumentsDirectory();
    // Hive.init(docPath.path);
    
    // // store notes in json format
    // // await Hive.deleteBoxFromDisk("notes");
    // _noteBox = await Hive.openBox<String>("notes");

    // // DEV ONLY
    // //await _noteBox.add( jsonEncode(TestNoteData.notes[0].toMap()) );

  }

  static Future<List<NoteModel>> loadNotes() async {
    var res = List<NoteModel>();

    var store = intMapStoreFactory.store();

    var finder = Finder(
      // filter: Filter.equals('pinned', false),
      sortOrders: [ SortOrder('updatedOn', false) ]
    );

    var keys = await store.findKeys(db, finder: finder);
    var records = await store.records(keys).get(db);

    for (int i = 0; i < keys.length; ++i) {
      var data = records[i];
      var model = NoteModel.fromMap(data);
      model.id = keys[i];
      res.add(model);
    }

    // for (var key in _noteBox.keys) {
    //   String json = _noteBox.get(key);

    //   print(json);
            
    //   var model = NoteModel.fromMap((jsonDecode(json)) as Map<String, dynamic>);
    //   model.id = key;

    //   res.add( model );
    // }

    return res;
  }

  static Future<int> addNote(NoteModel note) async {
    // var key = await _noteBox.add( jsonEncode(note.toMap()) );

    var store = intMapStoreFactory.store();
    int key = await store.add(db, note.toMap());
  
    return key;
  }

  static Future updateNote(NoteModel note) async {
    var store = intMapStoreFactory.store();
    var record = store.record(note.id);

    await record.update(db, note.toMap());

    // await _noteBox.put(note.id, jsonEncode(note.toMap()));
  }

  static Future deleteNote(NoteModel note) async {
    var store = intMapStoreFactory.store();
    var record = store.record(note.id);

    await record.delete(db);

    // await _noteBox.delete(note.id);
  }

  static Future deleteNoteWithID(int id) async {
    var store = intMapStoreFactory.store();
    var record = store.record(id);

    await record.delete(db);
  }

  static Future moveToArchived(NoteModel note) async {
    note.isArchived = true;
    await updateNote(note);
  }

  static Future unarchive(NoteModel note) async {
    note.isArchived = false;
    await updateNote(note);
  }

  static Future pinNote(NoteModel note) async {
    note.pinned = true;
    
    var store = intMapStoreFactory.store();
    var record = store.record(note.id);

    await record.put(db, {'pinned': true}, merge: true);
  }

  static Future unpinNote(NoteModel note) async {
    note.pinned = false;
    
    var store = intMapStoreFactory.store();
    var record = store.record(note.id);

    await record.put(db, {'pinned': false}, merge: true);
  }
}