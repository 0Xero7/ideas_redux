import 'dart:collection';

import 'package:flutter/cupertino.dart';

class SelectionState with ChangeNotifier {
  HashSet<int> _selection;
  HashSet<int> get selection => _selection;
  bool get selecting => (_selection.length > 0);
  
  SelectionState() : _selection = HashSet<int>();

  void addToSelection(int id) {
    _selection.add(id);
    notifyListeners();
  }

  void removeFromSelection(int id) {
    _selection.remove(id);
    notifyListeners();
  }

  void toggleSelection(int id) {
    if (contains(id)) removeFromSelection(id);
    else addToSelection(id);
    notifyListeners();
  }

  void clearSelection() {
    _selection.clear();
    notifyListeners();
  }

  bool contains(int id) => _selection.contains(id);
}