import 'package:ideas_redux/models/datamodels/basedatamodel.dart';

class TextDataModel extends BaseDataModel {
  String data;

  TextDataModel(this.data);

  toMap() => { 'type': 'text', 'data': data };
  factory TextDataModel.fromMap(Map<String, dynamic> arg) => TextDataModel(arg['data']);
}