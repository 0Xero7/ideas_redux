import 'dart:math';

import 'package:ideas_redux/models/datamodels/basedatamodel.dart';

class TextDataModel extends BaseDataModel {
  String data;
  TextDataModel(this.data, {int id}) {
    super.id = id ?? Random.secure().nextInt(10000);
  }

  toMap() => { 'type': 'text', 'data': data };
  factory TextDataModel.fromMap(Map<String, dynamic> arg) => TextDataModel(arg['data'], id:Random.secure().nextInt(10000));
}