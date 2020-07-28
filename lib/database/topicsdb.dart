import 'dart:convert';
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
      var _topic = TopicModel(1, 'Other');
      await updateTopic(_topic);
    }
  }

  static Future<List<TopicModel>> loadTopics() async {
    var res = List<TopicModel>();

    for (var key in _topicBox.keys) {
      String json = _topicBox.get(key);
            
      var model = TopicModel.fromMap((jsonDecode(json)) as Map<String, dynamic>);
      model.id = key;

      res.add( model );
    }

    return res;
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