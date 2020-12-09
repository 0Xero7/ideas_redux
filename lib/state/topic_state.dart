
import 'dart:collection';

import 'package:ideas_redux/models/topicmodel.dart';

class TopicState {
  HashMap<int, TopicModel> topics;
  List<int> topicList;

  TopicState() {
    topics = HashMap<int, TopicModel>();
    topicList = List<int>(32);
  }

  TopicState.from(TopicState oldState) {
    this.topics = oldState.topics;
    this.topicList = oldState.topicList;
  }

  void addTopic(TopicModel model) {
    topics[model.id] = model;
    topicList[model.order] = model.id;
  }

  void deleteTopic(int id) {
    assert(topics.containsKey(id));
    topics.remove(id);
  }

  void updateTopic(TopicModel model) {
    topics[model.id] = model;
  }
}