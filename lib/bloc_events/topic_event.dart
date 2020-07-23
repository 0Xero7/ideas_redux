import 'package:ideas_redux/models/topicmodel.dart';

enum TopicEventType {
  add, 
  delete,
  update
}

class TopicEvent {
  TopicModel topic;
  TopicEventType type;

  TopicEvent.addTopic(TopicModel model) {
    this.topic = model;
    this.type = TopicEventType.add;
  }

  TopicEvent.deleteTopic(TopicModel model) {
    this.topic = model;
    this.type = TopicEventType.delete;
  }

  TopicEvent.updateTopic(TopicModel model) {
    this.topic = model;
    this.type = TopicEventType.update;
  }
}