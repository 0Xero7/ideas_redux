import 'package:flutter/material.dart';

class ObjectGroup<T> {
  List<T> nodes;
  Function create;

  ObjectGroup(this.create, [int count = 1]) {
    nodes = [];
    // for (int i = 0; i < count; ++i) nodes.add( create() );
  }
}