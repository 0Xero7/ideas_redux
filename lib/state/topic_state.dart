
import 'dart:collection';

import 'package:ideas_redux/models/topicmodel.dart';

class TopicState {
  HashMap<int, TopicModel> topics;

  TopicState() {
    topics = HashMap<int, TopicModel>();
  }

  TopicState.from(TopicState oldState) {
    this.topics = oldState.topics;
  }

  void addTopic(TopicModel model) {
    topics[model.id] = model;
  }

  void deleteTopic(TopicModel model) {
    assert(topics.containsKey(model.id));
    topics.remove(model.id);
  }

  void updateTopic(TopicModel model) {
    topics[model.id] = model;
  }
}