import 'dart:math';

import 'package:ideas_redux/models/datamodels/basedatamodel.dart';

class ImageDataModel extends BaseDataModel {
  String path;
  ImageDataModel(this.path) { super.id = Random.secure().nextInt(10000); }

  Map<String, dynamic> toMap() => { 'type': 'image', 'data' : path };

  factory ImageDataModel.fromMap(Map<String, dynamic> arg) => ImageDataModel(arg['data']);
}