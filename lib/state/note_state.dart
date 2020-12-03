import 'dart:collection';

import 'package:ideas_redux/models/notemodel.dart';

class NoteState {
  HashMap<int, NoteModel> noteRef;
  NoteModel noteWithID(int id) => noteRef[id];

  HashMap<int, List<int>> notesInCategory;
  HashSet<int> archived;
  
  NoteState() {
    // notes = Set<NoteModel>();
    noteRef = HashMap<int, NoteModel>();
    notesInCategory = HashMap<int, List<int>>();
    archived = HashSet<int>();
  }

  NoteState._with(HashMap<int, NoteModel> _noteRef, HashMap<int, List<int>> _nic, HashSet<int> _archived) {
    // notes = _notes ?? Set<NoteModel>();
    noteRef = _noteRef ?? HashMap<int, NoteModel>();
    notesInCategory = _nic ??  HashMap<int, List<int>>();
    archived = _archived ?? HashSet<int>();
  }

  factory NoteState.from(NoteState state) {
    return NoteState._with(state.noteRef, state.notesInCategory, state.archived);
  }

  void _addNoteToCategory(NoteModel note) {
    notesInCategory[note.topicId] ??= List<int>();
    notesInCategory[note.topicId].add(note.id);
    
    orderCategory(note.topicId);
  }

  void addNote(NoteModel model) {
    if (noteRef.containsKey(model.id)) return;

    // notes.add(model);

    noteRef[model.id] = model;

    if (model.isArchived) {
      archived.add(model.id);
    } else {
      notesInCategory[model.topicId] ??= List<int>();
      notesInCategory[model.topicId].add(model.id);

      orderCategory(model.topicId);
    }
  }

  void deleteNote(NoteModel model) {
    assert(noteRef.containsKey(model.id));

    // notes.remove(model);
    noteRef.remove(model.id);

    if (model.isArchived) {
      archived.remove(model.id);
    } else {
      notesInCategory[model.topicId].remove(model.id);
    }
  }

  void deleteNoteWithID(int id) {
    print("deleting with id $id");
    assert(noteRef.containsKey(id));

    int topicId = noteRef[id].topicId;
    bool _isArchived = noteRef[id].isArchived;
    noteRef.remove(id);

    if (_isArchived) {
      archived.remove(id);
    } else {
      notesInCategory[topicId].remove(id);
    }
  }

  void moveNoteToArchived(NoteModel model) {
    assert(noteRef.containsKey(model.id));
    assert(notesInCategory[model.topicId].contains(model.id));

    notesInCategory[model.topicId].removeWhere((elem) => elem == model.id);
    archived.add(model.id);
  }

  void unarchiveNoteWithId(NoteModel note) {
    assert(noteRef.containsKey(note.id));
    assert(archived.contains(note.id));

    note.isArchived = false;

    archived.remove(note.id);
    _addNoteToCategory(note);
  }

  void pinNoteWithId(int id) {
    assert(noteRef.containsKey(id));

    noteRef[id].pinned = true;
    orderCategory(noteRef[id].topicId);
  }

  void unpinNoteWithId(int id) {
    assert(noteRef.containsKey(id));

    noteRef[id].pinned = false;
    orderCategory(noteRef[id].topicId);
  }

  // updating archived notes is not allowed
  void updateNote(NoteModel oldModel, NoteModel newModel) {
    assert(oldModel.id == newModel.id);
    assert(noteRef.containsKey(oldModel.id));

    notesInCategory[oldModel.topicId].removeWhere((key) => key == oldModel.id);
    _addNoteToCategory(newModel);
  }

  void orderCategory(int categoryId) {
      notesInCategory[categoryId].sort((a, b) {
        if ((noteRef[a].pinned && noteRef[b].pinned) || (!noteRef[a].pinned && !noteRef[b].pinned))
          return noteRef[b].updatedOn - noteRef[a].updatedOn;
        else {
          if (noteRef[a].pinned) return -1;
          return 1;
        }
      });
  }

  void debug() {
    for (var i in noteRef.keys)
      print(i);
  }
}