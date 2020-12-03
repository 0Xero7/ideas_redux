import 'package:ideas_redux/models/notemodel.dart';

enum EventType {
  add,
  delete,
  deleteWithID,
  update,
  moveToArchived,
  unarchive,
  pin,
  unpin
}

class NoteEvent {
  NoteModel newNote;
  NoteModel oldNote;
  EventType eventType;
  int noteId;

  NoteEvent.addNote(this.newNote) {
    eventType = EventType.add;
  }

  NoteEvent.deleteNote(this.newNote) {
    eventType = EventType.delete;
  }

  NoteEvent.deleteNoteWithID(this.noteId) {
    eventType = EventType.deleteWithID;
  }

  NoteEvent.updateNote(this.oldNote, this.newNote) {
    eventType = EventType.update;
  }

  NoteEvent.moveToArchived(this.noteId) {
    eventType = EventType.moveToArchived;
  }

  NoteEvent.unarchive(this.noteId) {
    eventType = EventType.unarchive;
  }

  NoteEvent.pin(this.noteId) {
    eventType = EventType.pin;
  }

  NoteEvent.unpin(this.noteId) {
    eventType = EventType.unpin;
  }
}