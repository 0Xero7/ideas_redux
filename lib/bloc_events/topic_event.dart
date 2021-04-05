import 'package:ideas_redux/models/topicmodel.dart';

enum TopicEventType {
  add, 
  delete,
  update,
  reorder,
  fixOrder
}

class TopicEvent {
  TopicModel topic;
  TopicModel otherTopic;
  TopicEventType type;
  int topidId;
  int reorderFrom, reorderTo;

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

  TopicEvent.reorder() {
    // this.topic = model;
    // this.reorderTo = to;
    // this.reorderFrom = from;
    this.type = TopicEventType.reorder;
  }

  TopicEvent.fixOrdering() {
    this.type = TopicEventType.fixOrder;
  }
}