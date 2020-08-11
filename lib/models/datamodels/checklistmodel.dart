import 'dart:math';

import 'package:ideas_redux/models/datamodels/basedatamodel.dart';
import 'package:ideas_redux/models/datamodels/checklistitemmodel.dart';

class ChecklistModel extends BaseDataModel {
  List<ChecklistElementModel> data;

  ChecklistModel() { data = List<ChecklistElementModel>(); super.id = Random.secure().nextInt(10000); }
  factory ChecklistModel.withData(List<ChecklistElementModel> data) {
    ChecklistModel model = ChecklistModel();
    model.data = data;
    model.id = Random.secure().nextInt(10000);
    return model;
  }

  ChecklistModel.emptyWithEntry() {
    data = List<ChecklistElementModel>();
    super.id = Random.secure().nextInt(10000);
    addEmpty();
  }

  toMap() {
    return {
      'type': 'checklist',
      'data': List.generate(data.length, (index) => data[index].toMap())
    };
  }

  void addEmpty() {
    data.add(ChecklistElementModel(false, ''));
  }

  factory ChecklistModel.fromMap(Map<String, dynamic> arg) {
    //print(arg);
    var list = List<ChecklistElementModel>();
    for (var i in arg['data']) {
      //print(i);
      list.add(ChecklistElementModel.fromMap(i));
      //print("ok");
      //print(list.last.toMap());
    }
    return ChecklistModel.withData(list);
  }
}