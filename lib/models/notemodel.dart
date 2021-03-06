import 'package:ideas_redux/helpers/crypto_helper.dart';
import 'package:ideas_redux/models/datamodels/basedatamodel.dart';
import 'package:ideas_redux/models/datamodels/checklistmodel.dart';
import 'package:ideas_redux/models/datamodels/imagedatamodel.dart';
import 'package:ideas_redux/models/datamodels/textdatamodel.dart';

class NoteModel {
  int id;
  int topicId;
  String title;
  List<BaseDataModel> data;
  bool isArchived;
  bool protected;
  bool pinned;

  int createdOn;
  int updatedOn;
  
  String encryptedData;
  String randomId; // for secure key storage

  NoteModel() { data = List<BaseDataModel>(); title = ""; }

  //  schema
  //  {
  //     'id' : <number>,
  //     'title' : '<text>',
  //     'archived' : '<bool>,
  //     'protected' : '<bool>,
  //     'pinned' : '<bool>',
  //     'createdOn' : <date>,
  //     'updatedOn' : <date>,
  //     'data' : [
  //        {
  //           'type' : 'text' or 'checklist',
  //           'data' : '<json>'
  //        },
  //     ]
  //  }

  NoteModel.empty(int topicID) {
    id = -1;
    this.topicId = topicID;
    title = null;
    data = List<BaseDataModel>();
    data.add(TextDataModel(null));
    isArchived = false;
    protected = false;
    pinned = false;

    createdOn = updatedOn = 0;    

    randomId = randomString(12);
  }

  NoteModel.from(NoteModel model) {
    this.id = model.id;
    this.title = model.title;
    this.topicId = model.topicId;
    this.data = model.data;
    this.isArchived = model.isArchived;
    this.protected = model.protected;
    this.randomId = model.randomId;
    this.pinned = model.pinned;

    this.createdOn = model.createdOn;
    this.updatedOn = model.updatedOn;
  }

  factory NoteModel.fromMap(Map<String, dynamic> arg) {
    NoteModel model = NoteModel();
    
    model.id = arg['id'] ?? -1;
    model.topicId = arg['topicId'] ?? 1;
    model.title = arg['title'];
    model.isArchived = arg['archived'] ?? false;
    model.protected = arg['protected'] ?? false;
    model.pinned = arg['pinned'] ?? false;
    model.randomId = arg['randomid'];

    model.createdOn = arg['createdOn'];
    model.updatedOn = arg['updatedOn'];

    if (!model.protected) { // unprotected data
      for (var i in arg['data']) {
        // print(i);
        if (i['type'] == 'text')
          model.data.add(TextDataModel.fromMap(i));
        else if (i['type'] == 'checklist')
          model.data.add(ChecklistModel.fromMap(i));
        else if (i['type'] == 'image')
          model.data.add(ImageDataModel.fromMap(i));
      }
    } else { // protected data
      model.encryptedData = arg['data'];
    }

    return model;
  }

  List<Map<String, dynamic>> getDataAsJson() {
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

        case ImageDataModel:
          var t = i as ImageDataModel;
          assert(t.path != null);

          _data.add( t.toMap() );
          break;
      }
    }
    return _data;
  }

  void addDataFromList(List arg) {
    data ??= List<BaseDataModel>();
    for (var i in arg) {
        if (i['type'] == 'text')
          data.add(TextDataModel.fromMap(i));
        else if (i['type'] == 'checklist')
          data.add(ChecklistModel.fromMap(i));
        else if (i['type'] == 'image')
          data.add(ImageDataModel.fromMap(i));
      }
  }

  Map<String, dynamic> toMap() {
    //assert(id != null && id > 0);
    assert(title != null);
    if (!protected) assert(data != null && data.length > 0);
    else assert(encryptedData != null && encryptedData.length > 0);


    var res = Map<String, dynamic>();

    //res['id'] = id;
    res['title'] = title;
    res['topicId'] = topicId;
    res['archived'] = isArchived;
    res['protected'] = protected ?? false;
    res['randomid'] = randomId;
    res['pinned'] = pinned;

    res['createdOn'] = createdOn;
    res['updatedOn'] = updatedOn;

    if (!protected) res['data'] = getDataAsJson();
    else res['data'] = encryptedData;
    
    return res;
  }
}