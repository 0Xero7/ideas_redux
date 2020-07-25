import 'package:ideas_redux/models/topicmodel.dart';

enum TopicEventType {
  add, 
  delete,
  update
}

class TopicEvent {
  TopicModel topic;
  TopicEventType type;
  int topidId;

  TopicEvent.addTopic(TopicModel model) {
    this.topic = model;
    this.type = TopicEventType.add;
  }

  TopicEvent.deleteTopicWithID(this.topidId) {
    this.type = TopicEventType.delete;
  }

  TopicEvent.updateTopic(TopicModel model) {
    this.topic = model;
    this.type = TopicEventType.update;
  }
}