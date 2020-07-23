import 'package:ideas_redux/models/datamodels/basedatamodel.dart';
import 'package:ideas_redux/models/datamodels/checklistmodel.dart';
import 'package:ideas_redux/models/datamodels/textdatamodel.dart';

class NoteModel {
  int id;
  int topicId;
  String title;
  List<BaseDataModel> data;
  bool isArchived;

  NoteModel() { data = List<BaseDataModel>(); title = ""; }

  //  schema
  //  {
  //     'id' : <number>,
  //     'title' : '<text>',
  //     'data' : [
  //        {
  //           'type' : 'text' or 'checklist',
  //           'data' : '<json>'
  //        },
  //     ]
  //  }

  NoteModel.empty() {
    id = -1;
    topicId = 1;
    title = null;
    data = List<BaseDataModel>();
    data.add(TextDataModel(null));
    isArchived = false;
  }

  NoteModel.from(NoteModel model) {
    this.id = model.id;
    this.title = model.title;
    this.topicId = model.topicId;
    this.data = model.data;
    this.isArchived = model.isArchived;
  }

  factory NoteModel.fromMap(Map<String, dynamic> arg) {
    NoteModel model = NoteModel();
    
    model.id = arg['id'] ?? -1;
    model.topicId = arg['topicId'] ?? 1;
    model.title = arg['title'];
    model.isArchived = arg['archived'] ?? false;

    for (var i in arg['data']) {
      // print(i);
      if (i['type'] == 'text') 
        model.data.add(TextDataModel.fromMap(i));
      else if (i['type'] == 'checklist')
        model.data.add(ChecklistModel.fromMap(i));
    }

    return model;
  }

  Map<String, dynamic> toMap() {
    //assert(id != null && id > 0);
    assert(title != null);
    assert(data != null && data.length > 0);


    var res = Map<String, dynamic>();

    //res['id'] = id;
    res['title'] = title;
    res['topicId'] = topicId;
    res['archived'] = isArchived;

    var _data = List<Map<String, dynamic>>();
    for (var i in data) {
      switch (i.runtimeType) {
        case TextDataModel:
          var t = i as TextDataModel;

          _data.add( t.toMap() );
          break;

        case ChecklistModel:
          var t = i as ChecklistModel;
          assert(t.data != null && t.data.length > 0);

          _data.add( t.toMap() );
          break;
      }
    }

    res['data'] = _data;
    return res;
  }
}