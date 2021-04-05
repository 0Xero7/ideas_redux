import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:ideas_redux/models/topicmodel.dart';
import 'package:path_provider/path_provider.dart';

class TopicsDB {
  static Box _topicBox;

  static Future initDB() async {
    // initialize Hive database
    Directory docPath = await getApplicationDocumentsDirectory();
    Hive.init(docPath.path);

    // await Hive.deleteBoxFromDisk("topics");
    _topicBox = await Hive.openBox<String>("topics");

    if (!_topicBox.containsKey(1)) {
      print('its not here buddy');
      var _topic = TopicModel(1, 'Other', 0);
      await updateTopic(_topic);
    } else {
      String json = _topicBox.get(1);
      var model = TopicModel.fromMap((jsonDecode(json)) as Map<String, dynamic>);
      if (model.order == null) {
        var _topic = TopicModel(1, 'Other', 0);
        await updateTopic(_topic);
      }
    }
  }

  static Future<List<TopicModel>> loadTopics() async {
    List<TopicModel> res = [];

    for (var key in _topicBox.keys) {
      String json = _topicBox.get(key);
      
      print(json);

      var model = TopicModel.fromMap((jsonDecode(json)) as Map<String, dynamic>);
      model.id = key;

      res.add( model );
    }

    return res;
  }

  static Future<int> rewriteAll(HashMap<int, TopicModel> data) async {
    for (var i in data.values)
      await updateTopic(i);
  }

  static Future<int> addTopic(TopicModel model) async {
    model.id = await _topicBox.add( jsonEncode(model.toMap()) );
    return model.id;
  }

  static Future deleteTopicWithID(int id) async {
    await _topicBox.delete(id);
  }

  static Future updateTopic(TopicModel model) async {
    await _topicBox.put(model.id, jsonEncode(model.toMap()));
  }
}