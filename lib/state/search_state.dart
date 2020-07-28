import 'dart:collection';

import 'package:flutter/material.dart';

class SearchState<TKey, TValue> {
  HashMap<TKey, TValue> source;
  Function searchDelegate;
  SearchState({@required this.source, @required this.searchDelegate});

  Stream<int> updateSearch() async* {
    
  }
}