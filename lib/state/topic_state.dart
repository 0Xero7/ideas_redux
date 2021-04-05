
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

    topics.removeWhere((_, m) => m.id == id);
    for (int i = 0; i < topicList.length; ++i)
      if (topicList[i] == id) {
        topicList[i] = null;
        break;
      }
  }

  void updateTopic(TopicModel model) {
    topics[model.id] = model;
  }

  void updateOrdering() {
    for (int i = 0; i < topics.length; ++i) {
      // if (topicList[i] == null) break;
      topics[topicList[i]].order = i;
    }
  }

  void fixOrdering() {
    int j = 0;
    for (int i = 0; i < topicList.length; ++i) {
      if (topicList[i] == null) continue;

      topicList[j] = topicList[i];
      topics[topicList[j]].order = i;
      ++j;
    }
  }

  void reorderTopics(int from, int to) {
    var tempList = List<int>();
    int originalId = this.topicList[from];

    for (int i = 0; i < topics.length; ++i) tempList.add(this.topicList[i]);
    tempList.removeAt(from);
    tempList.insert(to, originalId);

    for (int i = 0; i < topics.length; ++i) {
      topicList[i] = tempList[i];
    }
  }
}