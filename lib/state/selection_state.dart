import 'dart:collection';

import 'package:flutter/cupertino.dart';

class SelectionState with ChangeNotifier {
  HashSet<int> _selection;
  HashSet<int> get selection => _selection;
  bool get selecting => (_selection.length > 0);

  bool get pinnedParityPreserved => (pinned == 0 || unpinned == 0);

  int pinned, unpinned;
  
  SelectionState() : _selection = HashSet<int>(), pinned = 0, unpinned = 0;

  void addToSelection(int id, bool isPinned) {
    _selection.add(id);

    if (isPinned) ++pinned;
    else ++unpinned;
    
    notifyListeners();
  }

  void removeFromSelection(int id, bool isPinned) {
    _selection.remove(id);
    
    if (isPinned) --pinned;
    else --unpinned;

    notifyListeners();
  }

  void toggleSelection(int id, bool isPinned) {
    if (contains(id)) removeFromSelection(id, isPinned);
    else addToSelection(id, isPinned);
    notifyListeners();
  }

  void clearSelection() {
    _selection.clear();
    pinned = unpinned = 0;
    
    notifyListeners();
  }

  bool contains(int id) => _selection.contains(id);
}