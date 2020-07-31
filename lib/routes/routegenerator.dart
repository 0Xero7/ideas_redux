import 'package:flutter/material.dart';
import 'package:ideas_redux/models/notemodel.dart';
import 'package:ideas_redux/pages/mainpages/about.dart';
import 'package:ideas_redux/pages/mainpages/noteentry.dart';
import 'package:ideas_redux/pages/stackedpage.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => StackedPage());

      case '/editentry':
        return MaterialPageRoute(builder: (_) => NoteEntry(args as NoteModel));

      case '/about':
        return MaterialPageRoute(builder: (_) => AboutPage());
    }
  }
}